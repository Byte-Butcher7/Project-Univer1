import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/homework.dart';
import '../theme/app_theme.dart';

class HomeworkCard extends StatelessWidget {
  const HomeworkCard({
    super.key,
    required this.homework,
    this.onToggle,
    this.onDelete,
  });

  final Homework homework;

  /// Не null — показываем чекбокс «выполнено» (для студента).
  final ValueChanged<bool>? onToggle;

  /// Не null — показываем кнопку удаления (для преподавателя).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = homework.isDone;
    final days = daysUntil(homework.dueDate);
    final overdue = !done && days < 0;

    final Color dueColor = done
        ? AppColors.muted
        : overdue
            ? AppColors.danger
            : days <= 1
                ? AppColors.accent
                : AppColors.muted;

    return Opacity(
      opacity: done ? 0.55 : 1,
      child: Card(
        child: Padding(
          padding: EdgeInsets.fromLTRB(onToggle != null ? 4 : 16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onToggle != null)
                Checkbox(
                  value: done,
                  onChanged: (v) => onToggle!(v ?? false),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Tag(
                          text: homework.subjectName,
                          color: AppColors.accent,
                          icon: Icons.menu_book_outlined,
                        ),
                        _Tag(
                          text: dueLabel(homework.dueDate),
                          color: dueColor,
                          icon: Icons.event_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      homework.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (homework.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        homework.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.danger,
                  tooltip: 'Удалить задание',
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color, required this.icon});

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
