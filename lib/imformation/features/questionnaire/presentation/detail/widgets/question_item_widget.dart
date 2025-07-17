import 'package:flutter/material.dart';
import '../../../../../../utils/route_observer.dart';
import '../../../domain/questionnaire_detail.dart';
import 'question_text_field.dart';
import 'question_dropdown.dart';
import 'question_checkbox_list.dart';
import 'question_image_upload.dart';

class QuestionItemWidget extends StatefulWidget {
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
  State<QuestionItemWidget> createState() => _QuestionItemWidgetState();
  }

class _QuestionItemWidgetState extends State<QuestionItemWidget> with RouteAware {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(this, ModalRoute.of(context)!); // ✅ 구독
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   FocusScope.of(context).unfocus();
    // });
  }

  @override
  void dispose() {
    print('dispose');
    // routeObserver.unsubscribe(this); // ✅ 구독 해제
    _focusNode.dispose();
    super.dispose();
  }

  /// ✅ 다른 화면에서 돌아왔을 때 호출됨
  @override
  void didPopNext() {
    print('didPopNext');
    FocusScope.of(context).unfocus(); // 포커스 해제
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus(); // 여기에도 명시적으로 unfocus
        FocusScope.of(context).unfocus();
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
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.question.text,
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
                onImageSelected: (path) => widget.onChanged(path),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
