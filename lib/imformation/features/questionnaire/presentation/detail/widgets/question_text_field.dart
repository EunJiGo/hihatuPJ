import 'package:flutter/material.dart';

import '../../../../../../utils/widget/text_field_widget.dart';

class QuestionTextField extends StatelessWidget {
  final int answerStatus;
  final TextEditingController? controller;
  final dynamic initialAnswer;
  final void Function(String) onChanged;

  const QuestionTextField({
    super.key,
    required this.answerStatus,
    this.controller,
    required this.initialAnswer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isReadOnly = answerStatus == 1;

    return TextFieldWidget(
      isReadOnly: isReadOnly,
      inputValue: initialAnswer?.toString() ?? '',
      controller: controller,
      onChanged: onChanged,
      hintText: '回答を入力してください',
      hintColor: const Color(0xFFF0F7FF),
      editableBackgroundColor: const Color(0xFFF0F7FF),
      editableBorderColor: const Color(0xFFB0BEC5),
      readOnlyBackgroundColor: Colors.grey.shade200,
      readOnlyBorderColor: Colors.grey.shade400,
    );
  }
}
