import '../core/constants.dart';

class User {
  final int id;
  final String username;
  final String role;

  const User({required this.id, required this.username, required this.role});

  bool get isTeacher => role == Roles.teacher;
  String get roleTitle => isTeacher ? 'Преподаватель' : 'Студент';

  factory User.fromMap(Map<String, Object?> map) => User(
        id: map['id'] as int,
        username: map['username'] as String,
        role: map['role'] as String,
      );
}
