import 'package:flutter/material.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// 05.03.2026
String formatDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

/// 2026-03-05 — формат хранения в базе.
String dateToDb(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// 08:30
String formatTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

int timeToMinutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// Сколько календарных дней от сегодня до [date] (отрицательное — в прошлом).
int daysUntil(DateTime date) {
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final target = DateTime.utc(date.year, date.month, date.day);
  return target.difference(today).inDays;
}

String dueLabel(DateTime due) {
  final days = daysUntil(due);
  if (days < 0) return 'Просрочено, ${formatDate(due)}';
  if (days == 0) return 'Сдать сегодня';
  if (days == 1) return 'Сдать завтра';
  return 'Сдать до ${formatDate(due)}';
}
