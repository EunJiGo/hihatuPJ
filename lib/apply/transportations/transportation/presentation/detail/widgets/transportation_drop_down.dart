import 'package:flutter/material.dart';
import '../../../../../../../../utils/widgets/dropdown_widget.dart';
import '../../../../../../../../utils/widgets/modals/dropdown_modal_widget.dart';
import '../../../../../../utils/widgets/dropdown_option.dart';

class TransportationDropDown extends StatelessWidget {
  final List<String> options;
  final int answerStatus;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const TransportationDropDown({
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
          selectedTextColor: const Color(0xFFfea643),
          selectedIconColor: const Color(0xFFfea643),
          selectedBorderColor: const Color(0xFFffcc00),
          selectedBackgroundColor: const Color(0xFFfefcfa),
        );
      },

      // 💡 활성화 시 커스터마이징 가능한 색상
      iconColor: const Color(0xFFfea643), // 0xFF4CAF50  0xFF388E3C
      textColor: Colors.black87,
      enabledBorderColor: const Color(0xFFfea643),
      focusedBorderColor: const Color(0xFFffcc00),
      fillColor: const Color(0xFFfef7f0),
    );
  }
}
