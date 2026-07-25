import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoUtils {
  /// Encrypts text using AES encryption
  static String encryptBi(String text, String keyString, String ivString) {
    try {
      final key = encrypt.Key.fromUtf8(keyString.padRight(32).substring(0, 32));
      final iv = encrypt.IV.fromUtf8(ivString.padRight(16).substring(0, 16));

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final encrypted = encrypter.encrypt(text, iv: iv);

      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypts text using AES encryption
  static String decryptBi(
    String encryptedText,
    String keyString,
    String ivString,
  ) {
    try {
      final key = encrypt.Key.fromUtf8(keyString.padRight(32).substring(0, 32));
      final iv = encrypt.IV.fromUtf8(ivString.padRight(16).substring(0, 16));

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);

      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Generates MD5 hash
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}
