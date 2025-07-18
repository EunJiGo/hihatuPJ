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
            color: isDisabled ? Colors.grey.shade500 : textColor,
          ),
          decoration: InputDecoration(
            labelText: selectedValue != null ? null : '選択してください。',
            labelStyle: TextStyle(
              color: isDisabled ? Colors.grey : textColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey.shade400 : enabledBorderColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDisabled ? Colors.grey.shade400 : focusedBorderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: isDisabled ? Colors.grey : iconColor,
            ),
            filled: true,
            fillColor: isDisabled
                ? Colors.grey.shade200
                : (selectedValue == null ? Colors.white : fillColor),
          ),
        ),
      ),
    );
  }
}
