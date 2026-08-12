import 'package:flutter/material.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({Key? key}) : super(key: key);

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  Map<String, dynamic>? _votante;
  final _txtMensaje = TextEditingController();
  String _destinatarios = 'individual'; // individual, votaron, noVotaron, todos
  bool _enviando = false;
  final List<Map<String, dynamic>> _historialMensajes = [
    {
      'id': 'M001',
      'destinatario': 'Juan Pérez',
      'mensaje': '¿Ha recibido información sobre la votación?',
      'fecha': '2026-08-10 10:30 AM',
      'estado': 'entregado',
    },
    {
      'id': 'M002',
      'destinatario': 'María García',
      'mensaje': 'Recordatorio: la votación finaliza hoy a las 6 PM',
      'fecha': '2026-08-10 02:15 PM',
      'estado': 'entregado',
    },
    {
      'id': 'M003',
      'destinatario': 'Carlos López',
      'mensaje': 'Aún falta su participación en la votación',
      'fecha': '2026-08-11 09:00 AM',
      'estado': 'pendiente',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _votante = args['votante'] as Map<String, dynamic>?;
      _destinatarios = 'individual';
    }
  }

  void _enviarMensaje() {
    if (_txtMensaje.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escriba un mensaje')),
      );
      return;
    }

    setState(() => _enviando = true);

    // Simular envío de mensaje
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _enviando = false);

        // Agregar a historial
        final nuevoMensaje = {
          'id': 'M${_historialMensajes.length + 1}',
          'destinatario': _destinatarios == 'individual'
              ? (_votante?['nombre'] ?? 'Votantes seleccionados')
              : 'Grupo: $_destinatarios',
          'mensaje': _txtMensaje.text,
          'fecha': DateTime.now().toString(),
          'estado': 'entregado',
        };

        _historialMensajes.insert(0, nuevoMensaje);
        _txtMensaje.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _destinatarios == 'individual'
                  ? 'Mensaje enviado a ${_votante?['nombre']}'
                  : 'Mensaje enviado a ${_historialMensajes.length} votantes',
            ),
            backgroundColor: Colors.green[400],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Mensaje'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Selector de destinatarios
            if (_votante == null)
              Container(
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enviar a:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'todos', label: Text('Todos')),
                        ButtonSegment(value: 'votaron', label: Text('Votaron')),
                        ButtonSegment(
                          value: 'noVotaron',
                          label: Text('No votaron'),
                        ),
                      ],
                      selected: {_destinatarios},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() => _destinatarios = newSelection.first);
                      },
                    ),
                  ],
                ),
              )
            else
              Container(
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: const Color(0xFF0F172A),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(
                      _votante!['nombre'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _votante!['email'] as String,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            // Formulario de mensaje
            Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mensaje:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _txtMensaje,
                    maxLines: 6,
                    minLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escriba su mensaje aquí...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _enviando ? null : _enviarMensaje,
                      icon: _enviando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(_enviando ? 'Enviando...' : 'Enviar Mensaje'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Historial de mensajes
            if (_historialMensajes.isNotEmpty)
              Container(
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de Mensajes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _historialMensajes.length,
                      itemBuilder: (context, index) {
                        final msg = _historialMensajes[index];
                        final estado = msg['estado'] as String;

                        return Card(
                          color: const Color(0xFF0F172A),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(
                              msg['destinatario'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  msg['fecha'] as String,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: estado == 'entregado'
                                        ? Colors.green[900]
                                        : Colors.orange[900],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    estado,
                                    style: TextStyle(
                                      color: estado == 'entregado'
                                          ? Colors.green[300]
                                          : Colors.orange[300],
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Mensaje:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      msg['mensaje'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _txtMensaje.dispose();
    super.dispose();
  }
}
