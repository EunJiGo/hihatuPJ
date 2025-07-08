// 질문 1개에 대한 UI 렌더링 분기
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../domain/questionnaire_detail.dart';
import 'question_text_field.dart';
import 'question_dropdown.dart';
import 'question_checkbox_list.dart';
import 'question_image_upload.dart';

class QuestionItemWidget extends StatelessWidget {
  final QuestionItem question;
  final int answerStatus;
  final dynamic answer;
  final TextEditingController? textController;
  final void Function(dynamic) onChanged;

  const QuestionItemWidget({
    super.key,
    required this.question,
    required this.answerStatus,
    required this.answer,
    this.textController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.question_answer_outlined, color: Color(0xFF0253B3),),
              SizedBox(width: 5,),
              Text(
                question.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (question.type == 'text')
            QuestionTextField(
              answerStatus: answerStatus,
              controller: textController,
              initialAnswer: answer,
              onChanged: onChanged,
            )
          else if (question.type == 'select')
            QuestionDropdown(
              options: question.options,
              answerStatus: answerStatus,
              selectedValue: answer is String ? answer : null,
              onChanged: onChanged,
            )
          else if (question.type == 'check')
              QuestionCheckboxList(
                options: question.options,
                answerStatus: answerStatus,
                checkedValues: answer is List ? List<String?>.from(answer) : List.filled(question.options.length, null),
                onChanged: onChanged,
              )
            else if (question.type == 'upload')
                QuestionImageUpload(
                  answerStatus: answerStatus,
                  imagePath: answer is String ? answer : null,
                  onImageSelected: (path) => onChanged(path),
                ),
          const SizedBox(height: 16),
          // const Divider(height: 32), // 밑줄
        ],
      ),
    );
  }
}
