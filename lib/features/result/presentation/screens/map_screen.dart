import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaResultadosApp extends StatelessWidget {
  const MapaResultadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MapaResultadosScreen();
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
  final List<OpcionInfo> opciones;
  const TarjetonInfo({
    required this.id,
    required this.nombre,
    required this.opciones,
  });
}

class MunicipioGeo {
  final String nombre;
  final LatLng coordenadas;
  const MunicipioGeo({required this.nombre, required this.coordenadas});
}

// Tarjetones de ejemplo, coherentes con las pantallas de configuración/votación.
const List<TarjetonInfo> _tarjetonesInfo = [
  TarjetonInfo(
    id: 'gobernacion',
    nombre: 'Gobernación',
    opciones: [
      OpcionInfo(id: 'g1', nombre: 'Ana Torres', color: Color(0xFF22C55E)),
      OpcionInfo(id: 'g2', nombre: 'Carlos Ruiz', color: Color(0xFF3B82F6)),
      OpcionInfo(id: 'g3', nombre: 'Marta Gómez', color: Color(0xFFF59E0B)),
    ],
  ),
  TarjetonInfo(
    id: 'alcaldia',
    nombre: 'Alcaldía',
    opciones: [
      OpcionInfo(id: 'a1', nombre: 'Luis Pérez', color: Color(0xFF22C55E)),
      OpcionInfo(id: 'a2', nombre: 'Sofía León', color: Color(0xFFA855F7)),
    ],
  ),
  TarjetonInfo(
    id: 'camara',
    nombre: 'Cámara',
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

// Municipios de ejemplo del departamento del Huila, Colombia.
// Coordenadas aproximadas — reemplaza por tus datos reales de geolocalización.
const List<MunicipioGeo> _municipiosHuila = [
  MunicipioGeo(nombre: 'Neiva', coordenadas: LatLng(2.9273, -75.2819)),
  MunicipioGeo(nombre: 'Pitalito', coordenadas: LatLng(1.8535, -76.0503)),
  MunicipioGeo(nombre: 'Garzón', coordenadas: LatLng(2.1975, -75.6285)),
  MunicipioGeo(nombre: 'La Plata', coordenadas: LatLng(2.3921, -75.8898)),
  MunicipioGeo(nombre: 'Campoalegre', coordenadas: LatLng(2.6892, -75.3236)),
  MunicipioGeo(nombre: 'Aipe', coordenadas: LatLng(3.2189, -75.2405)),
  MunicipioGeo(nombre: 'Palermo', coordenadas: LatLng(2.8956, -75.3801)),
  MunicipioGeo(nombre: 'Timaná', coordenadas: LatLng(1.9663, -75.9316)),
  MunicipioGeo(nombre: 'Gigante', coordenadas: LatLng(2.3789, -75.5417)),
  MunicipioGeo(nombre: 'Rivera', coordenadas: LatLng(2.7813, -75.2578)),
  MunicipioGeo(nombre: 'San Agustín', coordenadas: LatLng(1.8792, -76.2696)),
  MunicipioGeo(nombre: 'Algeciras', coordenadas: LatLng(2.5230, -75.3122)),
  MunicipioGeo(nombre: 'Yaguará', coordenadas: LatLng(2.6841, -75.5145)),
];

const LatLng _centroHuila = LatLng(2.55, -75.65);

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class MapaResultadosScreen extends StatefulWidget {
  const MapaResultadosScreen({super.key});

  @override
  State<MapaResultadosScreen> createState() => _MapaResultadosScreenState();
}

class _MapaResultadosScreenState extends State<MapaResultadosScreen> {
  final MapController _mapController = MapController();
  final Random _random = Random();

  String _tarjetonSeleccionado = _tarjetonesInfo.first.id;

  /// tarjetonId -> municipio -> opcionId -> votos
  final Map<String, Map<String, Map<String, int>>> _votos = {};

  DateTime _ultimaActualizacion = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generarVotosIniciales();
  }

  void _generarVotosIniciales() {
    for (final tarjeton in _tarjetonesInfo) {
      final porMunicipio = <String, Map<String, int>>{};
      for (final municipio in _municipiosHuila) {
        final porOpcion = <String, int>{};
        for (final opcion in tarjeton.opciones) {
          porOpcion[opcion.id] = 80 + _random.nextInt(1800);
        }
        porMunicipio[municipio.nombre] = porOpcion;
      }
      _votos[tarjeton.id] = porMunicipio;
    }
  }

  TarjetonInfo get _tarjetonActual =>
      _tarjetonesInfo.firstWhere((t) => t.id == _tarjetonSeleccionado);

  int _totalVotosMunicipio(String municipio) {
    final porOpcion = _votos[_tarjetonSeleccionado]?[municipio] ?? {};
    return porOpcion.values.fold(0, (a, b) => a + b);
  }

  int get _maxVotosMunicipio {
    final valores = _municipiosHuila.map((m) => _totalVotosMunicipio(m.nombre));
    return valores.isEmpty ? 1 : valores.reduce(max).clamp(1, 1 << 31);
  }

  int get _totalVotosDepartamento =>
      _municipiosHuila.fold(0, (a, m) => a + _totalVotosMunicipio(m.nombre));

  Color _colorPorIntensidad(double ratio) {
    if (ratio <= 0.5) {
      return Color.lerp(Colors.blue[400], Colors.orange[400], ratio * 2)!;
    }
    return Color.lerp(Colors.orange[400], Colors.red[400], (ratio - 0.5) * 2)!;
  }

  // ---------- Acciones ----------

  void _simularActualizacion() {
    setState(() {
      final porMunicipio = _votos[_tarjetonSeleccionado]!;
      for (final municipio in _municipiosHuila) {
        final porOpcion = porMunicipio[municipio.nombre]!;
        for (final opcionId in porOpcion.keys) {
          porOpcion[opcionId] = porOpcion[opcionId]! + _random.nextInt(120);
        }
      }
      _ultimaActualizacion = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text('Resultados actualizados'),
      ),
    );
  }

  void _irAMunicipio(MunicipioGeo municipio) {
    _mapController.move(municipio.coordenadas, 10);
    _mostrarDetalleMunicipio(municipio);
  }

  void _mostrarDetalleMunicipio(MunicipioGeo municipio) {
    final tarjeton = _tarjetonActual;
    final porOpcion = _votos[_tarjetonSeleccionado]?[municipio.nombre] ?? {};
    final total = porOpcion.values.fold(0, (a, b) => a + b);
    final entradas =
        tarjeton.opciones.map((o) => MapEntry(o, porOpcion[o.id] ?? 0)).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 20),
                const SizedBox(width: 6),
                Text(
                  municipio.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$total votos',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Tarjetón: ${tarjeton.nombre}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ...entradas.map((e) {
              final ratio = total == 0 ? 0.0 : e.value / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${e.value} (${(ratio * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: AlwaysStoppedAnimation(e.key.color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
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
              'Resultados por ubicación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              'Huila, Colombia · $_totalVotosDepartamento votos totales',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFiltroTarjetones(),
          Expanded(
            child: Stack(
              children: [
                _buildMapa(),
                Positioned(top: 12, left: 12, child: _buildLeyenda()),
              ],
            ),
          ),
          _buildPanelRanking(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simularActualizacion,
        backgroundColor: Colors.blue[400],
        icon: const Icon(Icons.refresh),
        label: const Text('Simular actualización'),
      ),
    );
  }

  Widget _buildFiltroTarjetones() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _tarjetonesInfo.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final tarjeton = _tarjetonesInfo[i];
            final selected = tarjeton.id == _tarjetonSeleccionado;
            return ChoiceChip(
              label: Text(tarjeton.nombre),
              selected: selected,
              onSelected: (_) =>
                  setState(() => _tarjetonSeleccionado = tarjeton.id),
              backgroundColor: const Color(0xFF1E293B),
              selectedColor: Colors.blue[400]!.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: selected ? Colors.blue[100] : Colors.white70,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
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
      ),
    );
  }

  Widget _buildMapa() {
    final maxVotos = _maxVotosMunicipio;

    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: _centroHuila,
        initialZoom: 8,
        minZoom: 6,
        maxZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.votaciones_app',
        ),
        MarkerLayer(
          markers: _municipiosHuila.map((municipio) {
            final total = _totalVotosMunicipio(municipio.nombre);
            final ratio = (total / maxVotos).clamp(0.05, 1.0);
            final size = 28 + (46 * ratio);
            final color = _colorPorIntensidad(ratio);

            return Marker(
              point: municipio.coordenadas,
              width: 90,
              height: 90,
              child: GestureDetector(
                onTap: () => _mostrarDetalleMunicipio(municipio),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: size, end: size),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) => Container(
                        width: value,
                        height: value,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.35),
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Container(
                          width: value * 0.4,
                          height: value * 0.4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        municipio.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLeyenda() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Volumen de votos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 110,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  Colors.blue[400]!,
                  Colors.orange[400]!,
                  Colors.red[400]!,
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menos',
                style: TextStyle(color: Colors.white38, fontSize: 9),
              ),
              Text('Más', style: TextStyle(color: Colors.white38, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanelRanking() {
    final municipiosOrdenados = [..._municipiosHuila]
      ..sort(
        (a, b) => _totalVotosMunicipio(
          b.nombre,
        ).compareTo(_totalVotosMunicipio(a.nombre)),
      );
    final maxVotos = _maxVotosMunicipio;

    return Container(
      constraints: const BoxConstraints(maxHeight: 190),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.leaderboard_outlined,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Ranking por municipio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Act. ${_ultimaActualizacion.hour.toString().padLeft(2, '0')}:${_ultimaActualizacion.minute.toString().padLeft(2, '0')}:${_ultimaActualizacion.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: municipiosOrdenados.length,
              itemBuilder: (context, i) {
                final municipio = municipiosOrdenados[i];
                final total = _totalVotosMunicipio(municipio.nombre);
                final ratio = maxVotos == 0 ? 0.0 : total / maxVotos;

                return InkWell(
                  onTap: () => _irAMunicipio(municipio),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 92,
                          child: Text(
                            municipio.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: ratio),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) =>
                                  LinearProgressIndicator(
                                    value: value,
                                    minHeight: 7,
                                    backgroundColor: const Color(0xFF334155),
                                    valueColor: AlwaysStoppedAnimation(
                                      _colorPorIntensidad(ratio),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 52,
                          child: Text(
                            '$total',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
