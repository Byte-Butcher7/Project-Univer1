import 'package:flutter_test/flutter_test.dart';
import 'package:study_app/services/password_hasher.dart';

void main() {
  test('пароль хранится как хеш с солью и проверяется', () {
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash('secret123', salt);

    expect(hash, isNot('secret123'));
    expect(PasswordHasher.verify('secret123', salt, hash), isTrue);
    expect(PasswordHasher.verify('wrong-pass', salt, hash), isFalse);
  });

  test('одинаковые пароли с разной солью дают разные хеши', () {
    final a = PasswordHasher.hash('secret123', PasswordHasher.generateSalt());
    final b = PasswordHasher.hash('secret123', PasswordHasher.generateSalt());
    expect(a, isNot(b));
  });
}
