class Lesson {
  final int id;
  final int subjectId;
  final String subjectName;
  final String teacherName;
  final String classroom;

  /// 1 = понедельник ... 6 = суббота
  final int dayOfWeek;
  final String startTime; // "08:30"
  final String endTime; // "10:00"

  const Lesson({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.teacherName,
    required this.classroom,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory Lesson.fromMap(Map<String, Object?> map) => Lesson(
        id: map['id'] as int,
        subjectId: map['subject_id'] as int,
        subjectName: map['subject_name'] as String,
        teacherName: map['teacher_name'] as String,
        classroom: map['classroom'] as String,
        dayOfWeek: map['day_of_week'] as int,
        startTime: map['start_time'] as String,
        endTime: map['end_time'] as String,
      );
}
