import 'package:flutter/material.dart';

class SurveyResponsesScreen extends StatefulWidget {
  final Map<String, dynamic> survey;

  const SurveyResponsesScreen({super.key, required this.survey});

  @override
  State<SurveyResponsesScreen> createState() => _SurveyResponsesScreenState();
}

class _SurveyResponsesScreenState extends State<SurveyResponsesScreen> {
  // Datos de respuestas quemadas
  final List<Map<String, dynamic>> _responses = [
    {
      'id': '1',
      'responderId': 'resp_001',
      'location': 'Calle 5 con Carrera 10, Bogotá',
      'date': '2024-01-15 14:30',
      'answers': [
        {'question': '¿Por cuál candidato votarías?', 'answer': 'Candidato A'},
        {
          'question': '¿Cuál es tu principal razón de voto?',
          'answer': 'Porque confío en su propuesta económica',
        },
        {'question': '¿Confías en el proceso electoral?', 'answer': 'Sí'},
      ],
    },
    {
      'id': '2',
      'responderId': 'resp_002',
      'location': 'Avenida Paseo, Medellín',
      'date': '2024-01-15 15:45',
      'answers': [
        {'question': '¿Por cuál candidato votarías?', 'answer': 'Candidato B'},
        {
          'question': '¿Cuál es tu principal razón de voto?',
          'answer': 'Por su experiencia en el sector',
        },
        {'question': '¿Confías en el proceso electoral?', 'answer': 'Sí'},
      ],
    },
    {
      'id': '3',
      'responderId': 'resp_003',
      'location': 'Calle 72 con Carrera 7, Bogotá',
      'date': '2024-01-15 16:20',
      'answers': [
        {'question': '¿Por cuál candidato votarías?', 'answer': 'Candidato C'},
        {
          'question': '¿Cuál es tu principal razón de voto?',
          'answer': 'Propuestas innovadoras',
        },
        {'question': '¿Confías en el proceso electoral?', 'answer': 'No'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respuestas de la Encuesta'),
        centerTitle: true,
      ),
      body: _responses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay respuestas disponibles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _responses.length,
              itemBuilder: (context, index) {
                final response = _responses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    title: Text('Respuesta #${index + 1}'),
                    subtitle: Text('Ubicación: ${response['location']}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del Encuestador',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text('ID: ${response['responderId']}'),
                            Text('Fecha: ${response['date']}'),
                            Text('Ubicación: ${response['location']}'),
                            const SizedBox(height: 16),
                            Text(
                              'Respuestas',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ...response['answers']
                                .map(
                                  (answer) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'P: ${answer['question']}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'R: ${answer['answer']}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
