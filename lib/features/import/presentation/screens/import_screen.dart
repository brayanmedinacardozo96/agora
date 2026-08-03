import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImportarDatosApp extends StatelessWidget {
  const ImportarDatosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ImportarDatosScreen();
  }
}

// ---------------------------------------------------------------------------
// Modelo de un registro importado
// ---------------------------------------------------------------------------

class RegistroImportado {
  String documento;
  String nombre;
  String apellidos;
  String telefono;
  List<String> errores;

  RegistroImportado({
    required this.documento,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    this.errores = const [],
  });

  bool get esValido => errores.isEmpty;
}

// Nombres de columna aceptados (sin tildes, en minúscula) para cada campo.
const Map<String, List<String>> _columnasAceptadas = {
  'documento': [
    'documento',
    'numero_documento',
    'numerodocumento',
    'cedula',
    'nuip',
  ],
  'nombre': ['nombre', 'nombres'],
  'apellidos': ['apellido', 'apellidos'],
  'telefono': ['telefono', 'celular', 'numero_telefono', 'movil'],
};

String _normalizar(String texto) => texto
    .trim()
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll(RegExp(r'[^a-z0-9_]'), '');

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class ImportarDatosScreen extends StatefulWidget {
  const ImportarDatosScreen({super.key});

  @override
  State<ImportarDatosScreen> createState() => _ImportarDatosScreenState();
}

class _ImportarDatosScreenState extends State<ImportarDatosScreen> {
  List<RegistroImportado> _registros = [];
  String? _nombreArchivo;
  String? _errorArchivo;
  bool _cargandoArchivo = false;
  bool _importando = false;
  bool _soloConErrores = false;

  int get _totalValidos => _registros.where((r) => r.esValido).length;
  int get _totalConErrores => _registros.where((r) => !r.esValido).length;

  List<RegistroImportado> get _registrosMostrados => _soloConErrores
      ? _registros.where((r) => !r.esValido).toList()
      : _registros;

  // ---------- Selección y lectura del archivo ----------

  Future<void> _seleccionarArchivo() async {
    setState(() {
      _errorArchivo = null;
    });

    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) return;

    final archivo = resultado.files.first;
    final bytes = archivo.bytes;
    if (bytes == null) {
      setState(() => _errorArchivo = 'No se pudo leer el archivo seleccionado');
      return;
    }

    setState(() {
      _cargandoArchivo = true;
      _nombreArchivo = archivo.name;
    });

    try {
      final extension = archivo.extension?.toLowerCase() ?? '';
      final filas = extension == 'xlsx'
          ? _leerFilasXlsx(bytes)
          : _leerFilasCsv(bytes);

      final registros = _procesarFilas(filas);

      setState(() {
        _registros = registros;
        _cargandoArchivo = false;
      });
    } catch (e) {
      setState(() {
        _cargandoArchivo = false;
        _errorArchivo = 'No se pudo procesar el archivo: $e';
      });
    }
  }

  List<List<dynamic>> _leerFilasCsv(Uint8List bytes) {
    final contenido = utf8.decode(bytes, allowMalformed: true);
    return const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(contenido);
  }

  List<List<dynamic>> _leerFilasXlsx(Uint8List bytes) {
    final libro = xls.Excel.decodeBytes(bytes);
    final hoja = libro.tables.values.first;
    return hoja.rows
        .map(
          (fila) =>
              fila.map((celda) => celda?.value?.toString() ?? '').toList(),
        )
        .toList();
  }

  List<RegistroImportado> _procesarFilas(List<List<dynamic>> filas) {
    if (filas.isEmpty) return [];

    final encabezados = filas.first
        .map((c) => _normalizar(c.toString()))
        .toList();

    int? indiceDe(String campo) {
      final candidatos = _columnasAceptadas[campo]!;
      for (int i = 0; i < encabezados.length; i++) {
        if (candidatos.contains(encabezados[i])) return i;
      }
      return null;
    }

    final idxDocumento = indiceDe('documento');
    final idxNombre = indiceDe('nombre');
    final idxApellidos = indiceDe('apellidos');
    final idxTelefono = indiceDe('telefono');

    String celda(List<dynamic> fila, int? indice) =>
        (indice != null && indice < fila.length)
        ? fila[indice].toString().trim()
        : '';

    final registros = <RegistroImportado>[];
    for (int i = 1; i < filas.length; i++) {
      final fila = filas[i];
      if (fila.every((c) => c.toString().trim().isEmpty)) continue;

      registros.add(
        RegistroImportado(
          documento: celda(fila, idxDocumento),
          nombre: celda(fila, idxNombre),
          apellidos: celda(fila, idxApellidos),
          telefono: celda(fila, idxTelefono),
        ),
      );
    }

    _revalidarTodos(registros);
    return registros;
  }

  // ---------- Validación ----------

  void _revalidarTodos(List<RegistroImportado> registros) {
    final documentosVistos = <String, int>{};
    for (final r in registros) {
      if (r.documento.isNotEmpty) {
        documentosVistos[r.documento] =
            (documentosVistos[r.documento] ?? 0) + 1;
      }
    }

    for (final r in registros) {
      final errores = <String>[];
      if (r.documento.isEmpty) {
        errores.add('Falta el número de documento');
      } else if (!RegExp(r'^\d{5,15}$').hasMatch(r.documento)) {
        errores.add('El documento debe ser numérico (5-15 dígitos)');
      } else if ((documentosVistos[r.documento] ?? 0) > 1) {
        errores.add('Documento duplicado en el archivo');
      }
      if (r.nombre.isEmpty) errores.add('Falta el nombre');
      if (r.apellidos.isEmpty) errores.add('Faltan los apellidos');
      if (r.telefono.isEmpty) {
        errores.add('Falta el teléfono');
      } else if (!RegExp(r'^\d{7,15}$').hasMatch(r.telefono)) {
        errores.add('El teléfono debe ser numérico (7-15 dígitos)');
      }
      r.errores = errores;
    }
  }

  // ---------- Acciones sobre la lista ----------

  void _eliminarRegistro(RegistroImportado registro) {
    setState(() {
      _registros.remove(registro);
      _revalidarTodos(_registros);
    });
  }

  Future<void> _editarRegistro(RegistroImportado registro) async {
    final docCtrl = TextEditingController(text: registro.documento);
    final nombreCtrl = TextEditingController(text: registro.nombre);
    final apellidosCtrl = TextEditingController(text: registro.apellidos);
    final telefonoCtrl = TextEditingController(text: registro.telefono);

    final guardar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar registro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _campoEdicion('Número de documento', docCtrl, TextInputType.number),
            const SizedBox(height: 12),
            _campoEdicion('Nombre', nombreCtrl, TextInputType.text),
            const SizedBox(height: 12),
            _campoEdicion('Apellidos', apellidosCtrl, TextInputType.text),
            const SizedBox(height: 12),
            _campoEdicion('Teléfono', telefonoCtrl, TextInputType.phone),
            const SizedBox(height: 18),
            SizedBox(
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );

    if (guardar == true) {
      setState(() {
        registro.documento = docCtrl.text.trim();
        registro.nombre = nombreCtrl.text.trim();
        registro.apellidos = apellidosCtrl.text.trim();
        registro.telefono = telefonoCtrl.text.trim();
        _revalidarTodos(_registros);
      });
    }
  }

  Widget _campoEdicion(
    String label,
    TextEditingController controller,
    TextInputType tipo,
  ) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[400]!),
        ),
      ),
    );
  }

  void _limpiarArchivo() {
    setState(() {
      _registros = [];
      _nombreArchivo = null;
      _errorArchivo = null;
      _soloConErrores = false;
    });
  }

  Future<void> _descargarPlantilla() async {
    final filas = [
      ['documento', 'nombre', 'apellidos', 'telefono'],
      ['1082345678', 'Camilo', 'Perdomo Rojas', '3201234567'],
    ];
    final csv = const ListToCsvConverter().convert(filas);

    final directorio = await getTemporaryDirectory();
    final archivo = File('${directorio.path}/plantilla_importacion.csv');
    await archivo.writeAsString(csv);

    await Share.shareXFiles([
      XFile(archivo.path),
    ], text: 'Plantilla para importar usuarios');
  }

  Future<void> _importarRegistros() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar importación',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Se importarán $_totalValidos registros válidos'
          '${_totalConErrores > 0 ? ' (se omitirán $_totalConErrores con errores)' : ''}. '
          '¿Deseas continuar?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.blue[400]),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _importando = true);

    // Solo se simula la importación (UI únicamente, sin lógica de backend).
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _importando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_totalValidos registros importados correctamente'),
        ),
      );
      _limpiarArchivo();
    });
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Importar Usuarios'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPlantillaCard(),
                    const SizedBox(height: 16),
                    _buildSelectorArchivo(),
                    if (_errorArchivo != null) ...[
                      const SizedBox(height: 12),
                      _buildErrorArchivo(),
                    ],
                    if (_registros.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildResumenValidacion(),
                      const SizedBox(height: 12),
                      ..._registrosMostrados.map(_buildRegistroCard),
                    ],
                  ],
                ),
              ),
            ),
            if (_registros.isNotEmpty) _buildBarraInferior(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantillaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: Colors.blue[300], size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Descarga la plantilla con las columnas correctas: documento, '
              'nombre, apellidos y teléfono.',
              style: TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
          ),
          TextButton(
            onPressed: _descargarPlantilla,
            style: TextButton.styleFrom(foregroundColor: Colors.blue[300]),
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorArchivo() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _cargandoArchivo ? null : _seleccionarArchivo,
      child: DottedBorderContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              if (_cargandoArchivo)
                const CircularProgressIndicator(strokeWidth: 2)
              else
                Icon(
                  _nombreArchivo == null
                      ? Icons.upload_file_outlined
                      : Icons.check_circle_outline,
                  color: _nombreArchivo == null
                      ? Colors.white54
                      : Colors.green[400],
                  size: 34,
                ),
              const SizedBox(height: 10),
              Text(
                _nombreArchivo ?? 'Seleccionar archivo CSV o Excel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _nombreArchivo == null ? Colors.white70 : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _nombreArchivo == null
                    ? 'Toca para elegir un archivo .csv o .xlsx'
                    : 'Toca para elegir otro archivo',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorArchivo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[400]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[400]!.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorArchivo!,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenValidacion() {
    return Row(
      children: [
        Expanded(
          child: _chipResumen(
            texto: '$_totalValidos válidos',
            color: Colors.green[400]!,
            seleccionado: !_soloConErrores,
            onTap: () => setState(() => _soloConErrores = false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _chipResumen(
            texto: '$_totalConErrores con errores',
            color: Colors.red[300]!,
            seleccionado: _soloConErrores,
            onTap: () => setState(() => _soloConErrores = true),
          ),
        ),
      ],
    );
  }

  Widget _chipResumen({
    required String texto,
    required Color color,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.15)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? color : const Color(0xFF334155),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: seleccionado ? color : Colors.white54,
            fontSize: 12.5,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRegistroCard(RegistroImportado registro) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: registro.esValido ? Colors.green[400]! : Colors.red[300]!,
            width: 3,
          ),
          top: const BorderSide(color: Color(0xFF334155)),
          right: const BorderSide(color: Color(0xFF334155)),
          bottom: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  registro.nombre.isEmpty && registro.apellidos.isEmpty
                      ? '(sin nombre)'
                      : '${registro.nombre} ${registro.apellidos}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _editarRegistro(registro),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.white54,
                ),
                tooltip: 'Editar',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => _eliminarRegistro(registro),
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red[300],
                ),
                tooltip: 'Eliminar',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Doc: ${registro.documento.isEmpty ? '—' : registro.documento}   ·   '
            'Tel: ${registro.telefono.isEmpty ? '—' : registro.telefono}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (!registro.esValido) ...[
            const SizedBox(height: 6),
            ...registro.errores.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 12, color: Colors.red[300]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(color: Colors.red[300], fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarraInferior() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Color(0xFF334155))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue[400],
              disabledBackgroundColor: const Color(0xFF334155),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: (_totalValidos == 0 || _importando)
                ? null
                : _importarRegistros,
            child: _importando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Importar $_totalValidos registros válidos',
                    style: const TextStyle(fontSize: 15),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Contenedor con borde punteado simple (sin dependencias externas)
/// usado como zona de "arrastrar/seleccionar archivo".
class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const DottedBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DottedBorderPainter(), child: child);
  }
}

class _DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
