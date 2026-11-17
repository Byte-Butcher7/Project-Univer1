class Homework {
  final int id;
  final int subjectId;
  final String subjectName;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isDone;
  final DateTime createdAt;

  const Homework({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isDone,
    required this.createdAt,
  });

  factory Homework.fromMap(Map<String, Object?> map) => Homework(
        id: map['id'] as int,
        subjectId: map['subject_id'] as int,
        subjectName: map['subject_name'] as String,
        title: map['title'] as String,
        description: (map['description'] as String?) ?? '',
        dueDate: DateTime.parse(map['due_date'] as String),
        isDone: (map['is_done'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
