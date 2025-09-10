import 'package:flutter/material.dart' hide TextField;
import '../../../presentation/widgets/form_label.dart';
import '../widgets/finance_text_field.dart';
import '../widgets/finance_drop_down.dart';

class PurposeSection extends StatelessWidget {
  const PurposeSection({
    super.key,
    required this.selectedPurpose,
    this.customPurposeController,
    this.isDisabled = false,
    this.onPurposeChanged,
    this.onCustomPurposeChanged,
    required this.options,
  });

  final String selectedPurpose;
  final TextEditingController? customPurposeController;
  final bool isDisabled;
  final List<String> options;
  final ValueChanged<String>? onPurposeChanged;
  final ValueChanged<String>? onCustomPurposeChanged;

  @override
  Widget build(BuildContext context) {
    final dropdownValue =
    options.contains(selectedPurpose) ? selectedPurpose : 'その他';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel(
          text: '目的',
          icon: Icons.flag,
          iconColor: Color(0xFF0253B3),
        ),
        DropDown(
          options: options,
          answerStatus: isDisabled ? 1 : 0,
          selectedValue: dropdownValue,
          onChanged: (String? val) {
            if (isDisabled) return;
            final v = val ?? '';
            onPurposeChanged?.call(v);
            if (v != 'その他') customPurposeController?.clear();
          },
        ),
        if (dropdownValue == 'その他') ...[
          const SizedBox(height: 12),
          FinanceTextField(
            answerStatus: isDisabled ? 1 : 0,
            controller: customPurposeController,
            hintText: '具体的な目的を入力してください。',
            onChanged: (String val) {
              // 여기는 controller.text를 건드리지 않습니다!
              onCustomPurposeChanged?.call(val); // 상위에 값 전달 (필요 시)
            },
          ),
        ],
      ],
    );
  }
}
