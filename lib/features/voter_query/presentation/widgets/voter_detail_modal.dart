import 'dart:io';

import 'package:agora/features/voter_query/data/models/voter_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VoterDetailModal extends StatefulWidget {
  final VoterModel votante;

  const VoterDetailModal({super.key, required this.votante});

  @override
  State<VoterDetailModal> createState() => _VoterDetailModalState();
}

class _VoterDetailModalState extends State<VoterDetailModal> {
  late VoterModel _votante;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _votante = widget.votante;
  }

  Future<void> _adjuntarEvidencia() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (imagen == null) return;

    setState(() {
      _votante = _votante.copyWith(evidenciaPath: imagen.path);
    });
  }

  Future<void> _tomarFoto() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (imagen == null) return;

    setState(() {
      _votante = _votante.copyWith(evidenciaPath: imagen.path);
    });
  }

  void _eliminarEvidencia() {
    setState(() {
      _votante = _votante.copyWith(evidenciaPath: null);
    });
  }

  Future<void> _mostrarOpcionesAdjunto() async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue[300]),
                title: const Text(
                  'Seleccionar de galería',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'galeria'),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue[300]),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'camara'),
              ),
              if (_votante.tieneEvidencia)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Eliminar evidencia',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, 'eliminar'),
                ),
            ],
          ),
        ),
      ),
    );

    switch (opcion) {
      case 'galeria':
        await _adjuntarEvidencia();
      case 'camara':
        await _tomarFoto();
      case 'eliminar':
        _eliminarEvidencia();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16),
          _buildEncabezado(),
          const SizedBox(height: 24),
          _buildSeccion('Información del votante', [
            _buildInfoRow('Nombres', _votante.nombres),
            _buildInfoRow('Apellidos', _votante.apellidos),
            _buildInfoRow('Lugar de votación', _votante.lugarVotacion),
            _buildInfoRow('Mesa', _votante.mesa),
            _buildInfoRow('Opción votada', _votante.opcionVotada),
          ]),
          const SizedBox(height: 24),
          _buildSeccionEvidencia(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, _votante),
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue[400]!.withValues(alpha: 0.18),
          child: Text(
            _votante.iniciales,
            style: TextStyle(
              color: Colors.blue[200],
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _votante.nombreCompleto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ID: ${_votante.id}',
                style: const TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccion(String titulo, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: const TextStyle(color: Colors.white54, fontSize: 12.5),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionEvidencia() {
    final tieneEvidencia = _votante.tieneEvidencia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evidencia del voto',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _mostrarOpcionesAdjunto,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tieneEvidencia
                    ? Colors.green[400]!.withValues(alpha: 0.5)
                    : const Color(0xFF334155),
              ),
              image: tieneEvidencia
                  ? DecorationImage(
                      image: FileImage(File(_votante.evidenciaPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: tieneEvidencia
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.blue[300],
                        size: 42,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque para adjuntar evidencia',
                        style: TextStyle(
                          color: Colors.blue[200],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Puede seleccionar de galería o tomar una foto',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
