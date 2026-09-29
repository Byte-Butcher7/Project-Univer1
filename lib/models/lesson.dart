class Lesson {
  final int? id;
  final String subjectName; // Название предмета (например, "Высшая математика")
  final String teacherName; // ФИО преподавателя
  final String classroom;   // Кабинет/аудитория (например, "304")
  final String dayOfWeek;   // День недели (например, "Понедельник")
  final String startTime;   // Время начала (например, "09:00")
  final String endTime;     // Время окончания (например, "10:30")

  Lesson({
    this.id,
    required this.subjectName,
    required this.teacherName,
    required this.classroom,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      subjectName: json['subject_name'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      classroom: json['classroom'] ?? '',
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'subject_name': subjectName,
      'teacher_name': teacherName,
      'classroom': classroom,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}