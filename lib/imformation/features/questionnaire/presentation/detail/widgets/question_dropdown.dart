// 드롭다운 타입 질문 UI

import 'package:flutter/material.dart';

class QuestionDropdown extends StatelessWidget {
  final List<String> options;
  final int answerStatus;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const QuestionDropdown({
    super.key,
    required this.options,
    required this.answerStatus,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: (selectedValue != null && options.contains(selectedValue)) ? selectedValue : null,
      items: options.toSet().map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: answerStatus == 1 ? null : onChanged,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '選択してください',
      ),
    );
  }
}
