import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VotacionConfigApp extends StatelessWidget {
  const VotacionConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return VotacionConfigScreen();
  }
}

// ---------------------------------------------------------------------------
// Modelos de datos usados solo por la UI (sin lógica de negocio)
// ---------------------------------------------------------------------------

/// Una opción / candidato dentro de un tarjetón.
class OpcionData {
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController partidoCtrl = TextEditingController();

  void dispose() {
    nombreCtrl.dispose();
    partidoCtrl.dispose();
  }
}

/// Define qué campos se piden por cada opción de un tarjetón.
enum TarjetonModo { nombreYPartido, soloNombre, soloPartido }

extension TarjetonModoX on TarjetonModo {
  String get etiqueta {
    switch (this) {
      case TarjetonModo.nombreYPartido:
        return 'Nombre y partido';
      case TarjetonModo.soloNombre:
        return 'Solo nombre';
      case TarjetonModo.soloPartido:
        return 'Solo partido';
    }
  }

  bool get pideNombre => this != TarjetonModo.soloPartido;
  bool get pidePartido => this != TarjetonModo.soloNombre;
}

/// Un tarjetón (ej: Gobernación, Alcaldía, Cámara) con sus opciones.
class TarjetonData {
  final TextEditingController tituloCtrl = TextEditingController();
  final List<OpcionData> opciones = [OpcionData(), OpcionData()];
  bool expandido = true;
  TarjetonModo modo = TarjetonModo.nombreYPartido;

  void dispose() {
    tituloCtrl.dispose();
    for (final o in opciones) {
      o.dispose();
    }
  }
}

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class VotacionConfigScreen extends StatefulWidget {
  const VotacionConfigScreen({super.key});

  @override
  State<VotacionConfigScreen> createState() => _VotacionConfigScreenState();
}

class _VotacionConfigScreenState extends State<VotacionConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final txtTitulo = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFinal;
  bool _fechasTocadas = false;

  final List<TarjetonData> _tarjetones = [TarjetonData()];

  bool _isLoading = false;

  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void dispose() {
    txtTitulo.dispose();
    for (final t in _tarjetones) {
      t.dispose();
    }
    super.dispose();
  }

  // ---------- Acciones ----------

  Future<void> _seleccionarFecha({required bool esInicio}) async {
    final ahora = DateTime.now();
    final fechaBase = esInicio
        ? (_fechaInicio ?? ahora)
        : (_fechaFinal ?? _fechaInicio ?? ahora);

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaBase,
      firstDate: DateTime(ahora.year - 1),
      lastDate: DateTime(ahora.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(surface: const Color(0xFF1E293B)),
        ),
        child: child!,
      ),
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fechaBase),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(surface: const Color(0xFF1E293B)),
        ),
        child: child!,
      ),
    );
    if (hora == null) return;

    final fechaCompleta = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );

    setState(() {
      _fechasTocadas = true;
      if (esInicio) {
        _fechaInicio = fechaCompleta;
      } else {
        _fechaFinal = fechaCompleta;
      }
    });
  }

  void _agregarTarjeton() {
    setState(() => _tarjetones.add(TarjetonData()));
  }

  void _eliminarTarjeton(int index) {
    setState(() {
      _tarjetones[index].dispose();
      _tarjetones.removeAt(index);
    });
  }

  void _agregarOpcion(TarjetonData tarjeton) {
    setState(() => tarjeton.opciones.add(OpcionData()));
  }

  void _eliminarOpcion(TarjetonData tarjeton, int index) {
    setState(() {
      tarjeton.opciones[index].dispose();
      tarjeton.opciones.removeAt(index);
    });
  }

  String? get _errorFechas {
    if (!_fechasTocadas) return null;
    if (_fechaInicio == null || _fechaFinal == null) {
      return 'Selecciona ambas fechas';
    }
    if (!_fechaFinal!.isAfter(_fechaInicio!)) {
      return 'La fecha final debe ser posterior a la fecha de inicio';
    }
    return null;
  }

  void _guardar() {
    setState(() => _fechasTocadas = true);

    final formOk = _formKey.currentState!.validate();
    final fechasOk =
        _errorFechas == null && _fechaInicio != null && _fechaFinal != null;

    if (!formOk || !fechasOk) return;

    setState(() => _isLoading = true);

    // Solo se simula el guardado (UI únicamente, sin lógica de backend).
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración de votación validada')),
      );
    });
  }

  // ---------- Estilos compartidos ----------

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: icon == null ? null : Icon(icon, color: Colors.white54),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[400]!),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ---------- Secciones ----------

  Widget _buildTituloField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Título de la votación'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtTitulo,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.sentences,
          decoration: _fieldDecoration(
            hint: 'Ej: Elecciones Regionales 2026',
            icon: Icons.how_to_vote_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa el título de la votación';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFechaSelector({
    required String label,
    required DateTime? valor,
    required VoidCallback onTap,
    bool tieneError = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tieneError
                      ? Colors.red[300]!
                      : const Color(0xFF334155),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      valor == null ? 'Seleccionar' : _dateFormat.format(valor),
                      style: TextStyle(
                        color: valor == null ? Colors.white38 : Colors.white,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFechasRow() {
    final error = _errorFechas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFechaSelector(
              label: 'Fecha inicio',
              valor: _fechaInicio,
              tieneError: error != null,
              onTap: () => _seleccionarFecha(esInicio: true),
            ),
            const SizedBox(width: 12),
            _buildFechaSelector(
              label: 'Fecha final',
              valor: _fechaFinal,
              tieneError: error != null,
              onTap: () => _seleccionarFecha(esInicio: false),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              error,
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildModoSelector(TarjetonData tarjeton) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos que se registran por opción',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: TarjetonModo.values.map((modo) {
            final selected = tarjeton.modo == modo;
            final esUltimo = modo == TarjetonModo.values.last;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: esUltimo ? 0 : 8),
                child: GestureDetector(
                  onTap: () => setState(() => tarjeton.modo = modo),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.blue[400]!.withValues(alpha: 0.15)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? Colors.blue[400]!
                            : const Color(0xFF334155),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      modo.etiqueta,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.blue[100] : Colors.white60,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOpcionRow(TarjetonData tarjeton, int index) {
    final opcion = tarjeton.opciones[index];
    final puedeEliminar = tarjeton.opciones.length > 1;
    final modo = tarjeton.modo;

    final campoNombre = TextFormField(
      controller: opcion.nombreCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.words,
      decoration: _fieldDecoration(
        hint: modo == TarjetonModo.nombreYPartido
            ? 'Nombre del candidato'
            : 'Nombre del candidato / opción',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Requerido';
        }
        return null;
      },
    );

    final campoPartido = TextFormField(
      controller: opcion.partidoCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.words,
      decoration: _fieldDecoration(
        hint: modo == TarjetonModo.nombreYPartido
            ? 'Partido / lista (opcional)'
            : 'Partido / lista',
      ),
      validator: modo == TarjetonModo.soloPartido
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Requerido';
              }
              return null;
            }
          : null,
    );

    // Según el modo, se arma la lista de campos visibles para esta opción.
    final List<Widget> campos = [];
    if (modo.pideNombre) {
      campos.add(Expanded(flex: modo.pidePartido ? 3 : 1, child: campoNombre));
    }
    if (modo.pideNombre && modo.pidePartido) {
      campos.add(const SizedBox(width: 8));
    }
    if (modo.pidePartido) {
      campos.add(Expanded(flex: modo.pideNombre ? 2 : 1, child: campoPartido));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          ...campos,
          IconButton(
            onPressed: puedeEliminar
                ? () => _eliminarOpcion(tarjeton, index)
                : null,
            icon: Icon(
              Icons.remove_circle_outline,
              color: puedeEliminar ? Colors.red[300] : Colors.white24,
              size: 20,
            ),
            tooltip: 'Eliminar opción',
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetonCard(int index) {
    final tarjeton = _tarjetones[index];
    final puedeEliminarTarjeton = _tarjetones.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: tarjeton.expandido,
          onExpansionChanged: (v) => tarjeton.expandido = v,
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          collapsedIconColor: Colors.white54,
          iconColor: Colors.white54,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[400]!.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 18,
                  color: Colors.blue[200],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: tarjeton.tituloCtrl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ej: Gobernación, Alcaldía, Cámara...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del tarjetón';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                onPressed: puedeEliminarTarjeton
                    ? () => _eliminarTarjeton(index)
                    : null,
                icon: Icon(
                  Icons.delete_outline,
                  color: puedeEliminarTarjeton
                      ? Colors.red[300]
                      : Colors.white24,
                  size: 20,
                ),
                tooltip: 'Eliminar tarjetón',
              ),
            ],
          ),
          children: [
            _buildModoSelector(tarjeton),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Opciones / candidatos',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(
              tarjeton.opciones.length,
              (i) => _buildOpcionRow(tarjeton, i),
            ),
            TextButton.icon(
              onPressed: () => _agregarOpcion(tarjeton),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar opción'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[300],
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fieldLabel('Tarjetones de la votación'),
            const Spacer(),
            Text(
              '${_tarjetones.length}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_tarjetones.length, (i) => _buildTarjetonCard(i)),
        OutlinedButton.icon(
          onPressed: _agregarTarjeton,
          icon: const Icon(Icons.add),
          label: const Text('Agregar tarjetón'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue[300],
            side: BorderSide(color: Colors.blue[400]!.withValues(alpha: 0.6)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  // ---------- Build principal ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Configurar Votación',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nueva votación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Define el periodo y los tarjetones que la componen',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 24),

                    _buildTituloField(),
                    const SizedBox(height: 16),

                    _buildFechasRow(),
                    const SizedBox(height: 24),

                    _buildTarjetonesSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: SizedBox(
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _guardar,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar votación',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
