import '../../../../core/constants/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../models/auth_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> signIn({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Encrypt credentials before sending
      final encryptedEmail = CryptoUtils.encryptBi(
        email.trim(),
        AppConfig.keyLogin,
        AppConfig.ivLogin,
      );

      final encryptedPassword = CryptoUtils.encryptBi(
        password.trim(),
        AppConfig.keyLogin,
        AppConfig.ivLogin,
      );

      final response = await apiClient.post('login', {
        'email': encryptedEmail,
        'password': encryptedPassword,
      });

      final authResponse = AuthResponseModel.fromJson(response);

      if (authResponse.status == 500 || authResponse.data == null) {
        throw Exception(authResponse.message ?? 'Login failed');
      }

      return AuthModel.fromJson(authResponse.data);
    } catch (e) {
      throw Exception('Remote data source error: $e');
    }
  }
}
