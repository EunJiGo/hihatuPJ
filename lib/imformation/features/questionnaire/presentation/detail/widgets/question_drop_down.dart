import 'package:flutter/material.dart';
import 'package:hihatu_project/utils/widgets/dropdown_option.dart';
import 'package:hihatu_project/utils/widgets/dropdown_widget.dart';
import 'package:hihatu_project/utils/widgets/modals/dropdown_modal_widget.dart';

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
    final isDisabled = answerStatus == 1;

    // ✅ List<String> → List<DropdownOption>
    final dropdownOptions = options
        .map((str) => DropdownOption.fromText(str))
        .toList();

    return DropdownTextFieldWidget(
      selectedValue: selectedValue,
      isDisabled: isDisabled,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        DropdownModalWidget.show(
          context: context,
          options: dropdownOptions,
          selectedValue: selectedValue,
          isSelectCircleIcon: true,
          onSelected: (val) => onChanged(val),
          selectedTextColor: const Color(0xFF1565C0),
          selectedIconColor: Colors.blueAccent,
          selectedBorderColor: const Color(0xFF64B5F6),
          selectedBackgroundColor: const Color(0xFFE3F2FD),
        );
      },

      // 💡 활성화 시 커스터마이징 가능한 색상
      iconColor: const Color(0xFF1565C0),
      textColor: Colors.black87,
      enabledBorderColor: const Color(0xFF6096D0),
      focusedBorderColor: const Color(0xFF42A5F5),
      fillColor: const Color(0xFFffffff),
      // fillColor: const Color(0xFFF0F7FF),
    );
  }
}
