import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DashboardResultadosApp extends StatelessWidget {
  const DashboardResultadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardResultadosScreen();
  }
}

// ---------------------------------------------------------------------------
// Modelos de datos usados solo por la UI (datos de ejemplo, sin backend)
// ---------------------------------------------------------------------------

class OpcionInfo {
  final String id;
  final String nombre;
  final Color color;
  const OpcionInfo({
    required this.id,
    required this.nombre,
    required this.color,
  });
}

class TarjetonInfo {
  final String id;
  final String nombre;
  final IconData icono;
  final List<OpcionInfo> opciones;
  const TarjetonInfo({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.opciones,
  });
}

const List<TarjetonInfo> _tarjetonesInfo = [
  TarjetonInfo(
    id: 'gobernacion',
    nombre: 'Gobernación',
    icono: Icons.account_balance_outlined,
    opciones: [
      OpcionInfo(id: 'g1', nombre: 'Ana Torres', color: Color(0xFF22C55E)),
      OpcionInfo(id: 'g2', nombre: 'Carlos Ruiz', color: Color(0xFF3B82F6)),
      OpcionInfo(id: 'g3', nombre: 'Marta Gómez', color: Color(0xFFF59E0B)),
    ],
  ),
  TarjetonInfo(
    id: 'alcaldia',
    nombre: 'Alcaldía',
    icono: Icons.location_city_outlined,
    opciones: [
      OpcionInfo(id: 'a1', nombre: 'Luis Pérez', color: Color(0xFF22C55E)),
      OpcionInfo(id: 'a2', nombre: 'Sofía León', color: Color(0xFFA855F7)),
    ],
  ),
  TarjetonInfo(
    id: 'camara',
    nombre: 'Cámara',
    icono: Icons.groups_outlined,
    opciones: [
      OpcionInfo(id: 'c1', nombre: 'Partido Verde', color: Color(0xFF22C55E)),
      OpcionInfo(id: 'c2', nombre: 'Partido Azul', color: Color(0xFF3B82F6)),
      OpcionInfo(
        id: 'c3',
        nombre: 'Movimiento Cívico',
        color: Color(0xFFF59E0B),
      ),
    ],
  ),
];

const int _totalMesas = 420;
const int _totalMunicipios = 13;

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class DashboardResultadosScreen extends StatefulWidget {
  const DashboardResultadosScreen({super.key});

  @override
  State<DashboardResultadosScreen> createState() =>
      _DashboardResultadosScreenState();
}

class _DashboardResultadosScreenState extends State<DashboardResultadosScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();

  /// tarjetonId -> opcionId -> votos
  final Map<String, Map<String, int>> _votos = {};

  /// tarjetonId -> opcionId -> incremento desde la última actualización
  final Map<String, Map<String, int>> _delta = {};

  String _tarjetonDestacado = _tarjetonesInfo.first.id;
  int _mesasEscrutadas = 268;
  DateTime _ultimaActualizacion = DateTime.now();

  late final AnimationController _pulsoController;

  final List<String> _titulares = [
    '🔴 EN VIVO: siguiendo el escrutinio departamental',
    '📊 Participación departamental supera el 60%',
    '📍 Municipios reportando resultados parciales',
    '🗳️ El escrutinio avanza sin novedades hasta el momento',
  ];
  int _titularIndex = 0;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _generarVotosIniciales();

    _pulsoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _tickerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() => _titularIndex = (_titularIndex + 1) % _titulares.length);
    });
  }

  @override
  void dispose() {
    _pulsoController.dispose();
    _tickerTimer?.cancel();
    super.dispose();
  }

  void _generarVotosIniciales() {
    for (final tarjeton in _tarjetonesInfo) {
      final porOpcion = <String, int>{};
      for (final opcion in tarjeton.opciones) {
        porOpcion[opcion.id] = 500 + _random.nextInt(9000);
      }
      _votos[tarjeton.id] = porOpcion;
      _delta[tarjeton.id] = {for (final o in tarjeton.opciones) o.id: 0};
    }
  }

  // ---------- Cálculos ----------

  int _totalVotos(String tarjetonId) =>
      _votos[tarjetonId]!.values.fold(0, (a, b) => a + b);

  double _participacion() => (_mesasEscrutadas / _totalMesas).clamp(0.0, 1.0);

  List<MapEntry<OpcionInfo, int>> _rankingOpciones(TarjetonInfo tarjeton) {
    final entradas =
        tarjeton.opciones
            .map((o) => MapEntry(o, _votos[tarjeton.id]![o.id]!))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return entradas;
  }

  // ---------- Acciones ----------

  void _simularActualizacion() {
    setState(() {
      for (final tarjeton in _tarjetonesInfo) {
        final porOpcion = _votos[tarjeton.id]!;
        final deltaOpcion = _delta[tarjeton.id]!;
        for (final opcion in tarjeton.opciones) {
          final incremento = _random.nextInt(400);
          porOpcion[opcion.id] = porOpcion[opcion.id]! + incremento;
          deltaOpcion[opcion.id] = incremento;
        }
      }
      _mesasEscrutadas = (_mesasEscrutadas + 5 + _random.nextInt(15)).clamp(
        0,
        _totalMesas,
      );
      _ultimaActualizacion = DateTime.now();

      final destacado = _tarjetonesInfo.firstWhere(
        (t) => t.id == _tarjetonDestacado,
      );
      final lider = _rankingOpciones(destacado).first;
      _titulares[0] =
          '📈 ÚLTIMA HORA: ${lider.key.nombre} amplía su ventaja en ${destacado.nombre}';
      _titularIndex = 0;
    });
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: Column(
          children: [
            _buildBarraEnVivo(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEncabezado(),
                    const SizedBox(height: 18),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    _buildSelectorTarjetones(),
                    const SizedBox(height: 14),
                    _buildTarjetonDestacadoCard(),
                    const SizedBox(height: 20),
                    const Text(
                      'Resumen de todos los tarjetones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._tarjetonesInfo.map(_buildTarjetonResumenCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simularActualizacion,
        backgroundColor: const Color(0xFFDC2626),
        icon: const Icon(Icons.bolt),
        label: const Text('Simular actualización'),
      ),
    );
  }

  // ---------- Barra "EN VIVO" con ticker de noticias ----------

  Widget _buildBarraEnVivo() {
    return Container(
      color: const Color(0xFFDC2626),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.35, end: 1.0).animate(_pulsoController),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'EN VIVO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 14, color: Colors.white38),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.6),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  _titulares[_titularIndex],
                  key: ValueKey(_titulares[_titularIndex]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elecciones Regionales 2026',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Huila, Colombia · Actualizado hace instantes '
          '(${_ultimaActualizacion.hour.toString().padLeft(2, '0')}:'
          '${_ultimaActualizacion.minute.toString().padLeft(2, '0')}:'
          '${_ultimaActualizacion.second.toString().padLeft(2, '0')})',
          style: const TextStyle(color: Colors.white54, fontSize: 12.5),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final totalVotosGeneral = _tarjetonesInfo.fold(
      0,
      (a, t) => a + _totalVotos(t.id),
    );
    final participacion = _participacion();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icono: Icons.how_to_vote_outlined,
            valor: '$totalVotosGeneral',
            etiqueta: 'Votos totales',
            color: Colors.blue[400]!,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icono: Icons.percent_rounded,
            valor: '${(participacion * 100).toStringAsFixed(1)}%',
            etiqueta: 'Participación',
            color: Colors.orange[400]!,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icono: Icons.fact_check_outlined,
            valor: '$_mesasEscrutadas/$_totalMesas',
            etiqueta: 'Mesas escrutadas',
            color: Colors.green[400]!,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icono,
    required String valor,
    required String etiqueta,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTarjetones() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tarjetonesInfo.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tarjeton = _tarjetonesInfo[i];
          final selected = tarjeton.id == _tarjetonDestacado;
          return ChoiceChip(
            label: Text(tarjeton.nombre),
            selected: selected,
            onSelected: (_) => setState(() => _tarjetonDestacado = tarjeton.id),
            avatar: Icon(
              tarjeton.icono,
              size: 16,
              color: selected ? Colors.blue[100] : Colors.white54,
            ),
            backgroundColor: const Color(0xFF1E293B),
            selectedColor: Colors.blue[400]!.withValues(alpha: 0.25),
            labelStyle: TextStyle(
              color: selected ? Colors.blue[100] : Colors.white70,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12.5,
            ),
            side: BorderSide(
              color: selected ? Colors.blue[400]! : const Color(0xFF334155),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  // ---------- Tarjetón destacado (estilo "última hora") ----------

  Widget _buildTarjetonDestacadoCard() {
    final tarjeton = _tarjetonesInfo.firstWhere(
      (t) => t.id == _tarjetonDestacado,
    );
    final ranking = _rankingOpciones(tarjeton);
    final lider = ranking.first;
    final total = _totalVotos(tarjeton.id);
    final porcentajeLider = total == 0 ? 0.0 : lider.value / total;
    final deltaLider = _delta[tarjeton.id]?[lider.key.id] ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lider.key.color.withValues(alpha: 0.18),
            const Color(0xFF1E293B),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lider.key.color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: lider.key.color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LÍDER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tarjeton.nombre,
                style: const TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lider.key.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(porcentajeLider * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: lider.key.color,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${lider.value} votos',
                style: const TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
              if (deltaLider > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[400]!.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 11,
                        color: Colors.green[400],
                      ),
                      Text(
                        ' +$deltaLider',
                        style: TextStyle(
                          color: Colors.green[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...ranking.skip(1).map((entrada) {
            final ratio = total == 0 ? 0.0 : entrada.value / total;
            final delta = _delta[tarjeton.id]?[entrada.key.id] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entrada.key.nombre,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      if (delta > 0)
                        Text(
                          '+$delta  ',
                          style: TextStyle(
                            color: Colors.green[400]!,
                            fontSize: 11,
                          ),
                        ),
                      Text(
                        '${(ratio * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF334155),
                      valueColor: AlwaysStoppedAnimation(entrada.key.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------- Tarjeta resumen por tarjetón ----------

  Widget _buildTarjetonResumenCard(TarjetonInfo tarjeton) {
    final ranking = _rankingOpciones(tarjeton);
    final lider = ranking.first;
    final total = _totalVotos(tarjeton.id);
    final ratio = total == 0 ? 0.0 : lider.value / total;
    final destacado = tarjeton.id == _tarjetonDestacado;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _tarjetonDestacado = tarjeton.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: destacado ? Colors.blue[400]! : const Color(0xFF334155),
              width: destacado ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lider.key.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tarjeton.icono, color: lider.key.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarjeton.nombre,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lider.key.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: AlwaysStoppedAnimation(lider.key.color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(ratio * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: lider.key.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
