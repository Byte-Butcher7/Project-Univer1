import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/format.dart';
import '../providers/app_state.dart';
import '../widgets/filter_pill.dart';
import '../widgets/subject_field.dart';

class AddLessonScreen extends StatefulWidget {
  const AddLessonScreen({super.key});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _teacherCtl;
  final _classroomCtl = TextEditingController();
  final _startCtl = TextEditingController();
  final _endCtl = TextEditingController();

  String _subject = '';
  int _day = DateTime.now().weekday > 6 ? 1 : DateTime.now().weekday;
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _teacherCtl = TextEditingController(
      text: context.read<AppState>().currentUser?.username ?? '',
    );
  }

  @override
  void dispose() {
    _teacherCtl.dispose();
    _classroomCtl.dispose();
    _startCtl.dispose();
    _endCtl.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = (isStart ? _start : _end) ??
        (isStart ? const TimeOfDay(hour: 8, minute: 30) : const TimeOfDay(hour: 10, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? 'Начало пары' : 'Конец пары',
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        _startCtl.text = formatTime(picked);
      } else {
        _end = picked;
        _endCtl.text = formatTime(picked);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    if (timeToMinutes(_endCtl.text) <= timeToMinutes(_startCtl.text)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Конец пары должен быть позже начала')),
      );
      return;
    }

    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    try {
      await state.addLesson(
        subjectName: _subject,
        teacherName: _teacherCtl.text,
        classroom: _classroomCtl.text,
        dayOfWeek: _day,
        startTime: _startCtl.text,
        endTime: _endCtl.text,
      );
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Пара добавлена')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить пару. Попробуйте ещё раз.')),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.read<AppState>().subjects;

    return Scaffold(
      appBar: AppBar(title: const Text('Новая пара')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SubjectField(
                options: subjects,
                onChanged: (v) => _subject = v,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _teacherCtl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Преподаватель',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Укажите преподавателя'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _classroomCtl,
                decoration: const InputDecoration(
                  labelText: 'Аудитория',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Укажите аудиторию'
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                'День недели',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < kDays.length; i++)
                    FilterPill(
                      label: kDays[i],
                      selected: _day == i + 1,
                      onTap: () => setState(() => _day = i + 1),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startCtl,
                      readOnly: true,
                      onTap: () => _pickTime(isStart: true),
                      decoration: const InputDecoration(
                        labelText: 'Начало',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Выберите' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endCtl,
                      readOnly: true,
                      onTap: () => _pickTime(isStart: false),
                      decoration: const InputDecoration(
                        labelText: 'Конец',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Выберите' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Сохранить пару'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
