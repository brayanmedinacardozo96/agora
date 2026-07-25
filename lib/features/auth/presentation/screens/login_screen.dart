import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/ui_strings.dart';
import '../../../../core/widgets/custom_alert.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/responsive_login_layout_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginScreenBody());
  }
}

class LoginScreenBody extends StatelessWidget {
  final TextEditingController txtUser = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: _listenerMessage,
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Fondo oscuro sólido
      ),
      child: SafeArea(
        child: ResponsiveLoginLayout(
          loginForm: _buildLoginForm(context, state),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthState state) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        //color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildTextUser(context),
          const SizedBox(height: 16),
          _buildTextPassword(context),
          const SizedBox(height: 8),
          _buildResetPassword(context),
          const SizedBox(height: 24),
          _buildButton(context, state),
          const SizedBox(height: 12),
          _buildSignHereButton(context),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 8),
        Text(
          UIStrings.appTagline,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 32),
        const Text(
          UIStrings.welcomeBack,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          UIStrings.loginSubtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextUser(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UIStrings.emailLabel,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtUser,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: UIStrings.emailHint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
            filled: true,
            fillColor: const Color(0xFF1E293B), // const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return UIStrings.emailRequired;
            }
            if (!value.contains('@')) {
              return UIStrings.emailInvalid;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextPassword(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UIStrings.passwordLabel,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: txtPassword,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: UIStrings.passwordHint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
            suffixIcon: Icon(
              Icons.visibility_off_outlined,
              color: Colors.grey[500],
            ),
            filled: true,
            fillColor: const Color(0xFF1E293B), // const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return UIStrings.passwordRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResetPassword(BuildContext ctx) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _onForgotPassword(ctx),
        child: Text(
          UIStrings.forgotPassword,
          style: TextStyle(color: Colors.blue[400], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, AuthState state) {
    return ElevatedButton(
      onPressed: state is AuthLoading
          ? null
          : () {
              if (_formKey.currentState?.validate() ?? false) {
                context.read<AuthBloc>().add(
                  LoginEvent(email: txtUser.text, password: txtPassword.text),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: state is AuthLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              UIStrings.loginButton,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildSignHereButton(BuildContext ctx) {
    return OutlinedButton(
      onPressed: () => _onSignUp(ctx),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey[700]!),
      ),
      child: const Text(
        UIStrings.createAccount,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      UIStrings.appVersion,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    );
  }

  void _listenerMessage(BuildContext ctx, AuthState state) {
    if (state is AuthError) {
      CustomAlert.top(
        ctx: ctx,
        message: state.message,
        behavior: SnackBarBehavior.fixed,
      );
    }

    if (state is AuthAuthenticated) {
      // TODO: Navigate to home screen or trigger app-wide authentication state change
      // You might want to use an AuthenticationBloc at app level
      // ctx.read<AuthenticationBloc>().add(AuthenticationStatusChanged(AuthenticationStatus.authenticated));
    }
  }

  void _onForgotPassword(BuildContext ctx) {
    // TODO: Navigate to forgot password screen
    // Navigator.pushNamed(ctx, '/forgot-password');
  }

  void _onSignUp(BuildContext ctx) {
    Navigator.pushNamed(ctx, '/sign-up');
  }
}
