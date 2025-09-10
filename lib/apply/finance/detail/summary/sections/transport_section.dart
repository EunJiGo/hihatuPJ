import 'package:flutter/material.dart';
import '../../../presentation/widgets/form_label.dart';
import '../widgets/finance_text_field.dart';
import '../widgets/finance_drop_down.dart';

class TransportSection extends StatelessWidget {
  const TransportSection({
    super.key,
    required this.selectedTransport,
    this.customTransportController,
    this.isDisabled = false,
    this.onCustomTransportChanged,
    this.onTransportChanged,
    required this.options,
  });

  final String selectedTransport;
  final TextEditingController? customTransportController;
  final bool isDisabled;
  final List<String> options;
  final ValueChanged<String>? onTransportChanged;
  final ValueChanged<String>? onCustomTransportChanged;

  @override
  Widget build(BuildContext context) {
    final dropdownValue =
    options.contains(selectedTransport) ? selectedTransport : 'その他';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel(
          text: '交通手段',
          icon: Icons.directions_transit,
          iconColor: Color(0xFF0253B3),
        ),
        DropDown(
          options: options,
          answerStatus: isDisabled ? 1 : 0,
          selectedValue: dropdownValue,
          onChanged: (String? val) {
            if (isDisabled) return;
            final v = val ?? '';
            onTransportChanged?.call(v);
            if (v != 'その他') customTransportController?.clear();
          },
        ),
        if (dropdownValue == 'その他') ...[
          const SizedBox(height: 12),
          FinanceTextField(
            answerStatus: isDisabled ? 1 : 0,
            controller: customTransportController,
            hintText: '交通手段を入力してください。',
            onChanged: (String val) {
              //   if (isDisabled) return;
              //   customTransportController!.text = val;

              // 여기는 controller.text를 건드리지 않습니다!
              onCustomTransportChanged?.call(val); // 상위에 값 전달 (필요 시)
              // 또는 setState(() { _customTransport = val; });
            },
            // onChanged: isDisabled ? null : (val) {
            //   // 여기는 controller.text를 건드리지 않습니다!
            //   onCustomTransportChanged?.call(val); // 상위에 값 전달 (필요 시)
            //   // 또는 setState(() { _customTransport = val; });
            // },
          ),
        ],
      ],
    );
  }
}
