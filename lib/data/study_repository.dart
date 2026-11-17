import 'package:sqflite/sqflite.dart';

import '../core/format.dart';
import '../models/homework.dart';
import '../models/lesson.dart';
import 'database_helper.dart';

/// Расписание, предметы и домашние задания.
class StudyRepository {
  StudyRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  // ---------- Предметы ----------

  Future<List<String>> getSubjectNames() async {
    final db = await _helper.database;
    final rows = await db.query(
      'subjects',
      columns: ['name'],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Находит предмет по названию или создаёт новый.
  Future<int> _subjectId(DatabaseExecutor db, String name) async {
    final clean = name.trim();
    final rows = await db.query(
      'subjects',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [clean],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['id'] as int;
    return db.insert('subjects', {'name': clean});
  }

  // ---------- Расписание ----------

  Future<List<Lesson>> getLessons() async {
    final db = await _helper.database;
    final rows = await db.rawQuery('''
      SELECT l.id, l.subject_id, s.name AS subject_name, l.teacher_name,
             l.classroom, l.day_of_week, l.start_time, l.end_time
      FROM lessons l
      JOIN subjects s ON s.id = l.subject_id
      ORDER BY l.day_of_week, l.start_time
    ''');
    return rows.map(Lesson.fromMap).toList();
  }

  Future<void> addLesson({
    required String subjectName,
    required String teacherName,
    required String classroom,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int createdBy,
  }) async {
    final db = await _helper.database;
    await db.transaction((txn) async {
      final subjectId = await _subjectId(txn, subjectName);
      await txn.insert('lessons', {
        'subject_id': subjectId,
        'teacher_name': teacherName.trim(),
        'classroom': classroom.trim(),
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'created_by': createdBy,
      });
    });
  }

  Future<void> deleteLesson(int id) async {
    final db = await _helper.database;
    await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Домашние задания ----------

  /// Все ДЗ; поле is_done считается для конкретного пользователя.
  Future<List<Homework>> getHomework(int userId) async {
    final db = await _helper.database;
    final rows = await db.rawQuery('''
      SELECT h.id, h.subject_id, s.name AS subject_name, h.title,
             h.description, h.due_date, h.created_at,
             EXISTS(
               SELECT 1 FROM homework_done d
               WHERE d.homework_id = h.id AND d.user_id = ?
             ) AS is_done
      FROM homework h
      JOIN subjects s ON s.id = h.subject_id
      ORDER BY h.due_date ASC, h.id ASC
    ''', [userId]);
    return rows.map(Homework.fromMap).toList();
  }

  Future<void> addHomework({
    required String subjectName,
    required String title,
    required String description,
    required DateTime dueDate,
    required int createdBy,
  }) async {
    final db = await _helper.database;
    await db.transaction((txn) async {
      final subjectId = await _subjectId(txn, subjectName);
      await txn.insert('homework', {
        'subject_id': subjectId,
        'title': title.trim(),
        'description': description.trim(),
        'due_date': dateToDb(dueDate),
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> deleteHomework(int id) async {
    final db = await _helper.database;
    await db.delete('homework', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setHomeworkDone({
    required int userId,
    required int homeworkId,
    required bool done,
  }) async {
    final db = await _helper.database;
    if (done) {
      await db.insert(
        'homework_done',
        {'user_id': userId, 'homework_id': homeworkId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      await db.delete(
        'homework_done',
        where: 'user_id = ? AND homework_id = ?',
        whereArgs: [userId, homeworkId],
      );
    }
  }
}
