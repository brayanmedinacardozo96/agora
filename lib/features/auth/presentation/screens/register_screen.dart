import 'package:agora/core/widgets/otp_usage_examples.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/ui_strings.dart';
import '../../../../core/widgets/custom_alert.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RegisterScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: RegisterScreenBody());
  }
}

class RegisterScreenBody extends StatelessWidget {
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtUser = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPhoneCode = TextEditingController(text: '+57');
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtPasswordConfirmation = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegisterScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: _buildBody(
        context,
        AuthInitial(),
      ) /*BlocConsumer<AuthBloc, AuthState>(
        listener: _listenerMessage,
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),*/,
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Fondo oscuro sólido
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32.0),
              child: _buildRegisterForm(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, AuthState state) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildNameField(context),
          const SizedBox(height: 16),
          _buildUserField(context),
          const SizedBox(height: 16),
          _buildEmailField(context),
          const SizedBox(height: 16),
          _buildPhoneFields(context),
          const SizedBox(height: 16),
          _buildPasswordField(context),
          const SizedBox(height: 16),
          _buildPasswordConfirmationField(context),
          const SizedBox(height: 24),
          _buildRegisterButton(context, state),
          const SizedBox(height: 16),
          _buildLoginLink(context),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, color: Colors.blue[400], size: 32),
            const SizedBox(width: 12),
            const Text(
              UIStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Crear nueva cuenta',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Completa el formulario para registrarte',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre completo',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtName,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ingresa tu nombre completo',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.person, color: Colors.white54),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nombre';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUserField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Usuario',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtUser,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Elige un nombre de usuario',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(
              Icons.alternate_email,
              color: Colors.white54,
            ),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un usuario';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correo electrónico',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtEmail,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e-mail@ejemplo.com',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.email, color: Colors.white54),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu correo';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Ingresa un correo válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Teléfono',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: txtPhoneCode,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '+57',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.flag, color: Colors.white54),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Código';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: txtPhone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Número de teléfono',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.phone, color: Colors.white54),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu teléfono';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraseña',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        PasswordFieldWidget(controller: txtPassword),
      ],
    );
  }

  Widget _buildPasswordConfirmationField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmar contraseña',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        PasswordFieldWidget(
          controller: txtPasswordConfirmation,
          customValidator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor confirma tu contraseña';
            }
            if (value != txtPassword.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;

    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              OtpUsageExamples.verifyRegistration(context, txtEmail.text);
              if (_formKey.currentState!.validate()) {
                _handleRegister(context);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Crear cuenta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Ya tienes una cuenta? ',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            'Inicia sesión',
            style: TextStyle(
              color: Colors.blue[400],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Text(
      'Al registrarte, aceptas nuestros términos y condiciones',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white54, fontSize: 12),
    );
  }

  void _handleRegister(BuildContext context) {
    final registerData = {
      "name": txtName.text,
      "user": txtUser.text,
      "email": txtEmail.text,
      "phone_code": txtPhoneCode.text,
      "phone": txtPhone.text,
      "password": txtPassword.text,
      "password_confirmation": txtPasswordConfirmation.text,
    };

    // TODO: Implementar el evento de registro en el AuthBloc
    // context.read<AuthBloc>().add(RegisterEvent(registerData));

    print('Datos de registro: $registerData');
  }

  void _listenerMessage(BuildContext context, AuthState state) {
    if (state is AuthError) {
      CustomAlert.error(ctx: context, message: state.message);
    }

    if (state is AuthAuthenticated) {
      CustomAlert.success(ctx: context, message: 'Registro exitoso');
      // TODO: Navegar a la pantalla principal o login
    }
  }
}
