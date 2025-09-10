import 'package:flutter/material.dart';
import 'package:hihatu_project/imformation/features/questionnaire/domain/questionnaire_detail.dart';
import 'question_text_field.dart';
import 'question_drop_down.dart';
import 'question_checkbox_list.dart';
import 'question_image_upload.dart';

class QuestionItemWidget extends StatefulWidget {
  final QuestionItem question;
  final int answerStatus;
  final dynamic answer;
  final TextEditingController? textController;
  final void Function(dynamic) onChanged;
  final bool beforeDeadline;

  const QuestionItemWidget({
    super.key,
    required this.question,
    required this.answerStatus,
    required this.answer,
    this.textController,
    required this.onChanged,
    required this.beforeDeadline,
  });

  @override
  State<QuestionItemWidget> createState() => _QuestionItemWidgetState();
  }

class _QuestionItemWidgetState extends State<QuestionItemWidget> with RouteAware {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: () {
        _focusNode.unfocus(); // 여기에도 명시적으로 unfocus
        FocusScope.of(context).unfocus();  // 바깥 영역 터치 시 키보드 닫힘
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
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
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 영역
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.question_answer_rounded,
                  color: Color(0xFF42A5F5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.question.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF263238), // 다크그레이
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 질문 타입별 위젯 렌더링
            if (widget.question.type == 'text')
              QuestionTextField(
                answerStatus: widget.answerStatus,
                controller: widget.textController,
                focusNode: _focusNode,
                initialAnswer: widget.answer,
                onChanged: widget.onChanged,
              )
            else if (widget.question.type == 'select')
              QuestionDropdown(
                options: widget.question.options,
                answerStatus: widget.answerStatus,
                selectedValue: widget.answer is String ? widget.answer : null,
                onChanged: widget.onChanged,
              )
            else if (widget.question.type == 'check')
              QuestionCheckboxList(
                options: widget.question.options,
                answerStatus: widget.answerStatus,
                checkedValues:
                widget.answer is List
                        ? List<String?>.from(widget.answer)
                        : List.filled(widget.question.options.length, null),
                onChanged: widget.onChanged,
              )
            else if (widget.question.type == 'upload')
              QuestionImageUpload(
                focusNode: _focusNode,
                answerStatus: widget.answerStatus,
                imagePath: widget.answer is String ? widget.answer : null,
                beforeDeadline: widget.beforeDeadline,
                onImageSelected: (path) => widget.onChanged(path),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
