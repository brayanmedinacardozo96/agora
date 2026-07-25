import 'dart:typed_data';

import 'package:agora/features/voting/presentation/screens/vote_success.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VotarScreen();
  }
}

// ---------------------------------------------------------------------------
// Modelos de datos usados solo por la UI (datos de ejemplo, sin backend)
// ---------------------------------------------------------------------------

enum TarjetonModo { nombreYPartido, soloNombre, soloPartido }

extension TarjetonModoX on TarjetonModo {
  bool get pideNombre => this != TarjetonModo.soloPartido;
  bool get pidePartido => this != TarjetonModo.soloNombre;
}

class OpcionVotacion {
  final String id;
  final String? nombre;
  final String? partido;
  final Color color;

  const OpcionVotacion({
    required this.id,
    this.nombre,
    this.partido,
    required this.color,
  });

  /// Texto principal a mostrar según lo que tenga disponible.
  String get titulo => nombre ?? partido ?? '';

  /// Iniciales para el avatar circular.
  String get iniciales {
    final base = nombre ?? partido ?? '?';
    final partes = base.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }
}

class TarjetonVotacion {
  final String id;
  final String titulo;
  final TarjetonModo modo;
  final List<OpcionVotacion> opciones;

  const TarjetonVotacion({
    required this.id,
    required this.titulo,
    required this.modo,
    required this.opciones,
  });
}

// Datos de ejemplo — en una app real vendrían de la configuración de la votación.
final List<TarjetonVotacion> _tarjetonesEjemplo = [
  const TarjetonVotacion(
    id: 'gobernacion',
    titulo: 'Gobernación',
    modo: TarjetonModo.nombreYPartido,
    opciones: [
      OpcionVotacion(
        id: 'g1',
        nombre: 'Ana Torres',
        partido: 'Partido Verde',
        color: Color(0xFF22C55E),
      ),
      OpcionVotacion(
        id: 'g2',
        nombre: 'Carlos Ruiz',
        partido: 'Partido Azul',
        color: Color(0xFF3B82F6),
      ),
      OpcionVotacion(
        id: 'g3',
        nombre: 'Marta Gómez',
        partido: 'Movimiento Cívico',
        color: Color(0xFFF59E0B),
      ),
    ],
  ),
  const TarjetonVotacion(
    id: 'alcaldia',
    titulo: 'Alcaldía',
    modo: TarjetonModo.nombreYPartido,
    opciones: [
      OpcionVotacion(
        id: 'a1',
        nombre: 'Luis Pérez',
        partido: 'Partido Verde',
        color: Color(0xFF22C55E),
      ),
      OpcionVotacion(
        id: 'a2',
        nombre: 'Sofía León',
        partido: 'Alianza Ciudadana',
        color: Color(0xFFA855F7),
      ),
    ],
  ),
  const TarjetonVotacion(
    id: 'camara',
    titulo: 'Cámara',
    modo: TarjetonModo.soloPartido,
    opciones: [
      OpcionVotacion(
        id: 'c1',
        partido: 'Partido Verde',
        color: Color(0xFF22C55E),
      ),
      OpcionVotacion(
        id: 'c2',
        partido: 'Partido Azul',
        color: Color(0xFF3B82F6),
      ),
      OpcionVotacion(
        id: 'c3',
        partido: 'Movimiento Cívico',
        color: Color(0xFFF59E0B),
      ),
      OpcionVotacion(
        id: 'c4',
        partido: 'Alianza Ciudadana',
        color: Color(0xFFA855F7),
      ),
    ],
  ),
];

const String _tituloVotacion = 'Elecciones Regionales 2026';
const String _idVotoBlanco = '__voto_en_blanco__';

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class VotarScreen extends StatefulWidget {
  const VotarScreen({super.key});

  @override
  State<VotarScreen> createState() => _VotarScreenState();
}

class _VotarScreenState extends State<VotarScreen> {
  final List<TarjetonVotacion> _tarjetones = _tarjetonesEjemplo;
  final PageController _pageController = PageController();

  /// tarjetonId -> opcionId seleccionada (o _idVotoBlanco)
  final Map<String, String> _selecciones = {};

  /// tarjetonId -> fotos de evidencia adjuntas para ese tarjetón
  final Map<String, List<XFile>> _evidencias = {};
  final ImagePicker _picker = ImagePicker();

  /// Cambia a `true` si quieres exigir al menos una foto por tarjetón
  /// para poder continuar.
  static const bool _evidenciaObligatoria = false;

  int _paginaActual = 0;
  bool _enviando = false;

  /// El total de páginas incluye una página final de resumen.
  int get _totalPaginas => _tarjetones.length + 1;
  bool get _esPaginaResumen => _paginaActual == _tarjetones.length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _seleccionar(String tarjetonId, String opcionId) {
    setState(() => _selecciones[tarjetonId] = opcionId);
  }

  void _irASiguiente() {
    if (_paginaActual < _totalPaginas - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  void _irAAnterior() {
    if (_paginaActual > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _agregarEvidencia(String tarjetonId) async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Agregar evidencia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Tomar foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Elegir de galería',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (origen == null) return;

    final foto = await _picker.pickImage(source: origen, imageQuality: 80);
    if (foto == null || !mounted) return;

    setState(() {
      _evidencias.putIfAbsent(tarjetonId, () => []).add(foto);
    });
  }

  void _eliminarEvidencia(String tarjetonId, int index) {
    setState(() => _evidencias[tarjetonId]?.removeAt(index));
  }

  void _irATarjeton(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _confirmarVoto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar voto',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Una vez confirmado, no podrás modificar tu voto. ¿Deseas continuar?',
          style: TextStyle(color: Colors.white70),
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
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _enviando = true);

    // Solo se simula el envío (UI únicamente, sin lógica de backend).
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Voto registrado correctamente!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VotoExitosoApp()),
      );
    });
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              _tituloVotacion,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              _esPaginaResumen
                  ? 'Resumen de tu voto'
                  : 'Tarjetón ${_paginaActual + 1} de ${_tarjetones.length}',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgresoDots(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _totalPaginas,
                onPageChanged: (i) => setState(() => _paginaActual = i),
                itemBuilder: (context, index) {
                  if (index == _tarjetones.length) {
                    return _buildResumen();
                  }
                  return _buildTarjetonPage(_tarjetones[index]);
                },
              ),
            ),
            _buildBarraInferior(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgresoDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPaginas, (i) {
          final activo = i == _paginaActual;
          final completado = i < _paginaActual;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: activo ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: activo || completado
                  ? Colors.blue[400]
                  : const Color(0xFF334155),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // ---------- Página de un tarjetón ----------

  Widget _buildTarjetonPage(TarjetonVotacion tarjeton) {
    final seleccionActual = _selecciones[tarjeton.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tarjeton.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selecciona una opción',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              ...tarjeton.opciones.map(
                (opcion) => _buildOpcionCard(
                  tarjeton: tarjeton,
                  opcion: opcion,
                  seleccionada: seleccionActual == opcion.id,
                ),
              ),
              const SizedBox(height: 8),
              _buildVotoEnBlancoCard(
                tarjeton: tarjeton,
                seleccionada: seleccionActual == _idVotoBlanco,
              ),
              const SizedBox(height: 28),
              _buildEvidenciaSection(tarjeton),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Evidencia fotográfica ----------

  Widget _buildEvidenciaSection(TarjetonVotacion tarjeton) {
    final fotos = _evidencias[tarjeton.id] ?? const <XFile>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Evidencia fotográfica',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_evidenciaObligatoria) ...[
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: Colors.red[300])),
            ],
            const Spacer(),
            if (fotos.isNotEmpty)
              Text(
                '${fotos.length} foto${fotos.length == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _evidenciaObligatoria
              ? 'Adjunta al menos una foto que respalde la votación de este tarjetón'
              : 'Adjunta una foto que respalde la votación de este tarjetón (opcional)',
          style: const TextStyle(color: Colors.white54, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < fotos.length; i++)
              _buildFotoThumbnail(tarjeton.id, fotos[i], i),
            _buildAgregarFotoTile(tarjeton.id),
          ],
        ),
      ],
    );
  }

  Widget _buildFotoThumbnail(String tarjetonId, XFile foto, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 84,
            height: 84,
            child: FutureBuilder<Uint8List>(
              future: foto.readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: const Color(0xFF1E293B),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              },
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _eliminarEvidencia(tarjetonId, index),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgregarFotoTile(String tarjetonId) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _agregarEvidencia(tarjetonId),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.white54, size: 20),
            SizedBox(height: 4),
            Text(
              'Agregar',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionCard({
    required TarjetonVotacion tarjeton,
    required OpcionVotacion opcion,
    required bool seleccionada,
  }) {
    final modo = tarjeton.modo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _seleccionar(tarjeton.id, opcion.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: seleccionada
                ? Colors.blue[400]!.withValues(alpha: 0.12)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: seleccionada ? Colors.blue[400]! : const Color(0xFF334155),
              width: seleccionada ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: opcion.color.withValues(alpha: 0.2),
                child: Text(
                  opcion.iniciales,
                  style: TextStyle(
                    color: opcion.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (modo.pideNombre && opcion.nombre != null)
                      Text(
                        opcion.nombre!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (modo.pidePartido && opcion.partido != null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: modo.pideNombre && opcion.nombre != null ? 2 : 0,
                        ),
                        child: Text(
                          opcion.partido!,
                          style: TextStyle(
                            color: modo.pideNombre
                                ? Colors.white54
                                : Colors.white,
                            fontSize: modo.pideNombre ? 13 : 15,
                            fontWeight: modo.pideNombre
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildRadioIndicador(seleccionada),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVotoEnBlancoCard({
    required TarjetonVotacion tarjeton,
    required bool seleccionada,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _seleccionar(tarjeton.id, _idVotoBlanco),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionada
              ? Colors.blue[400]!.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionada ? Colors.blue[400]! : const Color(0xFF334155),
            width: seleccionada ? 2 : 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.block_outlined, color: Colors.white38, size: 22),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Voto en blanco',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildRadioIndicador(seleccionada),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioIndicador(bool seleccionada) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: seleccionada ? Colors.blue[400] : Colors.transparent,
        border: Border.all(
          color: seleccionada ? Colors.blue[400]! : Colors.white38,
          width: 2,
        ),
      ),
      child: seleccionada
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }

  // ---------- Página de resumen ----------

  Widget _buildResumen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Revisa tu voto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Verifica cada tarjetón antes de confirmar',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              ...List.generate(_tarjetones.length, (i) {
                final tarjeton = _tarjetones[i];
                final seleccionId = _selecciones[tarjeton.id];
                return _buildResumenCard(tarjeton, seleccionId, i);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenCard(
    TarjetonVotacion tarjeton,
    String? seleccionId,
    int index,
  ) {
    final fotosCount = _evidencias[tarjeton.id]?.length ?? 0;
    String textoSeleccion;
    IconData icono;
    Color colorIcono;

    if (seleccionId == null) {
      textoSeleccion = 'Sin responder';
      icono = Icons.error_outline;
      colorIcono = Colors.orange[300]!;
    } else if (seleccionId == _idVotoBlanco) {
      textoSeleccion = 'Voto en blanco';
      icono = Icons.block_outlined;
      colorIcono = Colors.white38;
    } else {
      final opcion = tarjeton.opciones.firstWhere((o) => o.id == seleccionId);
      final partes = <String>[
        if (tarjeton.modo.pideNombre && opcion.nombre != null) opcion.nombre!,
        if (tarjeton.modo.pidePartido && opcion.partido != null)
          opcion.partido!,
      ];
      textoSeleccion = partes.join(' · ');
      icono = Icons.check_circle;
      colorIcono = Colors.green[400]!;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Icon(icono, color: colorIcono, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarjeton.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    textoSeleccion,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 13,
                        color: fotosCount > 0
                            ? Colors.blue[300]
                            : Colors.white24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fotosCount > 0
                            ? '$fotosCount foto${fotosCount == 1 ? '' : 's'} adjunta${fotosCount == 1 ? '' : 's'}'
                            : 'Sin evidencia fotográfica',
                        style: TextStyle(
                          color: fotosCount > 0
                              ? Colors.blue[300]
                              : Colors.white24,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _irATarjeton(index),
              style: TextButton.styleFrom(foregroundColor: Colors.blue[300]),
              child: const Text('Editar'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Barra inferior de navegación ----------

  Widget _buildBarraInferior() {
    final tarjetonActual = _esPaginaResumen ? null : _tarjetones[_paginaActual];
    final puedeAvanzar = tarjetonActual == null
        ? true
        : _selecciones.containsKey(tarjetonActual.id) &&
              (!_evidenciaObligatoria ||
                  (_evidencias[tarjetonActual.id]?.isNotEmpty ?? false));
    final todasRespondidas = _tarjetones.every(
      (t) =>
          _selecciones.containsKey(t.id) &&
          (!_evidenciaObligatoria || (_evidencias[t.id]?.isNotEmpty ?? false)),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Row(
          children: [
            if (_paginaActual > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _enviando ? null : _irAAnterior,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Atrás'),
                ),
              ),
            if (_paginaActual > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  disabledBackgroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _enviando
                    ? null
                    : _esPaginaResumen
                    ? (todasRespondidas ? _confirmarVoto : null)
                    : (puedeAvanzar ? _irASiguiente : null),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _esPaginaResumen ? 'Confirmar voto' : 'Continuar',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
