import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_pill.dart';
import '../widgets/lesson_card.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  /// 1 = понедельник ... 6 = суббота. В воскресенье открываем понедельник.
  late int _day = DateTime.now().weekday > 6 ? 1 : DateTime.now().weekday;

  Future<void> _delete(int id, String subject) async {
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: 'Удалить пару?',
      message: 'Пара «$subject» будет удалена из расписания.',
    );
    if (!ok) return;
    await state.deleteLesson(id);
    messenger.showSnackBar(const SnackBar(content: Text('Пара удалена')));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lessons = state.lessonsForDay(_day);

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: kDaysShort.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => FilterPill(
              label: kDaysShort[i],
              selected: _day == i + 1,
              onTap: () => setState(() => _day = i + 1),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Text(
                kDays[_day - 1],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Text(
                'Пар: ${lessons.length}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surfaceHigh,
            onRefresh: state.refresh,
            child: lessons.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: EmptyState(
                          icon: Icons.event_available_outlined,
                          title: 'В этот день пар нет',
                          hint: state.isTeacher
                              ? 'Нажмите «Добавить пару», чтобы заполнить расписание.'
                              : null,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: lessons.length,
                    itemBuilder: (context, i) {
                      final lesson = lessons[i];
                      return LessonCard(
                        lesson: lesson,
                        onDelete: state.isTeacher
                            ? () => _delete(lesson.id, lesson.subjectName)
                            : null,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
