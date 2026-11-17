import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Хеширование паролей: случайная соль + SHA-256, многократно повторённый.
/// Пароль в базе в открытом виде не хранится.
class PasswordHasher {
  PasswordHasher._();

  static const int _rounds = 10000;

  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    final saltBytes = utf8.encode(salt);
    var digest = sha256.convert([...saltBytes, ...utf8.encode(password)]);
    for (var i = 0; i < _rounds; i++) {
      digest = sha256.convert([...digest.bytes, ...saltBytes]);
    }
    return digest.toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    final actual = hash(password, salt);
    if (actual.length != expectedHash.length) return false;
    // Сравнение без раннего выхода.
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return diff == 0;
  }
}
