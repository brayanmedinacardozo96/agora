import 'package:flutter/material.dart';

class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({super.key});

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  // Datos quemados de encuestas
  final List<Map<String, dynamic>> surveys = [
    {
      'id': '1',
      'title': 'Intención de Voto 2024',
      'description': '¿Por quién votarías en las próximas elecciones?',
      'type': 'Votación',
      'status': 'Activa',
      'questions': 3,
      'responses': 245,
    },
    {
      'id': '2',
      'title': 'Opinión sobre Políticas de Seguridad',
      'description':
          'Tu parecer sobre las políticas de seguridad implementadas',
      'type': 'Opinión',
      'status': 'Activa',
      'questions': 3,
      'responses': 189,
    },
    {
      'id': '3',
      'title': 'Encuesta Demográfica',
      'description': 'Información demográfica para análisis electoral',
      'type': 'Demográfica',
      'status': 'Borrador',
      'questions': 2,
      'responses': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuestas'),
        centerTitle: true,
        elevation: 0,
      ),
      body: surveys.isEmpty
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
                    'No hay encuestas disponibles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: surveys.length,
              itemBuilder: (context, index) {
                final survey = surveys[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(survey['title']),
                    subtitle: Text(survey['description']),
                    trailing: Chip(
                      label: Text(survey['status']),
                      backgroundColor: survey['status'] == 'Activa'
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/survey-detail',
                        arguments: survey,
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-survey');
        },
        tooltip: 'Nueva Encuesta',
        child: const Icon(Icons.add),
      ),
    );
  }
}
