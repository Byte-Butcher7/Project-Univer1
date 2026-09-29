import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';
import 'login_screen.dart';

class StudentScheduleScreen extends StatefulWidget {
  final String username;

  const StudentScheduleScreen({Key? key, required this.username})
      : super(key: key);

  @override
  State<StudentScheduleScreen> createState() =>
      _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
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
    Lesson(
      id: 2,
      subjectName: 'Программирование',
      teacherName: 'Петров П.П.',
      classroom: '412',
      dayOfWeek: 'Понедельник',
      startTime: '10:15',
      endTime: '11:45',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _lessons
        .where((lesson) => lesson.dayOfWeek == _selectedDay)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username} (Студент)'),
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
                      'На $_selectedDay пар нет 🎉',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLessons.length,
                    itemBuilder: (context, index) {
                      return LessonCard(lesson: filteredLessons[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}