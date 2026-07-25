class AppConfig {
  // API Configuration
  static const String service =
      'https://api.example.com'; // TODO: Update with actual API URL
  static const String serviceEndPoint = '/api/v1';

  // Encryption keys for login
  static const String keyLogin =
      'YOUR_KEY_HERE'; // TODO: Update with actual key
  static const String ivLogin = 'YOUR_IV_HERE'; // TODO: Update with actual IV

  // Encryption keys for local storage
  static const String keyLocalLogin =
      'YOUR_LOCAL_KEY_HERE'; // TODO: Update with actual key
  static const String ivLocalLogin =
      'YOUR_LOCAL_IV_HERE'; // TODO: Update with actual IV

  // Storage keys
  static const String userStorageKey = 'user_data';
}
