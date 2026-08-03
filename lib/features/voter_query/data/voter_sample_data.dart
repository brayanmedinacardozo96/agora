import 'package:agora/features/voter_query/data/models/voter_model.dart';

/// Datos de ejemplo para el módulo de consulta de votantes.
/// Reemplaza esta lista por tu fuente de datos real.
final List<VoterModel> sampleVoters = [
  VoterModel(
    id: '1',
    nombres: 'Diana Marcela',
    apellidos: 'Cárdenas López',
    lugarVotacion: 'Institución Educativa San José',
    mesa: 'Mesa 1',
    opcionVotada: 'Candidato A',
  ),
  VoterModel(
    id: '2',
    nombres: 'Jorge Andrés',
    apellidos: 'Castro Ríos',
    lugarVotacion: 'Colegio Departamental Norte',
    mesa: 'Mesa 3',
    opcionVotada: 'Candidato B',
  ),
  VoterModel(
    id: '3',
    nombres: 'Ana María',
    apellidos: 'Torres Fernández',
    lugarVotacion: 'Institución Educativa San José',
    mesa: 'Mesa 2',
    opcionVotada: 'Candidato A',
  ),
  VoterModel(
    id: '4',
    nombres: 'Luis Eduardo',
    apellidos: 'Pérez Gutiérrez',
    lugarVotacion: 'Colegio Departamental Norte',
    mesa: 'Mesa 1',
    opcionVotada: 'Candidato C',
  ),
  VoterModel(
    id: '5',
    nombres: 'Marta Lucía',
    apellidos: 'Gómez Díaz',
    lugarVotacion: 'Escuela Primaria Sur',
    mesa: 'Mesa 5',
    opcionVotada: 'Candidato A',
  ),
  VoterModel(
    id: '6',
    nombres: 'Carlos Alberto',
    apellidos: 'Ramírez Muñoz',
    lugarVotacion: 'Institución Educativa San José',
    mesa: 'Mesa 1',
    opcionVotada: 'Candidato B',
  ),
  VoterModel(
    id: '7',
    nombres: 'Lucía Fernanda',
    apellidos: 'Ortiz Salazar',
    lugarVotacion: 'Colegio Departamental Norte',
    mesa: 'Mesa 3',
    opcionVotada: 'Candidato A',
  ),
  VoterModel(
    id: '8',
    nombres: 'Pedro José',
    apellidos: 'Vargas Castillo',
    lugarVotacion: 'Escuela Primaria Sur',
    mesa: 'Mesa 5',
    opcionVotada: 'Candidato C',
  ),
  VoterModel(
    id: '9',
    nombres: 'Mariana',
    apellidos: 'Sánchez Beltrán',
    lugarVotacion: 'Institución Educativa San José',
    mesa: 'Mesa 2',
    opcionVotada: 'Candidato B',
  ),
  VoterModel(
    id: '10',
    nombres: 'Andrés Felipe',
    apellidos: 'Mendoza Rojas',
    lugarVotacion: 'Colegio Departamental Norte',
    mesa: 'Mesa 1',
    opcionVotada: 'Candidato A',
  ),
];

/// Resultado agregado para una mesa dentro de un lugar de votación.
class MesaResult {
  final String mesa;
  final int totalVotantes;
  final int conEvidencia;
  final int sinEvidencia;
  final Map<String, int> conteoOpciones;

  const MesaResult({
    required this.mesa,
    required this.totalVotantes,
    required this.conEvidencia,
    required this.sinEvidencia,
    required this.conteoOpciones,
  });
}

/// Resultado agregado para un lugar de votación.
class LugarResult {
  final String lugar;
  final int totalVotantes;
  final int conEvidencia;
  final int sinEvidencia;
  final List<MesaResult> mesas;

  const LugarResult({
    required this.lugar,
    required this.totalVotantes,
    required this.conEvidencia,
    required this.sinEvidencia,
    required this.mesas,
  });
}

/// Agrupa los votantes por lugar de votación y, dentro de cada lugar, por mesa.
List<LugarResult> buildResultsByPlaceAndTable(List<VoterModel> voters) {
  // lugar -> mesa -> lista de votantes
  final groups = <String, Map<String, List<VoterModel>>>{};

  for (final voter in voters) {
    groups
        .putIfAbsent(voter.lugarVotacion, () => {})
        .putIfAbsent(voter.mesa, () => [])
        .add(voter);
  }

  final resultados = <LugarResult>[];

  for (final lugarEntry in groups.entries) {
    final mesasResult = <MesaResult>[];
    var totalLugar = 0;
    var conEvidenciaLugar = 0;

    for (final mesaEntry in lugarEntry.value.entries) {
      final votantesMesa = mesaEntry.value;
      final conteo = <String, int>{};
      var conEvidencia = 0;

      for (final v in votantesMesa) {
        conteo[v.opcionVotada] = (conteo[v.opcionVotada] ?? 0) + 1;
        if (v.tieneEvidencia) conEvidencia++;
      }

      totalLugar += votantesMesa.length;
      conEvidenciaLugar += conEvidencia;

      mesasResult.add(
        MesaResult(
          mesa: mesaEntry.key,
          totalVotantes: votantesMesa.length,
          conEvidencia: conEvidencia,
          sinEvidencia: votantesMesa.length - conEvidencia,
          conteoOpciones: conteo,
        ),
      );
    }

    mesasResult.sort((a, b) => a.mesa.compareTo(b.mesa));

    resultados.add(
      LugarResult(
        lugar: lugarEntry.key,
        totalVotantes: totalLugar,
        conEvidencia: conEvidenciaLugar,
        sinEvidencia: totalLugar - conEvidenciaLugar,
        mesas: mesasResult,
      ),
    );
  }

  resultados.sort((a, b) => a.lugar.compareTo(b.lugar));
  return resultados;
}
