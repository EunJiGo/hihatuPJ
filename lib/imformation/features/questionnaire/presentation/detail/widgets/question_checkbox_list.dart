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
        final isChecked = checkedList[optIndex] != null;

        return GestureDetector(
          onTap: answerStatus == 1
              ? null
              : () {
            checkedList[optIndex] = isChecked ? null : opt;
            onChanged(List.from(checkedList));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFFE3F2FD) : const Color(0xFFF9FBFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isChecked ? const Color(0xFF64B5F6) : Colors.grey.shade300,
                width: isChecked ? 2 : 1,
              ),
              boxShadow: isChecked
                  ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: isChecked ? const Color(0xFF1565C0) : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isChecked ? const Color(0xFF1565C0) : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
