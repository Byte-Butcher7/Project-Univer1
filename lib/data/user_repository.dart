import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../services/password_hasher.dart';
import 'database_helper.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class UserRepository {
  UserRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<User> register({
    required String username,
    required String password,
    required String role,
  }) async {
    final db = await _helper.database;
    final name = username.trim();
    final salt = PasswordHasher.generateSalt();

    try {
      final id = await db.insert(
        'users',
        {
          'username': name,
          'password_hash': PasswordHasher.hash(password, salt),
          'salt': salt,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return User(id: id, username: name, role: role);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const AuthException('Этот логин уже занят. Выберите другой.');
      }
      rethrow;
    }
  }

  Future<User> login(String username, String password) async {
    final db = await _helper.database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AuthException('Неверный логин или пароль');
    }
    final row = rows.first;
    final ok = PasswordHasher.verify(
      password,
      row['salt'] as String,
      row['password_hash'] as String,
    );
    if (!ok) throw const AuthException('Неверный логин или пароль');
    return User.fromMap(row);
  }

  Future<User?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      'users',
      columns: ['id', 'username', 'role'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : User.fromMap(rows.first);
  }
}
