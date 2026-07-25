import 'package:agora/features/voting/presentation/screens/vote_evidence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final txtCedula = TextEditingController();
  final txtNombres = TextEditingController();
  final txtApellidos = TextEditingController();
  final txtTelefono = TextEditingController();
  final txtEmail = TextEditingController();
  final txtPuestoVotacion = TextEditingController();
  final txtMesa = TextEditingController();

  // Valores de selects (dropdowns) - de ejemplo, reemplazar por datos reales
  String? _departamentoSeleccionado;
  String? _municipioSeleccionado;
  String? _comunaSeleccionada;
  String? _zona; // Rural o Urbano
  bool _zonaTocada = false;

  final List<String> _departamentos = ['Huila', 'Cundinamarca', 'Antioquia'];
  final Map<String, List<String>> _municipiosPorDepartamento = {
    'Huila': ['Neiva', 'Pitalito', 'Garzón'],
    'Cundinamarca': ['Bogotá', 'Soacha', 'Zipaquirá'],
    'Antioquia': ['Medellín', 'Envigado', 'Itagüí'],
  };
  final List<String> _comunas = [
    'Comuna 1',
    'Comuna 2',
    'Comuna 3',
    'Comuna 4',
  ];
  final List<String> _zonas = ['Urbano', 'Rural'];

  bool _isLoading = false;

  @override
  void dispose() {
    txtCedula.dispose();
    txtNombres.dispose();
    txtApellidos.dispose();
    txtTelefono.dispose();
    txtEmail.dispose();
    txtPuestoVotacion.dispose();
    txtMesa.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _zonaTocada = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _zona == null) return;

    setState(() => _isLoading = true);

    // Aquí solo se simula el envío (UI únicamente, sin lógica de backend).
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulario validado correctamente')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VotingScreen()),
      );
    });
  }

  // ---------- Estilos compartidos ----------

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E293B),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
    );
  }

  // ---------- Campos individuales ----------

  Widget _buildCedulaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Cédula'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtCedula,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _fieldDecoration(
            hint: 'Ingresa tu número de cédula',
            icon: Icons.badge_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa tu cédula';
            }
            if (value.trim().length < 6) {
              return 'Cédula inválida';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNombresField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Nombres'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtNombres,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration(
            hint: 'Ingresa tus nombres',
            icon: Icons.person_outline,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa tus nombres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildApellidosField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Apellidos'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtApellidos,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration(
            hint: 'Ingresa tus apellidos',
            icon: Icons.person_outline,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa tus apellidos';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTelefonoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Teléfono'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtTelefono,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _fieldDecoration(
            hint: 'Ingresa tu número de teléfono',
            icon: Icons.phone_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa tu teléfono';
            }
            if (value.trim().length < 7) {
              return 'Teléfono inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Correo electrónico'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtEmail,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration(
            hint: 'correo@ejemplo.com',
            icon: Icons.email_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa tu correo electrónico';
            }
            final regex = RegExp(r'^[\w.\-+]+@[\w\-]+\.[a-zA-Z]{2,}$');
            if (!regex.hasMatch(value.trim())) {
              return 'Correo electrónico inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDepartamentoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Departamento'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _departamentoSeleccionado,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          decoration: _fieldDecoration(
            hint: 'Selecciona el departamento',
            icon: Icons.map_outlined,
          ),
          items: _departamentos
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _departamentoSeleccionado = value;
              _municipioSeleccionado = null;
            });
          },
          validator: (value) =>
              value == null ? 'Selecciona un departamento' : null,
        ),
      ],
    );
  }

  Widget _buildMunicipioField() {
    final municipiosDisponibles =
        _municipiosPorDepartamento[_departamentoSeleccionado] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Municipio'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _municipioSeleccionado,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          decoration: _fieldDecoration(
            hint: _departamentoSeleccionado == null
                ? 'Primero selecciona un departamento'
                : 'Selecciona el municipio',
            icon: Icons.location_city_outlined,
          ),
          items: municipiosDisponibles
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: _departamentoSeleccionado == null
              ? null
              : (value) => setState(() => _municipioSeleccionado = value),
          validator: (value) =>
              value == null ? 'Selecciona un municipio' : null,
        ),
      ],
    );
  }

  Widget _buildComunaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Comuna'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _comunaSeleccionada,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          decoration: _fieldDecoration(
            hint: 'Selecciona la comuna',
            icon: Icons.holiday_village_outlined,
          ),
          items: _comunas
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) => setState(() => _comunaSeleccionada = value),
          validator: (value) => value == null ? 'Selecciona una comuna' : null,
        ),
      ],
    );
  }

  Widget _buildZonaField() {
    final mostrarError = _zonaTocada && _zona == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Zona (Rural o Urbano)'),
        const SizedBox(height: 8),
        Row(
          children: _zonas.map((z) {
            final selected = _zona == z;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: z == _zonas.first ? 8 : 0,
                  left: z == _zonas.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _zona = z;
                    _zonaTocada = true;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.blue[400]!.withValues(alpha: 0.15)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Colors.blue[400]!
                            : (mostrarError
                                  ? Colors.red[300]!
                                  : const Color(0xFF334155)),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      z,
                      style: TextStyle(
                        color: selected ? Colors.blue[100] : Colors.white70,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (mostrarError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Selecciona la zona (rural o urbano)',
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPuestoVotacionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Puesto de votación'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtPuestoVotacion,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration(
            hint: 'Nombre del puesto de votación',
            icon: Icons.how_to_vote_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el puesto de votación';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMesaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Mesa'),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtMesa,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _fieldDecoration(
            hint: 'Número de mesa',
            icon: Icons.table_chart_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el número de mesa';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ---------- Build principal ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Registro de Votante',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Datos del votante',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Completa la información para registrarte',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 24),

                    _buildCedulaField(),
                    const SizedBox(height: 16),

                    _buildNombresField(),
                    const SizedBox(height: 16),

                    _buildApellidosField(),
                    const SizedBox(height: 16),

                    _buildTelefonoField(),
                    const SizedBox(height: 16),

                    _buildEmailField(),
                    const SizedBox(height: 16),

                    _buildDepartamentoField(),
                    const SizedBox(height: 16),

                    _buildMunicipioField(),
                    const SizedBox(height: 16),

                    _buildComunaField(),
                    const SizedBox(height: 16),

                    _buildZonaField(),
                    const SizedBox(height: 16),

                    _buildPuestoVotacionField(),
                    const SizedBox(height: 16),

                    _buildMesaField(),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Registrar',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
