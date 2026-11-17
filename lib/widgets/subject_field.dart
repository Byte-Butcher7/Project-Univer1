import 'package:flutter/material.dart';

/// Поле предмета с подсказками из уже существующих предметов.
/// Можно ввести и новое название — предмет создастся при сохранении.
class SubjectField extends StatelessWidget {
  const SubjectField({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return options;
        return options.where((o) => o.toLowerCase().contains(query));
      },
      onSelected: onChanged,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Предмет',
            prefixIcon: Icon(Icons.menu_book_outlined),
            helperText: 'Выберите из списка или введите новый',
          ),
          onChanged: onChanged,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Укажите предмет' : null,
        );
      },
    );
  }
}
