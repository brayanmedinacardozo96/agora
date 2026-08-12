import 'package:flutter/material.dart';

class FieldworkScreen extends StatefulWidget {
  final Map<String, dynamic> survey;

  const FieldworkScreen({super.key, required this.survey});

  @override
  State<FieldworkScreen> createState() => _FieldworkScreenState();
}

class _FieldworkScreenState extends State<FieldworkScreen> {
  late PageController _pageController;
  int _currentQuestionIndex = 0;

  final List<Map<String, String>> _questions = [
    {'question': '¿Por cuál candidato votarías?', 'type': 'multiple'},
    {'question': '¿Cuál es tu principal razón de voto?', 'type': 'text'},
    {'question': '¿Confías en el proceso electoral?', 'type': 'yesno'},
  ];

  final Map<int, String> _answers = {};
  String _location = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diligenciar Encuesta'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / _questions.length * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['question']!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        _buildQuestionWidget(index, question['type']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: const Text('Anterior'),
                ),
                ElevatedButton(
                  onPressed: _currentQuestionIndex < _questions.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () {
                          _submitResponse();
                        },
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? 'Siguiente'
                        : 'Enviar',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(int index, String type) {
    switch (type) {
      case 'multiple':
        return Column(
          children: ['Candidato A', 'Candidato B', 'Candidato C']
              .map(
                (option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _answers[index],
                  onChanged: (value) {
                    setState(() {
                      _answers[index] = value!;
                    });
                  },
                ),
              )
              .toList(),
        );
      case 'text':
        return TextFormField(
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
          onChanged: (value) {
            _answers[index] = value;
          },
        );
      case 'yesno':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _answers[index] = 'Sí';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answers[index] == 'Sí'
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
                child: const Text('Sí'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _answers[index] = 'No';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answers[index] == 'No'
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
                child: const Text('No'),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _submitResponse() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubicación del encuestador'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Ubicación',
            hintText: 'Ej: Calle 10 con Carrera 5',
          ),
          onChanged: (value) {
            _location = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Encuesta completada exitosamente!'),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
