class User {
  final int id;
  final String username;
  final String role; // 'student' или 'teacher'

  User({
    required this.id,
    required this.username,
    required this.role,
  });

  // Преобразование из JSON (когда получим данные с сервера)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
    );
  }

  // Преобразование в JSON (для отправки на сервер)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
    };
  }
}