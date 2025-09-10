import 'package:flutter/material.dart';

class DropdownTextFieldWidget extends StatelessWidget {
  final String? selectedValue;
  final bool isDisabled;
  final VoidCallback onTap;

  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final Color iconColor;
  final Color textColor;
  final Color fillColor;

  const DropdownTextFieldWidget({
    super.key,
    required this.selectedValue,
    required this.isDisabled,
    required this.onTap,
    required this.enabledBorderColor,
    required this.focusedBorderColor,
    required this.iconColor,
    required this.textColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: selectedValue ?? '');

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isDisabled ? null : onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            color: isDisabled ? Colors.grey.shade600 : textColor,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            isDense: true, // 👈 높이를 줄여줌
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            // ↑ padding 직접 지정해서 세로/가로 여백 줄이기
            labelText: selectedValue != null ? null : '選択してください。',
            labelStyle: TextStyle(
              color: isDisabled ? Colors.grey.shade600 : textColor,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey.shade500 : enabledBorderColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey.shade500 : focusedBorderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: isDisabled ? Colors.grey.shade500 : iconColor,
            ),
            filled: true,
            fillColor: isDisabled
                ? Colors.white
                : (selectedValue == null ? Colors.white : fillColor),
          ),
        ),
      ),
    );
  }
}
