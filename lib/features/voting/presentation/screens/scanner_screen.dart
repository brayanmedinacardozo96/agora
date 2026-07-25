import 'dart:convert';

import 'package:agora/features/voting/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CedulaScannerApp extends StatelessWidget {
  const CedulaScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CedulaScannerScreen();
  }
}

// ---------------------------------------------------------------------------
// Modelo de datos extraídos del PDF417
// ---------------------------------------------------------------------------

class CedulaData {
  String numeroDocumento;
  String primerApellido;
  String segundoApellido;
  String primerNombre;
  String segundoNombre;
  String fechaNacimiento;
  String sexo;
  final String textoCrudo;
  final List<String> segmentos;

  CedulaData({
    this.numeroDocumento = '',
    this.primerApellido = '',
    this.segundoApellido = '',
    this.primerNombre = '',
    this.segundoNombre = '',
    this.fechaNacimiento = '',
    this.sexo = '',
    this.textoCrudo = '',
    this.segmentos = const [],
  });
}

// ---------------------------------------------------------------------------
// Parser del contenido del PDF417
// ---------------------------------------------------------------------------
//
// IMPORTANTE: la Registraduría Nacional no publica una especificación
// oficial del contenido del PDF417 de la cédula colombiana, y el formato
// puede variar según la versión del documento (cédula amarilla antigua,
// cédula con hologramas reciente, etc.). Esta función hace un "mejor
// esfuerzo" separando el texto crudo en segmentos y ubicándolos en el
// orden que reportan la mayoría de implementaciones de referencia
// (apellidos, nombres y número de documento primero). SIEMPRE valida y
// ajusta el mapeo de índices contra cédulas reales antes de confiar en
// los datos — por eso la pantalla de confirmación permite editar todo
// antes de aceptarlo.
CedulaData parsearCedula(String textoCrudo) {
  // Los datos suelen venir separados por caracteres de control no imprimibles.
  var segmentos = textoCrudo
      .split(RegExp(r'[\x00-\x1F]+'))
      .where((s) => s.trim().isNotEmpty)
      .toList();

  // Si no hubo separadores de control, se intenta con saltos de línea normales.
  if (segmentos.length < 3) {
    segmentos = textoCrudo
        .split(RegExp(r'[\r\n]+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  String campo(int index) =>
      index < segmentos.length ? segmentos[index].trim() : '';

  return CedulaData(
    // Orden más común reportado por implementaciones de referencia.
    // Ajusta estos índices según lo que observes en tus pruebas reales.
    primerApellido: campo(0),
    segundoApellido: campo(1),
    primerNombre: campo(2),
    segundoNombre: campo(3),
    numeroDocumento: campo(4),
    sexo: campo(5),
    fechaNacimiento: campo(6),
    textoCrudo: textoCrudo,
    segmentos: segmentos,
  );
}

// ---------------------------------------------------------------------------
// Pantalla de escaneo
// ---------------------------------------------------------------------------

class CedulaScannerScreen extends StatefulWidget {
  const CedulaScannerScreen({super.key});

  @override
  State<CedulaScannerScreen> createState() => _CedulaScannerScreenState();
}

class _CedulaScannerScreenState extends State<CedulaScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.pdf417],
    // "normal" sigue analizando cada frame; el PDF417 es denso y suele
    // necesitar varios intentos hasta que el enfoque/distancia sean buenos.
    detectionSpeed: DetectionSpeed.normal,
    // Resolución alta: un PDF417 tiene muchas filas delgadas y con poca
    // resolución la cámara no alcanza a distinguirlas.
    cameraResolution: const Size(1920, 1080),
  );

  bool _procesando = false;
  bool _flashActivo = false;
  double _zoom = 0.0;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- Manejo de detección ----------

  void _onDetect(BarcodeCapture captura) {
    if (_procesando) return;
    if (captura.barcodes.isEmpty) return;

    final codigo = captura.barcodes.first;

    // El PDF417 de la cédula suele usar codificación Latin-1 (ISO-8859-1).
    // Si se decodifica como UTF-8 los caracteres con tildes/ñ quedan mal.
    String textoCrudo;
    if (codigo.rawBytes != null && codigo.rawBytes!.isNotEmpty) {
      try {
        textoCrudo = latin1.decode(codigo.rawBytes!);
      } catch (_) {
        textoCrudo = codigo.rawValue ?? '';
      }
    } else {
      textoCrudo = codigo.rawValue ?? '';
    }

    if (textoCrudo.trim().isEmpty) return;

    setState(() => _procesando = true);
    _controller.stop();

    final datos = parsearCedula(textoCrudo);
    _abrirConfirmacion(datos);
  }

  Future<void> _abrirConfirmacion(CedulaData datos) async {
    final resultado = await Navigator.push<CedulaData>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmarDatosCedulaScreen(datosIniciales: datos),
      ),
    );

    if (!mounted) return;

    if (resultado != null) {
      // Ya se confirmaron/editaron los datos: aquí normalmente harías
      // Navigator.pop(context, resultado) para devolverlos a quien llamó
      // a esta pantalla, o los usarías para prellenar tu formulario de
      // registro de votante.
      Navigator.pop(context, resultado);
    } else {
      // El usuario canceló la confirmación: se reanuda el escaneo.
      setState(() {
        _procesando = false;
        _error = null;
      });
      _controller.start();
    }
  }

  void _irAIngresoManual() async {
    final resultado = await Navigator.push<CedulaData>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmarDatosCedulaScreen(
          datosIniciales: CedulaData(),
          esIngresoManual: true,
        ),
      ),
    );
    if (!mounted) return;
    if (resultado != null) Navigator.pop(context, resultado);
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Escanear cédula (PDF417)'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() => _flashActivo = !_flashActivo);
            },
            icon: Icon(_flashActivo ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          _buildOverlayGuia(),
          _buildControlZoom(),
          _buildInstrucciones(),
          if (_procesando) _buildOverlayCargando(),
        ],
      ),
    );
  }

  Widget _buildControlZoom() {
    return Positioned(
      right: 12,
      top: 100,
      bottom: 140,
      child: RotatedBox(
        quarterTurns: 3,
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue[400],
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.blue[400],
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: _zoom,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              setState(() => _zoom = value);
              _controller.setZoomScale(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayGuia() {
    return Center(
      child: AspectRatio(
        // El PDF417 de la cédula es un rectángulo ancho y bajo.
        aspectRatio: 2.2,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[400]!, width: 2.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildInstrucciones() {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Acerca la cámara al código PDF417 del reverso (a unos 10-15 cm), '
              'evita reflejos y sostenla firme unos segundos. Usa el control '
              'lateral para hacer zoom si el código se ve muy pequeño.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _irAIngresoManual,
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            icon: const Icon(Icons.keyboard_outlined, size: 18),
            label: const Text('No se puede leer, ingresar manualmente'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayCargando() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 12),
            Text(
              'Código detectado, procesando...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pantalla de confirmación / edición de los datos extraídos
// ---------------------------------------------------------------------------

class ConfirmarDatosCedulaScreen extends StatefulWidget {
  final CedulaData datosIniciales;
  final bool esIngresoManual;

  const ConfirmarDatosCedulaScreen({
    super.key,
    required this.datosIniciales,
    this.esIngresoManual = false,
  });

  @override
  State<ConfirmarDatosCedulaScreen> createState() =>
      _ConfirmarDatosCedulaScreenState();
}

class _ConfirmarDatosCedulaScreenState
    extends State<ConfirmarDatosCedulaScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _documentoCtrl;
  late final TextEditingController _apellido1Ctrl;
  late final TextEditingController _apellido2Ctrl;
  late final TextEditingController _nombre1Ctrl;
  late final TextEditingController _nombre2Ctrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _sexoCtrl;

  bool _verTextoCrudo = false;

  @override
  void initState() {
    super.initState();
    final d = widget.datosIniciales;
    _documentoCtrl = TextEditingController(text: d.numeroDocumento);
    _apellido1Ctrl = TextEditingController(text: d.primerApellido);
    _apellido2Ctrl = TextEditingController(text: d.segundoApellido);
    _nombre1Ctrl = TextEditingController(text: d.primerNombre);
    _nombre2Ctrl = TextEditingController(text: d.segundoNombre);
    _fechaCtrl = TextEditingController(text: d.fechaNacimiento);
    _sexoCtrl = TextEditingController(text: d.sexo);
  }

  @override
  void dispose() {
    _documentoCtrl.dispose();
    _apellido1Ctrl.dispose();
    _apellido2Ctrl.dispose();
    _nombre1Ctrl.dispose();
    _nombre2Ctrl.dispose();
    _fechaCtrl.dispose();
    _sexoCtrl.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final datos = CedulaData(
      numeroDocumento: _documentoCtrl.text.trim(),
      primerApellido: _apellido1Ctrl.text.trim(),
      segundoApellido: _apellido2Ctrl.text.trim(),
      primerNombre: _nombre1Ctrl.text.trim(),
      segundoNombre: _nombre2Ctrl.text.trim(),
      fechaNacimiento: _fechaCtrl.text.trim(),
      sexo: _sexoCtrl.text.trim(),
      textoCrudo: widget.datosIniciales.textoCrudo,
      segmentos: widget.datosIniciales.segmentos,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroUsuarioScreen()),
    );
  }

  InputDecoration _decoracion(String hint, IconData icono) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icono, color: Colors.white54),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          widget.esIngresoManual
              ? 'Ingresar datos manualmente'
              : 'Confirmar datos leídos',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.esIngresoManual) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[400]!.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.orange[400]!.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange[300],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Verifica que los datos coincidan con el documento '
                                'antes de continuar. Puedes corregir cualquier campo.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    _campo(
                      'Número de documento',
                      _documentoCtrl,
                      Icons.badge_outlined,
                      TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      'Primer apellido',
                      _apellido1Ctrl,
                      Icons.person_outline,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      'Segundo apellido',
                      _apellido2Ctrl,
                      Icons.person_outline,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      'Primer nombre',
                      _nombre1Ctrl,
                      Icons.badge_outlined,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      'Segundo nombre',
                      _nombre2Ctrl,
                      Icons.badge_outlined,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      'Fecha de nacimiento',
                      _fechaCtrl,
                      Icons.calendar_today_outlined,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      'Sexo',
                      _sexoCtrl,
                      Icons.wc_outlined,
                      TextInputType.text,
                    ),
                    if (!widget.esIngresoManual &&
                        widget.datosIniciales.textoCrudo.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _verTextoCrudo = !_verTextoCrudo),
                        icon: Icon(
                          _verTextoCrudo
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        label: Text(
                          _verTextoCrudo
                              ? 'Ocultar texto crudo del PDF417'
                              : 'Ver texto crudo del PDF417',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue[300],
                        ),
                      ),
                      if (_verTextoCrudo)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: SelectableText(
                            widget.datosIniciales.segmentos.isNotEmpty
                                ? widget.datosIniciales.segmentos
                                      .asMap()
                                      .entries
                                      .map((e) => '[${e.key}] ${e.value}')
                                      .join('\n')
                                : widget.datosIniciales.textoCrudo,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _confirmar,
                        child: const Text(
                          'Confirmar datos',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller,
    IconData icono,
    TextInputType tipoTeclado,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: tipoTeclado,
          decoration: _decoracion(label, icono),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }
}
