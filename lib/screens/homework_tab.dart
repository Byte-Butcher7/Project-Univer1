import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_pill.dart';
import '../widgets/homework_card.dart';

class HomeworkTab extends StatefulWidget {
  const HomeworkTab({super.key});

  @override
  State<HomeworkTab> createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  /// null — показывать все предметы.
  String? _subject;

  Future<void> _delete(int id, String title) async {
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: 'Удалить задание?',
      message: 'Задание «$title» будет удалено у всех.',
    );
    if (!ok) return;
    await state.deleteHomework(id);
    messenger.showSnackBar(const SnackBar(content: Text('Задание удалено')));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final all = state.homework;

    final subjects = {for (final h in all) h.subjectName}.toList()..sort();
    final selected = subjects.contains(_subject) ? _subject : null;
    final items = selected == null
        ? all
        : all.where((h) => h.subjectName == selected).toList();

    final doneCount = all.where((h) => h.isDone).length;

    return Column(
      children: [
        if (subjects.isNotEmpty)
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: subjects.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return FilterPill(
                    label: 'Все',
                    selected: selected == null,
                    onTap: () => setState(() => _subject = null),
                  );
                }
                final name = subjects[i - 1];
                return FilterPill(
                  label: name,
                  selected: selected == name,
                  onTap: () => setState(() => _subject = name),
                );
              },
            ),
          ),
        if (!state.isTeacher && all.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Text(
                  'Выполнено $doneCount из ${all.length}',
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: all.isEmpty ? 0 : doneCount / all.length,
                      minHeight: 6,
                      backgroundColor: AppColors.outline,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surfaceHigh,
            onRefresh: state.refresh,
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: EmptyState(
                          icon: Icons.task_alt_outlined,
                          title: 'Заданий пока нет',
                          hint: state.isTeacher
                              ? 'Нажмите «Добавить задание», чтобы задать ДЗ по предмету.'
                              : 'Когда преподаватель добавит ДЗ, оно появится здесь.',
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final hw = items[i];
                      return HomeworkCard(
                        homework: hw,
                        onToggle: state.isTeacher
                            ? null
                            : (done) => state.setHomeworkDone(hw.id, done),
                        onDelete: state.isTeacher
                            ? () => _delete(hw.id, hw.title)
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
