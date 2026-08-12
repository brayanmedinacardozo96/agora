import 'package:flutter/material.dart';

class VoterListScreen extends StatefulWidget {
  const VoterListScreen({Key? key}) : super(key: key);

  @override
  State<VoterListScreen> createState() => _VoterListScreenState();
}

class _VoterListScreenState extends State<VoterListScreen> {
  String _filtro = 'todos'; // todos, votaron, noVotaron
  late List<Map<String, dynamic>> _votantes;

  @override
  void initState() {
    super.initState();
    _votantes = [
      {
        'id': 'V001',
        'nombre': 'Juan Pérez',
        'cedula': '1234567890',
        'email': 'juan.perez@example.com',
        'hasVoted': true,
        'ubicacion': 'Mesa 1 - Sede Central',
        'horaVoto': '09:30 AM',
        'telefono': '+57 300 123 4567',
      },
      {
        'id': 'V002',
        'nombre': 'María García',
        'cedula': '0987654321',
        'email': 'maria.garcia@example.com',
        'hasVoted': true,
        'ubicacion': 'Mesa 2 - Sede Central',
        'horaVoto': '10:15 AM',
        'telefono': '+57 300 234 5678',
      },
      {
        'id': 'V003',
        'nombre': 'Carlos López',
        'cedula': '1122334455',
        'email': 'carlos.lopez@example.com',
        'hasVoted': false,
        'ubicacion': 'Mesa 1 - Sede Central',
        'horaVoto': null,
        'telefono': '+57 300 345 6789',
      },
      {
        'id': 'V004',
        'nombre': 'Ana Martínez',
        'cedula': '5566778899',
        'email': 'ana.martinez@example.com',
        'hasVoted': true,
        'ubicacion': 'Mesa 3 - Extensión',
        'horaVoto': '11:45 AM',
        'telefono': '+57 300 456 7890',
      },
      {
        'id': 'V005',
        'nombre': 'Pedro Rodríguez',
        'cedula': '9988776655',
        'email': 'pedro.rodriguez@example.com',
        'hasVoted': false,
        'ubicacion': 'Mesa 2 - Extensión',
        'horaVoto': null,
        'telefono': '+57 300 567 8901',
      },
      {
        'id': 'V006',
        'nombre': 'Laura Fernández',
        'cedula': '4433221100',
        'email': 'laura.fernandez@example.com',
        'hasVoted': true,
        'ubicacion': 'Mesa 1 - Sede Central',
        'horaVoto': '02:20 PM',
        'telefono': '+57 300 678 9012',
      },
      {
        'id': 'V007',
        'nombre': 'Roberto Sánchez',
        'cedula': '7744556633',
        'email': 'roberto.sanchez@example.com',
        'hasVoted': false,
        'ubicacion': 'Mesa 3 - Extensión',
        'horaVoto': null,
        'telefono': '+57 300 789 0123',
      },
      {
        'id': 'V008',
        'nombre': 'Sofía Ramírez',
        'cedula': '2255884466',
        'email': 'sofia.ramirez@example.com',
        'hasVoted': true,
        'ubicacion': 'Mesa 2 - Sede Central',
        'horaVoto': '03:05 PM',
        'telefono': '+57 300 890 1234',
      },
    ];
  }

  List<Map<String, dynamic>> get _votantesFiltrados {
    switch (_filtro) {
      case 'votaron':
        return _votantes.where((v) => v['hasVoted'] == true).toList();
      case 'noVotaron':
        return _votantes.where((v) => v['hasVoted'] == false).toList();
      default:
        return _votantes;
    }
  }

  int get _totalVotaron => _votantes.where((v) => v['hasVoted'] == true).length;
  int get _totalNoVotaron =>
      _votantes.where((v) => v['hasVoted'] == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Votantes'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          // Estadísticas
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_votantes.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text('Total', style: TextStyle(color: Colors.grey)),
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
                    const Text('Votaron', style: TextStyle(color: Colors.grey)),
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
                      'Falta votar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Filtros
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _filtro == 'todos',
                    onSelected: (selected) {
                      setState(() => _filtro = 'todos');
                    },
                    backgroundColor: const Color(0xFF0F172A),
                    selectedColor: Colors.blue[400],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Text('Votaron'),
                    selected: _filtro == 'votaron',
                    onSelected: (selected) {
                      setState(() => _filtro = 'votaron');
                    },
                    backgroundColor: const Color(0xFF0F172A),
                    selectedColor: Colors.green[400],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Text('No votaron'),
                    selected: _filtro == 'noVotaron',
                    onSelected: (selected) {
                      setState(() => _filtro = 'noVotaron');
                    },
                    backgroundColor: const Color(0xFF0F172A),
                    selectedColor: Colors.orange[400],
                  ),
                ),
              ],
            ),
          ),
          // Lista de votantes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: _votantesFiltrados.length,
              itemBuilder: (context, index) {
                final votante = _votantesFiltrados[index];
                final hasVoted = votante['hasVoted'] as bool;

                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: hasVoted
                            ? Colors.green[400]
                            : Colors.orange[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          hasVoted ? Icons.check_circle : Icons.schedule,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      votante['nombre'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Cédula: ${votante['cedula']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Email: ${votante['email']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Ubicación: ${votante['ubicacion']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (hasVoted)
                          Text(
                            'Votó: ${votante['horaVoto']}',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 12,
                            ),
                          )
                        else
                          Text(
                            'Aún no ha votado',
                            style: TextStyle(
                              color: Colors.orange[300],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      color: const Color(0xFF1E293B),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text(
                            'Ver detalles',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _mostrarDetallesVotante(votante);
                          },
                        ),
                        PopupMenuItem(
                          child: const Text(
                            'Enviar mensaje',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/send-message',
                              arguments: {'votante': votante},
                            );
                          },
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

  void _mostrarDetallesVotante(Map<String, dynamic> votante) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          votante['nombre'] as String,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detalleRow('ID:', votante['id']),
              _detalleRow('Cédula:', votante['cedula']),
              _detalleRow('Email:', votante['email']),
              _detalleRow('Teléfono:', votante['telefono']),
              _detalleRow('Ubicación:', votante['ubicacion']),
              _detalleRow(
                'Estado:',
                votante['hasVoted'] ? 'Votó ✓' : 'Pendiente',
              ),
              if (votante['hasVoted'])
                _detalleRow('Hora de voto:', votante['horaVoto']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
