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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220253B3),
            blurRadius: 6,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 영역
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.question_answer_rounded,
                  color: Color(0xFF42A5F5), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF263238), // 다크그레이
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 질문 타입별 위젯 렌더링
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
                checkedValues: answer is List
                    ? List<String?>.from(answer)
                    : List.filled(question.options.length, null),
                onChanged: onChanged,
              )
            else if (question.type == 'upload')
                QuestionImageUpload(
                  answerStatus: answerStatus,
                  imagePath: answer is String ? answer : null,
                  onImageSelected: (path) => onChanged(path),
                ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
