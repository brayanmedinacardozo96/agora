import 'package:agora/features/voting/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';

class VotoExitosoApp extends StatelessWidget {
  const VotoExitosoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VotoExitosoScreen(
        tituloVotacion: 'Elecciones Regionales 2026 - Huila',
        codigoConfirmacion: 'HUI-2026-84K2',
        fechaRegistro: DateTime.now(),
        resumen: const [
          ResumenVotoItem(
            tarjeton: 'Gobernación',
            seleccion: 'Ana Torres · Partido Verde',
            fotosAdjuntas: 1,
          ),
          ResumenVotoItem(
            tarjeton: 'Alcaldía',
            seleccion: 'Voto en blanco',
            esVotoBlanco: true,
          ),
          ResumenVotoItem(
            tarjeton: 'Cámara',
            seleccion: 'Partido Azul',
            fotosAdjuntas: 2,
          ),
        ],
        onEmitirOtroVoto: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistroUsuarioScreen(),
          ),
        ),
        onIrAlInicio: () => Navigator.pushNamed(context, '/home'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modelo del resumen (lo llenas con lo que el usuario seleccionó en VotarScreen)
// ---------------------------------------------------------------------------

class ResumenVotoItem {
  final String tarjeton;
  final String seleccion;
  final bool esVotoBlanco;
  final int fotosAdjuntas;

  const ResumenVotoItem({
    required this.tarjeton,
    required this.seleccion,
    this.esVotoBlanco = false,
    this.fotosAdjuntas = 0,
  });
}

// ---------------------------------------------------------------------------
// Pantalla de confirmación exitosa
// ---------------------------------------------------------------------------

class VotoExitosoScreen extends StatefulWidget {
  final String tituloVotacion;
  final String codigoConfirmacion;
  final DateTime fechaRegistro;
  final List<ResumenVotoItem> resumen;
  final VoidCallback onEmitirOtroVoto;
  final VoidCallback onIrAlInicio;

  const VotoExitosoScreen({
    super.key,
    required this.tituloVotacion,
    required this.codigoConfirmacion,
    required this.fechaRegistro,
    required this.resumen,
    required this.onEmitirOtroVoto,
    required this.onIrAlInicio,
  });

  @override
  State<VotoExitosoScreen> createState() => _VotoExitosoScreenState();
}

class _VotoExitosoScreenState extends State<VotoExitosoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _escala;
  late final Animation<double> _opacidad;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _escala = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacidad = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.4, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatearHora(DateTime fecha) =>
      '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')} · '
      '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Evita que el botón "atrás" del sistema regrese a las páginas de
      // selección una vez el voto ya quedó registrado.
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIconoExito(),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _opacidad,
                            child: Column(
                              children: [
                                const Text(
                                  '¡Voto registrado con éxito!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Tu voto se guardó de forma segura y anónima.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCodigoConfirmacion(),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.tituloVotacion,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...widget.resumen.map(_buildResumenCard),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildBotonesInferiores(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconoExito() {
    return Center(
      child: ScaleTransition(
        scale: _escala,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.green[400]!.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green[400]!, width: 2),
          ),
          child: Icon(Icons.check_rounded, color: Colors.green[400], size: 44),
        ),
      ),
    );
  }

  Widget _buildCodigoConfirmacion() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.white54,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Código de confirmación',
                  style: TextStyle(color: Colors.white38, fontSize: 10.5),
                ),
                Text(
                  widget.codigoConfirmacion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatearHora(widget.fechaRegistro),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard(ResumenVotoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Icon(
              item.esVotoBlanco ? Icons.block_outlined : Icons.check_circle,
              color: item.esVotoBlanco ? Colors.white38 : Colors.green[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tarjeton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.seleccion,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            if (item.fotosAdjuntas > 0)
              Row(
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 13,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${item.fotosAdjuntas}',
                    style: const TextStyle(color: Colors.blue, fontSize: 11.5),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesInferiores() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onIrAlInicio,
              child: const Text('Ir al inicio', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Color(0xFF334155)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onEmitirOtroVoto,
              child: const Text(
                'Emitir otro voto',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
