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
    final isReadOnly = answerStatus == 1;

    if (isReadOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          // color: const Color(0xFFF7FAFC),
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          initialAnswer?.toString().trim().isNotEmpty == true
              ? initialAnswer.toString()
              : '（未入力）',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF), // 통일감을 위한 밝은 파랑 회색 배경
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB0BEC5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220253B3),
            blurRadius: 6,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: TextField(
        maxLines: null,
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          hintText: '回答を入力してください',
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          filled: true,
          fillColor: Color(0xFFF0F7FF), // ⬅️ 내부도 동일한 색상
        ),
        onChanged: onChanged,
      ),
    );
  }
}
