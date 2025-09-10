import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../presentation/widgets/form_label.dart';
import '../widgets/finance_text_field.dart';

class AmountSection extends StatelessWidget {
  const AmountSection({
    super.key,
    required this.controller,
    this.isDisabled = false,
    this.onChanged,
    this.isRoundTrip,
  });

  final TextEditingController controller;
  final bool isDisabled;
  final ValueChanged<int>? onChanged; // 숫자 문자열
  final bool? isRoundTrip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(
          text: '金額 (\u5186)',
          icon: Icons.attach_money,
          iconColor: const Color(0xFF0253B3),
        ),
        FinanceTextField(
          answerStatus: isDisabled ? 1 : 0,
          controller: controller,
          onChanged: isDisabled ? null : (String v) {
            // 빈 문자열 처리(모두 지웠을 때)
            if (v.isEmpty) {
              onChanged?.call(0); // 또는 null 허용이면 시그니처를 바꾸세요
              return;
            }
            final parsed = int.tryParse(v);
            if (parsed != null) {
              onChanged?.call(parsed);
            } else {
              // 숫자 외 입력은 필터에서 걸리지만 혹시 모를 예외 안전장치
              onChanged?.call(0);
            }
          },
          // // 널 허욜일 경우
          // onChanged: isDisabled ? null : (String v) {
          //   // v == "" → null 전달
          //   if (v.isEmpty) {
          //     onChanged?.call(null);
          //     return;
          //   }
          //   // 숫자로 변환 시도
          //   final parsed = int.tryParse(v);
          //   onChanged?.call(parsed);
          // },
          hintText: isRoundTrip == null ? '金額を入力してください' : isRoundTrip == true ? '往復交通費を入力してください' : '片道交通費を入力してください',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}
