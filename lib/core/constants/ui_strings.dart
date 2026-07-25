/// UI text constants for the application
/// Consider moving these to i18n files for internationalization
class UIStrings {
  UIStrings._(); // Private constructor to prevent instantiation

  // Image loading states
  static const String loadingImage = 'Cargando imagen...';
  static const String imageLoadError = 'Error al cargar imagen';

  // Login screen
  static const String welcomeBack = 'Bienvenido de nuevo';
  static const String loginSubtitle =
      'Inicia sesión para encontrar tu próximo empleo';
  static const String emailLabel = 'Correo electrónico';
  static const String emailHint = 'tucorreo@ejemplo.com';
  static const String passwordLabel = 'Contraseña';
  static const String passwordHint = '••••••••';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String loginButton = 'Iniciar sesión';
  static const String createAccount = 'Crear cuenta';

  // Validation messages
  static const String emailRequired = 'Ingresa tu correo electrónico';
  static const String emailInvalid = 'Ingresa un correo válido';
  static const String passwordRequired = 'Ingresa tu contraseña';

  // App info
  static const String appName = 'EASY';
  static const String appTagline = 'publish, search and hire';
  static const String appVersion = 'v1.0 · Easy Inc.';
}
