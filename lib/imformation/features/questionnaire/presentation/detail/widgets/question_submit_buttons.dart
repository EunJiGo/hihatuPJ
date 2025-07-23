import 'package:flutter/material.dart';
import '../../../../../../utils/widgets/common_submit_buttons.dart';

class QuestionSubmitButtons extends StatelessWidget {
  final VoidCallback onSavePressed;
  final VoidCallback onSubmitPressed;

  const QuestionSubmitButtons({
    super.key,
    required this.onSavePressed,
    required this.onSubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonSubmitButtons(
      onSavePressed: onSavePressed,
      onSubmitPressed: onSubmitPressed,
      saveText: '保　　存',
      submitText: '提　　出',
      saveConfirmMessage: '安否確認内容を保存しますか？',
      submitConfirmMessage: '安否確認内容を提出しますか？',
      themeColor: const Color(0xFF0253B3),
      padding: 20.0, // 여기서 한 번만 컬러 지정
    );
  }
}
