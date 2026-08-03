import 'dart:io';

/// Modelo que representa la información de un votante y su evidencia de voto.
class VoterModel {
  final String id;
  final String nombres;
  final String apellidos;
  final String lugarVotacion;
  final String mesa;
  final String opcionVotada;
  String? evidenciaPath;

  VoterModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.lugarVotacion,
    required this.mesa,
    required this.opcionVotada,
    this.evidenciaPath,
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();

  String get iniciales {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '';
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }

  bool get tieneEvidencia =>
      evidenciaPath != null &&
      evidenciaPath!.isNotEmpty &&
      File(evidenciaPath!).existsSync();

  VoterModel copyWith({
    String? id,
    String? nombres,
    String? apellidos,
    String? lugarVotacion,
    String? mesa,
    String? opcionVotada,
    String? evidenciaPath,
  }) {
    return VoterModel(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      lugarVotacion: lugarVotacion ?? this.lugarVotacion,
      mesa: mesa ?? this.mesa,
      opcionVotada: opcionVotada ?? this.opcionVotada,
      evidenciaPath: evidenciaPath ?? this.evidenciaPath,
    );
  }
}
