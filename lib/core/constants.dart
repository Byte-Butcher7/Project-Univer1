/// Дни недели: индекс + 1 совпадает с DateTime.weekday (1 = понедельник).
const List<String> kDays = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
];

const List<String> kDaysShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

class Roles {
  Roles._();
  static const String student = 'student';
  static const String teacher = 'teacher';
}

class AppConfig {
  AppConfig._();

  /// Код, который нужно ввести при регистрации преподавателя.
  /// Поменяйте на свой, чтобы студенты не могли стать преподавателями.
  static const String teacherCode = 'TEACHER2026';

  static const int minUsernameLength = 3;
  static const int minPasswordLength = 6;
}
