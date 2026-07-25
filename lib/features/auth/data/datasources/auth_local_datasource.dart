import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../models/auth_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthModel> getCachedUser();
  Future<bool> cacheUser(AuthModel authModel);
  Future<bool> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AuthModel> getCachedUser() async {
    try {
      final encryptedData = sharedPreferences.getString(
        AppConfig.userStorageKey,
      );

      if (encryptedData == null || encryptedData.isEmpty) {
        throw Exception('No cached user found');
      }

      // Decrypt the data
      final decryptedData = CryptoUtils.decryptBi(
        encryptedData,
        AppConfig.keyLocalLogin,
        AppConfig.ivLocalLogin,
      );

      final jsonData = jsonDecode(decryptedData) as Map<String, dynamic>;
      return AuthModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to get cached user: $e');
    }
  }

  @override
  Future<bool> cacheUser(AuthModel authModel) async {
    try {
      // Convert model to JSON
      final jsonData = authModel.toJson();
      final jsonString = jsonEncode(jsonData);

      // Encrypt the data
      final encryptedData = CryptoUtils.encryptBi(
        jsonString,
        AppConfig.keyLocalLogin,
        AppConfig.ivLocalLogin,
      );

      // Save to shared preferences
      return await sharedPreferences.setString(
        AppConfig.userStorageKey,
        encryptedData,
      );
    } catch (e) {
      throw Exception('Failed to cache user: $e');
    }
  }

  @override
  Future<bool> clearCache() async {
    try {
      return await sharedPreferences.remove(AppConfig.userStorageKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }
}
