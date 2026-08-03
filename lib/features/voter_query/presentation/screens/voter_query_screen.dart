import 'package:agora/features/voter_query/data/models/voter_model.dart';
import 'package:agora/features/voter_query/data/voter_sample_data.dart';
import 'package:agora/features/voter_query/presentation/widgets/voter_detail_modal.dart';
import 'package:flutter/material.dart';

enum FiltroEvidencia { todos, conEvidencia, sinEvidencia }

extension FiltroEvidenciaX on FiltroEvidencia {
  String get etiqueta {
    switch (this) {
      case FiltroEvidencia.todos:
        return 'Todos';
      case FiltroEvidencia.conEvidencia:
        return 'Con evidencia';
      case FiltroEvidencia.sinEvidencia:
        return 'Sin evidencia';
    }
  }
}

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class ConsultaVotantesApp extends StatelessWidget {
  const ConsultaVotantesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConsultaVotantesScreen();
  }
}

class ConsultaVotantesScreen extends StatefulWidget {
  const ConsultaVotantesScreen({super.key});

  @override
  State<ConsultaVotantesScreen> createState() => _ConsultaVotantesScreenState();
}

class _ConsultaVotantesScreenState extends State<ConsultaVotantesScreen> {
  final List<VoterModel> _votantes = List.from(sampleVoters);
  final TextEditingController _busquedaCtrl = TextEditingController();

  FiltroEvidencia _filtroEvidencia = FiltroEvidencia.todos;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  List<VoterModel> get _votantesFiltrados {
    final query = _busquedaCtrl.text.trim().toLowerCase();
    return _votantes.where((v) {
      final coincideBusqueda =
          query.isEmpty ||
          v.nombres.toLowerCase().contains(query) ||
          v.apellidos.toLowerCase().contains(query) ||
          v.lugarVotacion.toLowerCase().contains(query) ||
          v.mesa.toLowerCase().contains(query);

      final coincideEvidencia = switch (_filtroEvidencia) {
        FiltroEvidencia.todos => true,
        FiltroEvidencia.conEvidencia => v.tieneEvidencia,
        FiltroEvidencia.sinEvidencia => !v.tieneEvidencia,
      };

      return coincideBusqueda && coincideEvidencia;
    }).toList();
  }

  Future<void> _abrirDetalle(VoterModel votante) async {
    final resultado = await showModalBottomSheet<VoterModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => VoterDetailModal(votante: votante),
    );

    if (resultado != null && mounted) {
      setState(() {
        final index = _votantes.indexWhere((v) => v.id == resultado.id);
        if (index != -1) {
          _votantes[index] = resultado;
        }
      });
    }
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final votantes = _votantesFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Consulta de Votantes',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBuscador(),
            _buildFiltros(),
            Expanded(
              child: votantes.isEmpty
                  ? _buildEstadoVacio()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: votantes.length,
                      itemBuilder: (context, i) =>
                          _buildVotanteCard(votantes[i]),
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
          hintText: 'Buscar por nombre, apellido, lugar o mesa',
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

  Widget _buildFiltros() {
    final filtros = FiltroEvidencia.values;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filtros.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final filtro = filtros[i];
            final selected = _filtroEvidencia == filtro;
            return ChoiceChip(
              label: Text(filtro.etiqueta),
              selected: selected,
              onSelected: (_) => setState(() => _filtroEvidencia = filtro),
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
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, color: Colors.white24, size: 42),
          SizedBox(height: 10),
          Text(
            'No se encontraron votantes',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVotanteCard(VoterModel votante) {
    final tieneEvidencia = votante.tieneEvidencia;

    return GestureDetector(
      onTap: () => _abrirDetalle(votante),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue[400]!.withValues(alpha: 0.18),
              child: Text(
                votante.iniciales,
                style: TextStyle(
                  color: Colors.blue[200],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    votante.nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    votante.lugarVotacion,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoRow(Icons.table_bar_outlined, votante.mesa),
                  const SizedBox(height: 2),
                  _buildInfoRow(
                    Icons.how_to_vote_outlined,
                    votante.opcionVotada,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tieneEvidencia
                      ? Icons.image
                      : Icons.image_not_supported_outlined,
                  color: tieneEvidencia ? Colors.green[400] : Colors.white38,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  tieneEvidencia ? 'Con evidencia' : 'Sin evidencia',
                  style: TextStyle(
                    color: tieneEvidencia ? Colors.green[400] : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icono, String texto) {
    return Row(
      children: [
        Icon(icono, size: 14, color: Colors.white54),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
