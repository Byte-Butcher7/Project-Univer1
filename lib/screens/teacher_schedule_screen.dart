import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';
import 'add_lesson_screen.dart';
import 'login_screen.dart';

class TeacherScheduleScreen extends StatefulWidget {
  final String username;

  const TeacherScheduleScreen({Key? key, required this.username})
      : super(key: key);

  @override
  State<TeacherScheduleScreen> createState() =>
      _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  String _selectedDay = 'Понедельник';

  final List<String> _days = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];

  final List<Lesson> _lessons = [
    Lesson(
      id: 1,
      subjectName: 'Высшая математика',
      teacherName: 'Иванов И.И.',
      classroom: '304',
      dayOfWeek: 'Понедельник',
      startTime: '08:30',
      endTime: '10:00',
    ),
  ];

  void _deleteLesson(int? id) {
    if (id == null) return;
    setState(() {
      _lessons.removeWhere((lesson) => lesson.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пара удалена')),
    );
  }

  void _navigateToAddLesson() async {
    final newLesson = await Navigator.push<Lesson>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLessonScreen(),
      ),
    );

    if (newLesson != null) {
      setState(() {
        _lessons.add(newLesson);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новая пара добавлена!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _lessons
        .where((lesson) => lesson.dayOfWeek == _selectedDay)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username} (Преподаватель)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final isSelected = day == _selectedDay;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDay = day;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filteredLessons.isEmpty
                ? Center(
                    child: Text(
                      'На $_selectedDay пар пока нет',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLessons.length,
                    itemBuilder: (context, index) {
                      final lesson = filteredLessons[index];
                      return LessonCard(
                        lesson: lesson,
                        onDelete: () => _deleteLesson(lesson.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddLesson,
        icon: const Icon(Icons.add),
        label: const Text('Добавить пару'),
      ),
    );
  }
}