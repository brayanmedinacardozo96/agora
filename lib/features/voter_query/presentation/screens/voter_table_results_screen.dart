import 'package:agora/features/voter_query/data/models/voter_model.dart';
import 'package:agora/features/voter_query/data/voter_sample_data.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Pantalla de resultados agrupados por mesa y lugar de votación
// ---------------------------------------------------------------------------

class VoterTableResultsApp extends StatelessWidget {
  const VoterTableResultsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const VoterTableResultsScreen();
  }
}

class VoterTableResultsScreen extends StatefulWidget {
  const VoterTableResultsScreen({super.key});

  @override
  State<VoterTableResultsScreen> createState() =>
      _VoterTableResultsScreenState();
}

class _VoterTableResultsScreenState extends State<VoterTableResultsScreen> {
  final List<VoterModel> _votantes = List.from(sampleVoters);
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  List<LugarResult> get _resultadosFiltrados {
    final todos = buildResultsByPlaceAndTable(_votantes);
    final query = _busquedaCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return todos;

    return todos.where((lugar) {
      final coincideLugar = lugar.lugar.toLowerCase().contains(query);
      final coincideMesa = lugar.mesas.any(
        (mesa) => mesa.mesa.toLowerCase().contains(query),
      );
      return coincideLugar || coincideMesa;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _resultadosFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Resultados por mesa y lugar',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBuscador(),
            _buildResumenGeneral(resultados),
            Expanded(
              child: resultados.isEmpty
                  ? _buildEstadoVacio()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: resultados.length,
                      itemBuilder: (context, i) =>
                          _buildLugarCard(resultados[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _busquedaCtrl,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por lugar o mesa de votación',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13.5),
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
          suffixIcon: _busquedaCtrl.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _busquedaCtrl.clear()),
                ),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
        ),
      ),
    );
  }

  Widget _buildResumenGeneral(List<LugarResult> resultados) {
    final totalVotantes = resultados.fold<int>(
      0,
      (sum, l) => sum + l.totalVotantes,
    );
    final totalMesas = resultados.fold<int>(
      0,
      (sum, l) => sum + l.mesas.length,
    );
    final totalLugares = resultados.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            _buildResumenItem(
              Icons.how_to_vote_outlined,
              '$totalVotantes',
              'Votos',
            ),
            _buildSeparador(),
            _buildResumenItem(Icons.table_bar_outlined, '$totalMesas', 'Mesas'),
            _buildSeparador(),
            _buildResumenItem(
              Icons.location_on_outlined,
              '$totalLugares',
              'Lugares',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(IconData icono, String valor, String etiqueta) {
    return Expanded(
      child: Column(
        children: [
          Icon(icono, color: Colors.blue[300], size: 22),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            etiqueta,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparador() {
    return Container(width: 1, height: 40, color: const Color(0xFF334155));
  }

  Widget _buildEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_outlined, color: Colors.white24, size: 42),
          SizedBox(height: 10),
          Text(
            'No se encontraron lugares o mesas',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLugarCard(LugarResult lugar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: ExpansionTile(
        iconColor: Colors.blue[300],
        collapsedIconColor: Colors.white54,
        title: Text(
          lugar.lugar,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _buildBadge(
                Icons.how_to_vote_outlined,
                '${lugar.totalVotantes} votos',
              ),
              const SizedBox(width: 8),
              _buildBadge(
                Icons.table_bar_outlined,
                '${lugar.mesas.length} mesas',
              ),
            ],
          ),
        ),
        children: lugar.mesas.map((mesa) => _buildMesaTile(mesa)).toList(),
      ),
    );
  }

  Widget _buildBadge(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue[400]!.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: Colors.blue[200]),
          const SizedBox(width: 4),
          Text(texto, style: TextStyle(color: Colors.blue[200], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMesaTile(MesaResult mesa) {
    final opcionesOrdenadas = mesa.conteoOpciones.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mesa.mesa,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.image, color: Colors.green[400], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${mesa.conEvidencia}',
                    style: TextStyle(color: Colors.green[400], fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white30,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mesa.sinEvidencia}',
                    style: const TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...opcionesOrdenadas.map(
            (e) => _buildBarraOpcion(e.key, e.value, mesa.totalVotantes),
          ),
          const SizedBox(height: 10),
          Text(
            'Total: ${mesa.totalVotantes} votante${mesa.totalVotantes == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraOpcion(String opcion, int votos, int total) {
    final porcentaje = total == 0 ? 0.0 : votos / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                opcion,
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              Text(
                '$votos · ${(porcentaje * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 8,
              backgroundColor: const Color(0xFF334155),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
            ),
          ),
        ],
      ),
    );
  }
}
