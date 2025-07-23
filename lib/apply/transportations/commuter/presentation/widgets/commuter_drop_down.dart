import 'package:flutter/material.dart';
import '../../../../../../../../utils/widgets/dropdown_widget.dart';
import '../../../../../../../../utils/widgets/modals/dropdown_modal_widget.dart';

class CommuterDropDown extends StatelessWidget {
  final List<String> options;
  final int answerStatus;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const CommuterDropDown({
    super.key,
    required this.options,
    required this.answerStatus,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = answerStatus == 1;

    return DropdownTextFieldWidget(
      selectedValue: selectedValue,
      isDisabled: isDisabled,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        DropdownModalWidget.show(
          context: context,
          options: options,
          selectedValue: selectedValue,
          onSelected: (val) => onChanged(val),
          selectedTextColor: const Color(0xFF66BB6A),
          selectedIconColor: const Color(0xFF81C784),
          selectedBorderColor: const Color(0xFFA4D65C),
          selectedBackgroundColor: const Color(0xFFFCFFF0),
        );
      },

      // 💡 활성화 시 커스터마이징 가능한 색상
      iconColor: const Color(0xFF66BB6A), // 0xFF4CAF50  0xFF388E3C
      textColor: Colors.black87,
      enabledBorderColor: const Color(0xFF81C784),
      focusedBorderColor: const Color(0xFFB8EF4F),
      fillColor: const Color(0xFFFCFFF0),
    );
  }
}
