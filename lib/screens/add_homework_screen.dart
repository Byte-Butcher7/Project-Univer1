import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../providers/app_state.dart';
import '../widgets/subject_field.dart';

class AddHomeworkScreen extends StatefulWidget {
  const AddHomeworkScreen({super.key});

  @override
  State<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _dueCtl = TextEditingController();

  String _subject = '';
  DateTime? _due;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _due = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    _dueCtl.text = formatDate(_due!);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    _dueCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 2)),
      helpText: 'Срок сдачи',
    );
    if (picked == null) return;
    setState(() {
      _due = picked;
      _dueCtl.text = formatDate(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    try {
      await state.addHomework(
        subjectName: _subject,
        title: _titleCtl.text,
        description: _descCtl.text,
        dueDate: _due!,
      );
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Задание добавлено')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить задание. Попробуйте ещё раз.')),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.read<AppState>().subjects;

    return Scaffold(
      appBar: AppBar(title: const Text('Новое задание')),
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
                controller: _titleCtl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Что нужно сделать',
                  prefixIcon: Icon(Icons.edit_note_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Опишите задание кратко'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtl,
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Подробности (необязательно)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dueCtl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Срок сдачи',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Выберите дату' : null,
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
                    : const Text('Сохранить задание'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
