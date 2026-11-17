import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/study_repository.dart';
import '../data/user_repository.dart';
import '../models/homework.dart';
import '../models/lesson.dart';
import '../models/user.dart';

/// Единый источник данных для всех экранов.
class AppState extends ChangeNotifier {
  AppState({UserRepository? users, StudyRepository? study})
      : _users = users ?? UserRepository(),
        _study = study ?? StudyRepository();

  static const String _sessionKey = 'session_user_id';

  final UserRepository _users;
  final StudyRepository _study;

  User? _user;
  bool _initializing = true;
  List<Lesson> _lessons = const [];
  List<Homework> _homework = const [];
  List<String> _subjects = const [];

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isTeacher => _user?.isTeacher ?? false;
  bool get initializing => _initializing;

  List<Lesson> get lessons => _lessons;
  List<Homework> get homework => _homework;
  List<String> get subjects => _subjects;

  List<Lesson> lessonsForDay(int day) =>
      _lessons.where((l) => l.dayOfWeek == day).toList();

  // ---------- Сессия ----------

  /// Восстанавливает вход после перезапуска приложения.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt(_sessionKey);
      if (id != null) {
        final user = await _users.getById(id);
        if (user != null) {
          _user = user;
          await _loadData();
        } else {
          await prefs.remove(_sessionKey);
        }
      }
    } catch (e) {
      debugPrint('Не удалось восстановить сессию: $e');
    }
    _initializing = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final user = await _users.login(username, password);
    await _startSession(user);
  }

  Future<void> register({
    required String username,
    required String password,
    required String role,
    String? teacherCode,
  }) async {
    if (role == Roles.teacher && teacherCode?.trim() != AppConfig.teacherCode) {
      throw const AuthException('Неверный код преподавателя');
    }
    final user = await _users.register(
      username: username,
      password: password,
      role: role,
    );
    await _startSession(user);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _user = null;
    _lessons = const [];
    _homework = const [];
    _subjects = const [];
    notifyListeners();
  }

  Future<void> _startSession(User user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, user.id);
    await _loadData();
    notifyListeners();
  }

  // ---------- Данные ----------

  Future<void> refresh() async {
    await _loadData();
    notifyListeners();
  }

  Future<void> _loadData() async {
    final user = _user;
    if (user == null) return;
    _lessons = await _study.getLessons();
    _homework = await _study.getHomework(user.id);
    _subjects = await _study.getSubjectNames();
  }

  void _requireTeacher() {
    if (!isTeacher) throw const AuthException('Недостаточно прав');
  }

  Future<void> addLesson({
    required String subjectName,
    required String teacherName,
    required String classroom,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    _requireTeacher();
    await _study.addLesson(
      subjectName: subjectName,
      teacherName: teacherName,
      classroom: classroom,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      createdBy: _user!.id,
    );
    await refresh();
  }

  Future<void> deleteLesson(int id) async {
    _requireTeacher();
    await _study.deleteLesson(id);
    await refresh();
  }

  Future<void> addHomework({
    required String subjectName,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    _requireTeacher();
    await _study.addHomework(
      subjectName: subjectName,
      title: title,
      description: description,
      dueDate: dueDate,
      createdBy: _user!.id,
    );
    await refresh();
  }

  Future<void> deleteHomework(int id) async {
    _requireTeacher();
    await _study.deleteHomework(id);
    await refresh();
  }

  Future<void> setHomeworkDone(int homeworkId, bool done) async {
    final user = _user;
    if (user == null) return;
    await _study.setHomeworkDone(
      userId: user.id,
      homeworkId: homeworkId,
      done: done,
    );
    await refresh();
  }
}
