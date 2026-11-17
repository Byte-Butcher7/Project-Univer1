import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../theme/app_theme.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.lesson, this.onDelete});

  final Lesson lesson;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: AppColors.accent),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.startTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.endTime,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.outline),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lesson.subjectName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.person_outline,
                      text: lesson.teacherName,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.meeting_room_outlined,
                      text: 'Аудитория ${lesson.classroom}',
                    ),
                  ],
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.danger,
                tooltip: 'Удалить пару',
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.muted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
