import 'package:flutter/material.dart';

class VotingStatsScreen extends StatefulWidget {
  const VotingStatsScreen({Key? key}) : super(key: key);

  @override
  State<VotingStatsScreen> createState() => _VotingStatsScreenState();
}

class _VotingStatsScreenState extends State<VotingStatsScreen> {
  final List<Map<String, dynamic>> _ubicaciones = [
    {
      'nombre': 'Mesa 1 - Sede Central',
      'total': 3,
      'votaron': 2,
      'noVotaron': 1,
    },
    {
      'nombre': 'Mesa 2 - Sede Central',
      'total': 3,
      'votaron': 2,
      'noVotaron': 1,
    },
    {'nombre': 'Mesa 3 - Extensión', 'total': 2, 'votaron': 1, 'noVotaron': 1},
    {'nombre': 'Mesa 2 - Extensión', 'total': 1, 'votaron': 0, 'noVotaron': 1},
  ];

  int get _totalVotantes =>
      _ubicaciones.fold(0, (sum, u) => sum + (u['total'] as int));
  int get _totalVotaron =>
      _ubicaciones.fold(0, (sum, u) => sum + (u['votaron'] as int));
  int get _totalNoVotaron =>
      _ubicaciones.fold(0, (sum, u) => sum + (u['noVotaron'] as int));

  double get _porcentajeVotacion => (_totalVotaron / _totalVotantes) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Votación'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta principal de progreso
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Participación General',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: _porcentajeVotacion / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation(Colors.green[400]),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${_porcentajeVotacion.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'han votado',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Estadísticas en fila
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$_totalVotantes',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Total Votantes',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$_totalVotaron',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[300],
                            ),
                          ),
                          const Text(
                            'Votaron',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$_totalNoVotaron',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[300],
                            ),
                          ),
                          const Text(
                            'Pendientes',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Estadísticas por ubicación
            const Text(
              'Participación por Ubicación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ubicaciones.length,
              itemBuilder: (context, index) {
                final ubicacion = _ubicaciones[index];
                final porcentaje =
                    (ubicacion['votaron'] as int) /
                    (ubicacion['total'] as int) *
                    100;

                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ubicacion['nombre'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Barra de progreso
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: porcentaje / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation(
                              porcentaje == 100
                                  ? Colors.green[400]
                                  : Colors.blue[400],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Estadísticas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${ubicacion['votaron']}/${ubicacion['total']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${porcentaje.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Chip(
                              label: Text(
                                '${ubicacion['noVotaron']} pendientes',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              backgroundColor: Colors.orange[900],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Acciones rápidas
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/voter-list');
                },
                icon: const Icon(Icons.people),
                label: const Text('Ver Lista de Votantes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[600],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/send-message');
                },
                icon: const Icon(Icons.mail_outline),
                label: const Text('Enviar Mensaje a Votantes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
