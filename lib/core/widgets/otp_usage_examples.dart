import 'package:flutter/material.dart';
import '../../core/widgets/otp_verification_screen.dart';

/// Ejemplos de uso del OTP en diferentes contextos
class OtpUsageExamples {
  /// Ejemplo 1: Verificación de registro de cuenta
  static Future<bool?> verifyRegistration(BuildContext context, String email) {
    return Navigator.push<bool>(
      context,
      OtpVerificationScreen.route(
        title: 'Verificar cuenta',
        subtitle: 'Verificación por correo electrónico',
        description:
            'Ingresa el código de 6 dígitos enviado a tu correo electrónico.',
        recipient: email,
        icon: Icons.mark_email_read_outlined,
        onVerify: (code) async {
          // TODO: Implementar verificación con API
          // final result = await authRepository.verifyRegistration(email, code);
          // return result.isRight();

          print('Verificando registro con código: $code');
          await Future.delayed(const Duration(seconds: 2));
          return true; // Simular éxito
        },
        onResend: () async {
          // TODO: Implementar reenvío con API
          // final result = await authRepository.resendVerificationCode(email);
          // return result.isRight();

          print('Reenviando código a: $email');
          await Future.delayed(const Duration(seconds: 1));
          return true;
        },
        onSuccess: () {
          print('Registro verificado exitosamente');
        },
        onError: (error) {
          print('Error en verificación: $error');
        },
      ),
    );
  }

  /// Ejemplo 2: Verificación de cambio de contraseña
  static Future<bool?> verifyPasswordReset(BuildContext context, String email) {
    return Navigator.push<bool>(
      context,
      OtpVerificationScreen.route(
        title: 'Recuperar contraseña',
        subtitle: 'Verificación de seguridad',
        description:
            'Ingresa el código de 6 dígitos enviado a tu correo para restablecer tu contraseña.',
        recipient: email,
        icon: Icons.lock_reset,
        primaryColor: Colors.orange,
        onVerify: (code) async {
          // TODO: Implementar verificación de reset
          // final result = await authRepository.verifyPasswordReset(email, code);
          // return result.isRight();

          print('Verificando código de reset: $code');
          await Future.delayed(const Duration(seconds: 2));
          return true;
        },
        onResend: () async {
          print('Reenviando código de reset a: $email');
          await Future.delayed(const Duration(seconds: 1));
          return true;
        },
      ),
    );
  }

  /// Ejemplo 3: Verificación de cambio de email
  static Future<bool?> verifyEmailChange(
    BuildContext context,
    String newEmail,
  ) {
    return Navigator.push<bool>(
      context,
      OtpVerificationScreen.route(
        title: 'Cambiar correo',
        subtitle: 'Verifica tu nuevo correo',
        description:
            'Ingresa el código enviado a tu nuevo correo electrónico para confirmar el cambio.',
        recipient: newEmail,
        icon: Icons.email_outlined,
        primaryColor: Colors.purple,
        onVerify: (code) async {
          // TODO: Implementar verificación de cambio de email
          print('Verificando cambio de email: $code');
          await Future.delayed(const Duration(seconds: 2));
          return true;
        },
        onResend: () async {
          print('Reenviando código a nuevo email: $newEmail');
          await Future.delayed(const Duration(seconds: 1));
          return true;
        },
      ),
    );
  }

  /// Ejemplo 4: Verificación de número de teléfono
  static Future<bool?> verifyPhone(BuildContext context, String phoneNumber) {
    return Navigator.push<bool>(
      context,
      OtpVerificationScreen.route(
        title: 'Verificar teléfono',
        subtitle: 'Verificación por SMS',
        description: 'Ingresa el código de 6 dígitos enviado a tu teléfono.',
        recipient: phoneNumber,
        icon: Icons.phone_android,
        primaryColor: Colors.green,
        onVerify: (code) async {
          // TODO: Implementar verificación de teléfono
          print('Verificando teléfono con código: $code');
          await Future.delayed(const Duration(seconds: 2));
          return true;
        },
        onResend: () async {
          print('Reenviando SMS a: $phoneNumber');
          await Future.delayed(const Duration(seconds: 1));
          return true;
        },
      ),
    );
  }

  /// Ejemplo 5: Autenticación de dos factores (2FA)
  static Future<bool?> verify2FA(BuildContext context, String username) {
    return Navigator.push<bool>(
      context,
      OtpVerificationScreen.route(
        title: 'Autenticación de dos factores',
        subtitle: 'Verificación de seguridad adicional',
        description:
            'Ingresa el código de 6 dígitos de tu aplicación de autenticación.',
        recipient: username,
        icon: Icons.security,
        primaryColor: Colors.red,
        codeLength: 6,
        onVerify: (code) async {
          // TODO: Implementar verificación 2FA
          print('Verificando 2FA para usuario: $username con código: $code');
          await Future.delayed(const Duration(seconds: 2));
          return true;
        },
        // 2FA generalmente no tiene opción de reenvío
        onResend: null,
      ),
    );
  }

  /// Ejemplo 6: Verificación de transacción
  static Future<bool?> verifyTransaction(
    BuildContext context,
    String email,
    double amount,
  ) {
    return Navigator.push<bool>(
      context,
      OtpVerificationScreen.route(
        title: 'Confirmar transacción',
        subtitle: 'Verificación de seguridad',
        description:
            'Ingresa el código enviado a tu correo para confirmar la transacción de \$$amount.',
        recipient: email,
        icon: Icons.payment,
        primaryColor: Colors.teal,
        onVerify: (code) async {
          // TODO: Implementar verificación de transacción
          print('Verificando transacción de \$$amount con código: $code');
          await Future.delayed(const Duration(seconds: 2));
          return true;
        },
        onResend: () async {
          print('Reenviando código de transacción');
          await Future.delayed(const Duration(seconds: 1));
          return true;
        },
      ),
    );
  }

  /// Ejemplo 7: Uso personalizado con callbacks completos
  static Future<bool?> customVerification(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String recipient,
    required Future<bool> Function(String) onVerify,
    Future<bool> Function()? onResend,
    IconData? icon,
    Color? primaryColor,
    int codeLength = 6,
  }) {
    return Navigator.push<bool>(
      context,
      OtpVerificationScreen.route(
        title: title,
        subtitle: subtitle,
        description: description,
        recipient: recipient,
        icon: icon,
        primaryColor: primaryColor,
        codeLength: codeLength,
        onVerify: onVerify,
        onResend: onResend,
        onSuccess: () {
          // Lógica adicional después de verificación exitosa
          print('Verificación exitosa');
        },
        onError: (error) {
          // Manejo de errores personalizado
          print('Error en verificación: $error');
        },
      ),
    );
  }
}
