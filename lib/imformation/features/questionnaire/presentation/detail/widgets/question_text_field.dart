// 텍스트 타입 질문 UI

import 'package:flutter/material.dart';

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
    if (answerStatus == 1) {
      // 제출 후 읽기 전용 상태
      return Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black45),
        ),
        child: Text(
          initialAnswer?.toString() ?? '',
          style: const TextStyle(fontSize: 16, color: Colors.black45),
        ),
      );
    } else {
      return TextField(
        maxLines: null,
        controller: controller,
        decoration: const InputDecoration(
          hintText: '回答を入力してください',
          border: OutlineInputBorder(),
        ),
        readOnly: answerStatus == 1,
        onChanged: onChanged,
      );
    }
  }
}
