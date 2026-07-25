# Sistema de Verificación OTP (Reutilizable)

## 📍 Ubicación
Los componentes OTP están en `lib/core/widgets/` para ser reutilizados en toda la aplicación.

```
lib/core/widgets/
├── otp_input_field.dart              ✅ Widget de campos OTP
├── otp_verification_screen.dart      ✅ Pantalla genérica de verificación
└── otp_usage_examples.dart           ✅ Ejemplos de uso
```

## 🎯 ¿Por qué en Core?

El OTP **NO** es específico de autenticación. Puede usarse en múltiples contextos:

- ✅ Verificación de registro
- ✅ Recuperación de contraseña
- ✅ Cambio de email
- ✅ Verificación de teléfono
- ✅ Autenticación de dos factores (2FA)
- ✅ Confirmación de transacciones
- ✅ Verificación de acciones sensibles

## 📦 Componentes

### 1. OtpInputField (Widget Básico)

Widget de bajo nivel para campos OTP personalizables.

```dart
import 'package:easy/core/widgets/otp_input_field.dart';

OtpInputField(
  length: 6,
  onCompleted: (code) {
    print('Código completo: $code');
  },
  onChanged: (code) {
    print('Código parcial: $code');
  },
  // Personalización
  fieldWidth: 56,
  fieldHeight: 64,
  spacing: 8,
  backgroundColor: Colors.grey[900],
  activeBorderColor: Colors.blue,
  borderColor: Colors.grey,
  textColor: Colors.white,
  borderRadius: 12,
  borderWidth: 2,
)
```

#### Propiedades

| Propiedad | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `length` | `int` | `6` | Número de dígitos |
| `onCompleted` | `Function(String)` | **required** | Callback al completar |
| `onChanged` | `Function(String)?` | `null` | Callback en cada cambio |
| `fieldWidth` | `double` | `56` | Ancho de campo |
| `fieldHeight` | `double` | `64` | Alto de campo |
| `spacing` | `double` | `8` | Espacio entre campos |
| `backgroundColor` | `Color?` | tema | Color de fondo |
| `borderColor` | `Color?` | tema | Color de borde inactivo |
| `activeBorderColor` | `Color?` | tema | Color de borde activo |
| `textColor` | `Color?` | tema | Color del texto |
| `borderRadius` | `double` | `12` | Radio de esquinas |
| `borderWidth` | `double` | `2` | Ancho del borde |

#### Métodos Públicos

```dart
final otpKey = GlobalKey<OtpInputFieldState>();

// Obtener el código actual
String code = otpKey.currentState?.currentCode ?? '';

// Verificar si está completo
bool isComplete = otpKey.currentState?.isComplete ?? false;

// Limpiar todos los campos
otpKey.currentState?.clear();

// Establecer un código
otpKey.currentState?.setCode('123456');
```

### 2. OtpVerificationScreen (Pantalla Completa)

Pantalla de verificación lista para usar con UI completa.

```dart
import 'package:easy/core/widgets/otp_verification_screen.dart';

// Navegar a la pantalla
final result = await Navigator.push<bool>(
  context,
  OtpVerificationScreen.route(
    title: 'Verificar cuenta',
    subtitle: 'Verificación por correo electrónico',
    description: 'Ingresa el código de 6 dígitos enviado a tu correo.',
    recipient: 'usuario@ejemplo.com',
    icon: Icons.mark_email_read_outlined,
    primaryColor: Colors.blue,
    codeLength: 6,
    onVerify: (code) async {
      // Lógica de verificación
      final isValid = await api.verifyCode(code);
      return isValid;
    },
    onResend: () async {
      // Lógica de reenvío
      final success = await api.resendCode();
      return success;
    },
    onSuccess: () {
      print('Verificación exitosa');
    },
    onError: (error) {
      print('Error: $error');
    },
  ),
);

if (result == true) {
  // Código verificado exitosamente
}
```

#### Propiedades

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `title` | `String` | Título principal |
| `subtitle` | `String` | Subtítulo |
| `description` | `String` | Descripción/instrucciones |
| `recipient` | `String` | Email/teléfono destinatario |
| `onVerify` | `Future<bool> Function(String)` | Función de verificación |
| `codeLength` | `int` | Número de dígitos (default: 6) |
| `onResend` | `Future<bool> Function()?` | Función de reenvío (opcional) |
| `onSuccess` | `VoidCallback?` | Callback de éxito |
| `onError` | `Function(String)?` | Callback de error |
| `icon` | `IconData?` | Ícono del header |
| `primaryColor` | `Color?` | Color del tema |

## 📚 Ejemplos de Uso

### Ejemplo 1: Verificación de Registro

```dart
import 'package:easy/core/widgets/otp_usage_examples.dart';

final verified = await OtpUsageExamples.verifyRegistration(
  context,
  'usuario@ejemplo.com',
);
```

### Ejemplo 2: Recuperación de Contraseña

```dart
final verified = await OtpUsageExamples.verifyPasswordReset(
  context,
  'usuario@ejemplo.com',
);

if (verified == true) {
  // Navegar a pantalla de nueva contraseña
  Navigator.push(context, NewPasswordScreen.route());
}
```

### Ejemplo 3: Verificación de Teléfono

```dart
final verified = await OtpUsageExamples.verifyPhone(
  context,
  '+57 321 904 7590',
);
```

### Ejemplo 4: Autenticación 2FA

```dart
final verified = await OtpUsageExamples.verify2FA(
  context,
  'username',
);

if (verified == true) {
  // Permitir acceso a la aplicación
  Navigator.pushReplacement(context, HomeScreen.route());
}
```

### Ejemplo 5: Verificación Personalizada

```dart
final verified = await OtpUsageExamples.customVerification(
  context,
  title: 'Confirmar acción',
  subtitle: 'Seguridad adicional',
  description: 'Ingresa el código para confirmar esta acción.',
  recipient: 'usuario@ejemplo.com',
  icon: Icons.security,
  primaryColor: Colors.purple,
  codeLength: 6,
  onVerify: (code) async {
    return await myCustomApi.verify(code);
  },
  onResend: () async {
    return await myCustomApi.resend();
  },
);
```

## 🔌 Integración con BLoC

### En Auth Feature

```dart
// En register_screen.dart
void _listenerMessage(BuildContext context, AuthState state) {
  if (state is RegistrationSuccess) {
    // Navegar a verificación OTP
    _navigateToOtpVerification(state.email);
  }
}

Future<void> _navigateToOtpVerification(String email) async {
  final verified = await Navigator.push<bool>(
    context,
    OtpVerificationScreen.route(
      title: 'Verificar cuenta',
      subtitle: 'Verificación por correo electrónico',
      description: 'Ingresa el código de 6 dígitos enviado a tu correo.',
      recipient: email,
      onVerify: (code) async {
        // Usar el repository a través del BLoC
        final result = await context
            .read<AuthBloc>()
            .authRepository
            .verifyRegistration(email, code);
        
        return result.fold(
          (failure) => false,
          (success) => true,
        );
      },
      onResend: () async {
        final result = await context
            .read<AuthBloc>()
            .authRepository
            .resendVerificationCode(email);
        
        return result.fold(
          (failure) => false,
          (success) => true,
        );
      },
    ),
  );

  if (verified == true) {
    // Navegar a home o login
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### Crear un Bloc para OTP (Opcional)

Si necesitas un manejo de estado más complejo:

```dart
// lib/core/bloc/otp_bloc.dart
abstract class OtpEvent {}
class VerifyOtpEvent extends OtpEvent {
  final String code;
  final String identifier; // email, phone, etc.
  VerifyOtpEvent(this.code, this.identifier);
}
class ResendOtpEvent extends OtpEvent {
  final String identifier;
  ResendOtpEvent(this.identifier);
}

abstract class OtpState {}
class OtpInitial extends OtpState {}
class OtpLoading extends OtpState {}
class OtpSuccess extends OtpState {}
class OtpError extends OtpState {
  final String message;
  OtpError(this.message);
}
```

## 🎨 Personalización de Estilos

### Tema Oscuro Personalizado

```dart
OtpInputField(
  length: 6,
  onCompleted: (code) => print(code),
  backgroundColor: const Color(0xFF1E293B),
  borderColor: const Color(0xFF334155),
  activeBorderColor: Colors.blue[400],
  textColor: Colors.white,
  borderRadius: 16,
  borderWidth: 3,
  fieldWidth: 60,
  fieldHeight: 70,
  spacing: 12,
)
```

### Tema Claro Personalizado

```dart
OtpInputField(
  length: 6,
  onCompleted: (code) => print(code),
  backgroundColor: Colors.grey[100],
  borderColor: Colors.grey[300],
  activeBorderColor: Colors.green,
  textColor: Colors.black,
  borderRadius: 8,
  borderWidth: 2,
)
```

### Adaptación Automática al Tema

El widget se adapta automáticamente al tema de la app si no proporcionas colores personalizados:

```dart
OtpInputField(
  length: 6,
  onCompleted: (code) => print(code),
  // Sin colores personalizados = usa el tema de la app
)
```

## ✨ Características

### ✅ Copiar y Pegar
- Detecta automáticamente cuando se pega texto
- Extrae solo los números
- Distribuye los dígitos en los campos correspondientes

```dart
// Usuario copia: "Tu código es: 123456"
// Resultado: [1][2][3][4][5][6]
```

### ✅ Navegación Inteligente
- Auto-avance al escribir
- Auto-retroceso al borrar
- Manejo de foco optimizado

### ✅ Validación
- Solo acepta dígitos numéricos
- Límite de 1 carácter por campo
- Validación en tiempo real

### ✅ Accesibilidad
- Soporte para lectores de pantalla
- Navegación por teclado
- Alto contraste
- Tamaños táctiles adecuados

## 🧪 Testing

### Test del Widget

```dart
testWidgets('OTP field handles paste correctly', (tester) async {
  String? completedCode;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: OtpInputField(
          onCompleted: (code) => completedCode = code,
        ),
      ),
    ),
  );
  
  // Simular pegado
  final firstField = find.byType(TextField).first;
  await tester.enterText(firstField, '123456');
  await tester.pump();
  
  expect(completedCode, '123456');
});
```

### Test de la Pantalla

```dart
testWidgets('OTP screen calls onVerify when complete', (tester) async {
  bool verifyCalled = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: OtpVerificationScreen(
        title: 'Test',
        subtitle: 'Test',
        description: 'Test',
        recipient: 'test@test.com',
        onVerify: (code) async {
          verifyCalled = true;
          return true;
        },
      ),
    ),
  );
  
  // Completar OTP
  // ...
  
  expect(verifyCalled, true);
});
```

## 🔄 Migración desde Auth

Si tenías el OTP en `features/auth/`, actualiza las importaciones:

**Antes:**
```dart
import '../widgets/otp_input_field.dart';
```

**Después:**
```dart
import '../../../../core/widgets/otp_input_field.dart';
// o usar el path completo:
import 'package:easy/core/widgets/otp_input_field.dart';
```

## 📝 Mejores Prácticas

1. **Usa OtpVerificationScreen para casos comunes**: Es más rápido y tiene UI completa
2. **Usa OtpInputField para casos personalizados**: Cuando necesitas UI completamente custom
3. **Siempre maneja errores**: Implementa `onError` para mejorar UX
4. **Proporciona feedback**: Usa loading states y mensajes claros
5. **Implementa límites**: Considera límite de intentos y tiempo de expiración

## 🚀 Próximas Mejoras

- [ ] Timer de expiración configurable
- [ ] Límite de intentos
- [ ] Animaciones de transición
- [ ] Vibración en error
- [ ] Soporte para códigos alfanuméricos
- [ ] Modo offline con códigos de respaldo

## 📄 Licencia

Este componente es parte del proyecto Easy y puede ser reutilizado libremente dentro de la aplicación.
