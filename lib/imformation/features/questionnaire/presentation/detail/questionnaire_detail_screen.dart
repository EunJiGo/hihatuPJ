import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/base/base_screen.dart';
import 'package:hihatu_project/imformation/features/questionnaire/presentation/detail/widgets/question_submit_buttons.dart';
import '../../../../../tabbar/htt_tabbar.dart';
import '../../../../../utils/dialog.dart';
import '../../data/fetch_questionnaire_detail.dart';
import '../../data/fetch_questionnaire_detail_answer.dart';
import '../../data/fetch_save_questionnaire_answer.dart';
import '../../domain/questionnaire_detail.dart';
import '../../domain/questionnaire_detail_answer_response.dart';
import '../../domain/questionnaire_detail_response.dart';
import '../../state/question_detail_provider.dart';
import 'widgets/question_item_widget.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final int questionnaireId;

  const QuestionDetailScreen({super.key, required this.questionnaireId});

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  List<TextEditingController> textControllers = [];
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    Future.wait([
      fetchQuestionnaireDetail(widget.questionnaireId),
      fetchQuestionnaireDetailAnswer(widget.questionnaireId),
    ]).then((results) {
      final detail = results[0] as QuestionnaireDetailResponse;
      final answerResponse = results[1] as QuestionnaireDetailAnswerResponse;

      final questions = detail.data.questions;
      final answers = answerResponse.data?.answers;

      final initialAnswers = List.generate(questions.length, (i) {
        final type = questions[i].type;
        if (answers != null && i < answers.length) {
          var ans = answers[i];
          if (type == 'check') {
            if (ans is List) {
              return List<String?>.from(ans.map((e) => e?.toString()));
            } else {
              return List<String?>.filled(questions[i].options.length, null);
            }
          } else {
            return ans?.toString();
          }
        } else {
          return type == 'check'
              ? List<String?>.filled(questions[i].options.length, null)
              : null;
        }
      });

      ref.read(selectedAnswersProvider.notifier).setAnswers(initialAnswers);

      textControllers = List.generate(questions.length, (i) {
        if (questions[i].type == 'text') {
          return TextEditingController(
            text: initialAnswers[i] != null ? initialAnswers[i].toString() : '',
          );
        } else {
          return TextEditingController();
        }
      });

      ref.read(answerStatusProvider.notifier).state = answerResponse.data?.status ?? 0;

      setState(() {
        isInitialized = true;
      });
    });
  }

  void handleSaveOrSubmit(int status) async {
    final selectedAnswers = ref.read(selectedAnswersProvider);
    bool hasAnyAnswer = selectedAnswers.any((ans) {
      if (ans == null) return false;
      if (ans is String && ans.trim().isEmpty) return false;
      if (ans is List && ans.every((e) => e == null || e.toString().trim().isEmpty)) return false;
      return true;
    });

    if (!hasAnyAnswer) {
      showAlertDialog(context, '注意', '何も入力されていません。');
      return;
    }

    bool success = await fetchSaveQuestionnaireAnswer(
      questionnaireId: widget.questionnaireId,
      status: status,
      answers: selectedAnswers,
    );

    if (success) {
      await showAlertDialog(
        context,
        '成功',
        status == 0 ? '保存が完了しました。' : '提出が完了しました。',
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HHTTabbar(
            initialIndex: 2,
            informationTabIndex: 1,
          ),
        ),
            (Route<dynamic> route) => false,
      );
    } else {
      showAlertDialog(context, 'エラー', '送信に失敗しました。');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(questionnaireDetailProvider(widget.questionnaireId));
    final answerStatus = ref.watch(answerStatusProvider);
    final selectedAnswers = ref.watch(selectedAnswersProvider);

    return BaseScreen(
      child: Column(
        children: [
          AppBar(
            title: const Text('アンケート詳細'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
            child: detailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('エラー: $err')),
              data: (detail) {
                if (!isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }

                final QuestionnaireDetail questionnaireDetail = detail.data;

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(questionnaireDetail.description),
                    Expanded(
                      child: ListView.builder(
                        itemCount: questionnaireDetail.questions.length,
                        itemBuilder: (context, index) {
                          return QuestionItemWidget(
                            question: questionnaireDetail.questions[index],
                            answerStatus: answerStatus,
                            answer: selectedAnswers.length > index ? selectedAnswers[index] : null,
                            textController: textControllers.length > index ? textControllers[index] : null,
                            onChanged: (value) {
                              ref.read(selectedAnswersProvider.notifier).updateAnswer(index, value);
                            },
                          );
                        },
                      ),
                    ),
                    QuestionSubmitButtons(
                      onSavePressed: () => handleSaveOrSubmit(0),
                      onSubmitPressed: () => handleSaveOrSubmit(1),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
