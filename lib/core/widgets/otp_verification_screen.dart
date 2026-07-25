import 'package:flutter/material.dart';
import 'otp_input_field.dart';

/// Pantalla genérica de verificación OTP
///
/// Puede ser usada en múltiples contextos:
/// - Verificación de registro
/// - Verificación de cambio de contraseña
/// - Verificación de cambio de email/teléfono
/// - Autenticación de dos factores (2FA)
///
/// Ejemplo de uso:
/// ```dart
/// Navigator.push(
///   context,
///   OtpVerificationScreen.route(
///     title: 'Verificar cuenta',
///     subtitle: 'Verificación por correo electrónico',
///     description: 'Ingresa el código de 6 dígitos enviado a tu correo',
///     recipient: 'usuario@ejemplo.com',
///     onVerify: (code) async {
///       // Lógica de verificación
///       return true;
///     },
///     onResend: () async {
///       // Lógica de reenvío
///       return true;
///     },
///   ),
/// );
/// ```
class OtpVerificationScreen extends StatefulWidget {
  /// Título principal de la pantalla
  final String title;

  /// Subtítulo o tipo de verificación
  final String subtitle;

  /// Descripción o instrucciones
  final String description;

  /// Destinatario del código (email, teléfono, etc.)
  final String recipient;

  /// Número de dígitos del código
  final int codeLength;

  /// Callback para verificar el código
  final Future<bool> Function(String code) onVerify;

  /// Callback opcional para reenviar el código
  final Future<bool> Function()? onResend;

  /// Callback opcional cuando la verificación es exitosa
  final VoidCallback? onSuccess;

  /// Callback opcional cuando hay un error
  final Function(String error)? onError;

  /// Ícono a mostrar en el header
  final IconData? icon;

  /// Color del tema
  final Color? primaryColor;

  const OtpVerificationScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.recipient,
    required this.onVerify,
    this.codeLength = 6,
    this.onResend,
    this.onSuccess,
    this.onError,
    this.icon,
    this.primaryColor,
  });

  static Route<bool> route({
    required String title,
    required String subtitle,
    required String description,
    required String recipient,
    required Future<bool> Function(String code) onVerify,
    int codeLength = 6,
    Future<bool> Function()? onResend,
    VoidCallback? onSuccess,
    Function(String error)? onError,
    IconData? icon,
    Color? primaryColor,
  }) {
    return MaterialPageRoute<bool>(
      builder: (_) => OtpVerificationScreen(
        title: title,
        subtitle: subtitle,
        description: description,
        recipient: recipient,
        onVerify: onVerify,
        codeLength: codeLength,
        onResend: onResend,
        onSuccess: onSuccess,
        onError: onError,
        icon: icon,
        primaryColor: primaryColor,
      ),
    );
  }

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final GlobalKey<OtpInputFieldState> _otpKey = GlobalKey<OtpInputFieldState>();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(primaryColor),
                  const SizedBox(height: 40),
                  OtpInputField(
                    key: _otpKey,
                    length: widget.codeLength,
                    onCompleted: _handleVerification,
                    activeBorderColor: primaryColor,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(),
                  ],
                  const SizedBox(height: 32),
                  _buildVerifyButton(primaryColor),
                  if (widget.onResend != null) ...[
                    const SizedBox(height: 16),
                    _buildResendLink(primaryColor),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon ?? Icons.mark_email_read_outlined,
            size: 48,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          widget.subtitle,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.description,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.6)
                : Colors.black54,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.recipient,
          style: TextStyle(
            color: primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(Color primaryColor) {
    final otpState = _otpKey.currentState;
    final isComplete = otpState?.isComplete ?? false;
    final canVerify = isComplete && !_isLoading;

    return ElevatedButton(
      onPressed: canVerify
          ? () => _handleVerification(otpState!.currentCode)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        disabledBackgroundColor: primaryColor.withOpacity(0.3),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Verificar código',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: canVerify ? Colors.white : Colors.white38,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildResendLink(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No recibiste el código? ',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.6)
                : Colors.black54,
            fontSize: 14,
          ),
        ),
        _isResending
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : GestureDetector(
                onTap: _handleResendCode,
                child: Text(
                  'Reenviar',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ],
    );
  }

  Future<void> _handleVerification(String code) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onVerify(code);

      if (!mounted) return;

      if (success) {
        widget.onSuccess?.call();
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Código incorrecto. Por favor intenta nuevamente.';
          _isLoading = false;
        });
        _otpKey.currentState?.clear();
      }
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString();
      widget.onError?.call(errorMsg);

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
      _otpKey.currentState?.clear();
    }
  }

  Future<void> _handleResendCode() async {
    if (_isResending || widget.onResend == null) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onResend!();

      if (!mounted) return;

      setState(() {
        _isResending = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código reenviado a ${widget.recipient}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'No se pudo reenviar el código. Intenta nuevamente.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error al reenviar el código: ${e.toString()}';
        _isResending = false;
      });
    }
  }
}
