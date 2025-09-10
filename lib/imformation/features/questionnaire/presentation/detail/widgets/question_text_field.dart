import 'package:flutter/material.dart';

import '../../../../../../utils/widgets/text_field_widget.dart';

class QuestionTextField extends StatelessWidget {
  final int answerStatus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final dynamic initialAnswer;
  final void Function(String) onChanged;

  const QuestionTextField({
    super.key,
    required this.answerStatus,
    this.controller,
    this.focusNode,
    required this.initialAnswer,
    required this.onChanged,
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
      hintText: '回答を入力してください。',
      hintColor: const Color(0xFFF0F7FF), // 지금 editableBackgroundColor의 색깔이 hintColor가 덮어씌움
      // editableBackgroundColor: const Color(0xFFF0F7FF), // 이거 넣으면 뒤에 네모 상자가나옴
      editableBorderColor: const Color(0xFF6096D0),
      selectedBorderColor: const Color(0xFF6096D0),
      // selectedBorderColor: const Color(0xFF64B5F6),
    );
  }
}
