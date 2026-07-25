/// Constants for external assets URLs and local asset paths
class AssetsConstants {
  AssetsConstants._(); // Private constructor to prevent instantiation

  // External Assets (AWS S3, CDN, etc.)
  static const String s3BaseUrl =
      'https://easyappstore.s3.us-east-2.amazonaws.com';

  // Authentication assets
  static const String loginImageUrl = '$s3BaseUrl/assets/easy_login.png';

  // Local Assets paths (uncomment and add as needed)
  // static const String localImagesPath = 'assets/img/';
  // static const String localIconsPath = 'assets/icons/';
  // static const String localI18nPath = 'assets/i18n/';
}
