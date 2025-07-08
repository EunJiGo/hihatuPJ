import 'package:flutter/material.dart';

class QuestionCheckboxList extends StatelessWidget {
  final List<String> options;
  final int answerStatus;
  final List<String?> checkedValues;
  final void Function(List<String?>) onChanged;

  const QuestionCheckboxList({
    super.key,
    required this.options,
    required this.answerStatus,
    required this.checkedValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final optIndex = entry.key;
        final opt = entry.value;
        final checkedList = List<String?>.from(checkedValues);

        return CheckboxListTile(
          title: Text(opt),
          value: checkedList[optIndex] != null,
          onChanged: answerStatus == 1
              ? null
              : (bool? checked) {
            if (checked == null) return;
            checkedList[optIndex] = checked ? opt : null;
            onChanged(List.from(checkedList));
          },
        );
      }).toList(),
    );
  }
}
