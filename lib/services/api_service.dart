import '../models/lesson.dart';

class ApiService {
  // Замените на реальный IP при подключении к Node.js/Python серверу
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Получить список всех пар
  Future<List<Lesson>> fetchSchedule() async {
    // В будущем здесь будет HTTP-запрос к серверу
    return [];
  }

  // Отправить новую пару на сервер (только преподаватель)
  Future<bool> addLesson(Lesson lesson) async {
    // В будущем здесь будет POST-запрос к серверу
    return true;
  }

  // Удалить пару на сервере (только преподаватель)
  Future<bool> deleteLesson(int id) async {
    // В будущем здесь будет DELETE-запрос к серверу
    return true;
  }
}