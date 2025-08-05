import 'package:flutter/material.dart';
import '../../../../../../../../utils/widgets/dropdown_widget.dart';
import '../../../../../../../../utils/widgets/modals/dropdown_modal_widget.dart';
import '../../../../../utils/widgets/dropdown_option.dart';

class OtherExpenseDropDown extends StatelessWidget {
  final List<String> options;
  final int answerStatus;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const OtherExpenseDropDown({
    super.key,
    required this.options,
    required this.answerStatus,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = answerStatus == 1;
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
          onSelected: (val) => onChanged(val),
          selectedTextColor: const Color(0xFF89e6f4),
          selectedIconColor: const Color(0xFF00acc6),
          selectedBorderColor: const Color(0xFF01dcfd),
          selectedBackgroundColor: const Color(0xFFebf8fd),
        );
      },

      // 💡 활성화 시 커스터마이징 가능한 색상
      iconColor: const Color(0xFF00acc6), // 0xFF4CAF50  0xFF388E3C
      textColor: Colors.black87,
      enabledBorderColor: const Color(0xFF89e6f4),
      focusedBorderColor: const Color(0xFF01dcfd),
      fillColor: const Color(0xFFebf8fd),
    );
  }
}
