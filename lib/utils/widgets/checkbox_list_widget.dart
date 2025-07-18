import 'package:flutter/material.dart';

class SelectableCheckboxList extends StatelessWidget {
  final List<String> options;
  final List<String?> checkedValues;
  final void Function(List<String?>) onChanged;
  final bool isDisabled;

  // ✅ 선택된 항목에 적용될 색상만 파라미터로 받기
  final Color selectedBackgroundColor;
  final Color selectedBorderColor;
  final Color selectedIconColor;
  final Color selectedTextColor;

  const SelectableCheckboxList({
    super.key,
    required this.options,
    required this.checkedValues,
    required this.onChanged,
    required this.isDisabled,
    required this.selectedBackgroundColor,
    required this.selectedBorderColor,
    required this.selectedIconColor,
    required this.selectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final currentCheckedList = List<String?>.from(checkedValues);
        final isChecked = currentCheckedList[index] != null;

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
            currentCheckedList[index] =
            isChecked ? null : option;
            onChanged(List.from(currentCheckedList));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.shade200
                  : isChecked
                  ? selectedBackgroundColor
                  : const Color(0xFFF9FBFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDisabled
                    ? Colors.grey.shade400
                    : isChecked
                    ? selectedBorderColor
                    : Colors.grey.shade300,
                width: isChecked ? 1.5 : 1,
              ),
              boxShadow: isChecked && !isDisabled
                  ? [
                BoxShadow(
                  color: selectedBorderColor.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  isChecked
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: isDisabled
                      ? Colors.grey.shade400
                      : isChecked
                      ? selectedIconColor
                      : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? Colors.grey
                          : isChecked
                          ? selectedTextColor
                          : Colors.black87,
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
