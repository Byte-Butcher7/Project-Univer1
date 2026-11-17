import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import 'add_homework_screen.dart';
import 'add_lesson_screen.dart';
import 'homework_tab.dart';
import 'schedule_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  Future<void> _logout() async {
    final state = context.read<AppState>();
    final ok = await confirmDialog(
      context,
      title: 'Выйти из аккаунта?',
      message: 'Данные сохранятся, при следующем входе всё будет на месте.',
      confirmText: 'Выйти',
    );
    if (ok) await state.logout();
  }

  void _openAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _tab == 0 ? const AddLessonScreen() : const AddHomeworkScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('StudyApp'),
            Text(
              '${user.username} · ${user.roleTitle}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Выйти',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [ScheduleTab(), HomeworkTab()],
      ),
      floatingActionButton: user.isTeacher
          ? FloatingActionButton.extended(
              onPressed: _openAddScreen,
              icon: const Icon(Icons.add_rounded),
              label: Text(_tab == 0 ? 'Добавить пару' : 'Добавить задание'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Домашние задания',
          ),
        ],
      ),
    );
  }
}
