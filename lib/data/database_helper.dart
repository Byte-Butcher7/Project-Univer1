import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Открывает SQLite-базу и создаёт таблицы при первом запуске.
///
/// Таблицы:
///  - users          — логины, соль и хеш пароля, роль
///  - subjects       — предметы
///  - lessons        — расписание (ссылается на subjects)
///  - homework       — домашние задания по предметам
///  - homework_done  — какие ДЗ отметил выполненными каждый пользователь
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'study_app.db';
  static const int _dbVersion = 1;

  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        username      TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        salt          TEXT NOT NULL,
        role          TEXT NOT NULL CHECK (role IN ('student', 'teacher')),
        created_at    TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE subjects (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE
      )
    ''');

    batch.execute('''
      CREATE TABLE lessons (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id   INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
        teacher_name TEXT NOT NULL,
        classroom    TEXT NOT NULL,
        day_of_week  INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
        start_time   TEXT NOT NULL,
        end_time     TEXT NOT NULL,
        created_by   INTEGER REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE homework (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id  INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
        title       TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        due_date    TEXT NOT NULL,
        created_by  INTEGER REFERENCES users(id) ON DELETE SET NULL,
        created_at  TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE homework_done (
        user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        homework_id INTEGER NOT NULL REFERENCES homework(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, homework_id)
      )
    ''');

    batch.execute('CREATE INDEX idx_lessons_day ON lessons(day_of_week, start_time)');
    batch.execute('CREATE INDEX idx_homework_subject ON homework(subject_id)');
    batch.execute('CREATE INDEX idx_homework_due ON homework(due_date)');

    await batch.commit(noResult: true);
  }
}
