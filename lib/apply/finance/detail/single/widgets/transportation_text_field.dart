import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../../../utils/widgets/text_field_widget.dart';

class TransportationTextField extends StatelessWidget {
  final int answerStatus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final dynamic initialAnswer;
  final void Function(String) onChanged;
  final  String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const TransportationTextField({
    super.key,
    required this.answerStatus,
    this.controller,
    this.focusNode,
    required this.initialAnswer,
    required this.onChanged,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final isReadOnly = answerStatus == 1;

    return TextFieldWidget(
      isReadOnly: isReadOnly,
      // inputValue: initialAnswer?.toString() ?? '',
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      hintText: hintText,
      hintColor: const Color(0xFFfef7f0), // 지금 editableBackgroundColor의 색깔이 hintColor가 덮어씌움
      // editableBackgroundColor: const Color(0xFFFCFFF0), // 이거 넣으면 뒤에 네모 상자가나옴
      editableBorderColor: const Color(0xFFfea643),
      selectedBorderColor: const Color(0xFFffcc00),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
