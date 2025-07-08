import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hihatu_project/base/base_screen.dart';
import 'package:hihatu_project/imformation/features/questionnaire/presentation/questionnaire_list_screen.dart';
import '../../../../screens/information_screen.dart';
import '../../../../tabbar/htt_tabbar.dart';
import '../../../../utils/image_picker_helper.dart';
import '../data/fetch_questionnaire_detail.dart';
import '../data/fetch_questionnaire_detail_answer.dart';
import '../data/fetch_save_questionnaire_answer.dart';
import '../domain/questionnaire_detail.dart';
import '../domain/questionnaire_detail_answer_response.dart';
import '../domain/questionnaire_detail_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/question_detail_provider.dart';

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

    // FutureProvider를 쓰니까 직접 futureDetail, futureAnswer 만들 필요 없음.

    // 초기 데이터 가져온 후 selectedAnswers 초기화 및 textControllers 생성
    Future.wait([
      fetchQuestionnaireDetail(widget.questionnaireId),
      fetchQuestionnaireDetailAnswer(widget.questionnaireId),
    ]).then((results) {
      final detail = results[0] as QuestionnaireDetailResponse;
      final answerResponse = results[1] as QuestionnaireDetailAnswerResponse;

      final questions = detail.data.questions;
      final answers = answerResponse.data?.answers;

      // 여기서 answers 안에 이미지 경로(파일 경로나 URL)가 들어있음
      print('답변 데이터 전체: $answers');

      // selectedAnswers 초기화
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

      // textControllers 생성 (text 타입 질문만)
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('注意'),
          content: Text('何も入力されていません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    bool success = await fetchSaveQuestionnaireAnswer(
      questionnaireId: widget.questionnaireId,
      status: status,
      answers: selectedAnswers,
    );

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('成功'),
          content: Text(status == 0 ? '保存が完了しました。' : '提出が完了しました。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('エラー'),
          content: Text('送信に失敗しました。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
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
                  // 초기 로딩 후에도 여전히 초기화 안됐으면 로딩 표시
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
                          final question = questionnaireDetail.questions[index];
                          final answer = selectedAnswers.length > index ? selectedAnswers[index] : null;
                          final currentIndex = index;

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q${index + 1}. ${question.text}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (question.type == 'text')
                                  if (answerStatus == 0)
                                    TextField(
                                      maxLines: null,
                                      controller: textControllers[index],
                                      decoration: InputDecoration(
                                        hintText: '回答を入力してください',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: answerStatus == 1,
                                      onChanged: (value) {
                                        ref.read(selectedAnswersProvider.notifier).updateAnswer(index, value);
                                      },
                                    )
                                  else
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black45),
                                      ),
                                      child: Text(
                                        answer.toString(),
                                        style: TextStyle(fontSize: 16, color: Colors.black45),
                                      ),
                                    )
                                else if (question.type == 'select')
                                  DropdownButtonFormField<String>(
                                    value: (answer is String && question.options.contains(answer)) ? answer : null,
                                    items: question.options.toSet().map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                                    onChanged: answerStatus == 1 ? null : (value) {
                                      ref.read(selectedAnswersProvider.notifier).updateAnswer(index, value);
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '選択してください',
                                    ),
                                  )
                                else if (question.type == 'check')
                                    Column(
                                      children: question.options.asMap().entries.map((entry) {
                                        final optIndex = entry.key;
                                        final opt = entry.value;
                                        final List<String?> checkedList = List<String?>.from(answer ?? List.filled(question.options.length, null));

                                        return CheckboxListTile(
                                          title: Text(opt),
                                          value: checkedList[optIndex] != null,
                                          onChanged: answerStatus == 1 ? null : (bool? checked) {
                                            if (checked == null) return;
                                            checkedList[optIndex] = checked ? opt : null;
                                            ref.read(selectedAnswersProvider.notifier).updateAnswer(currentIndex, List.from(checkedList));
                                          },
                                        );
                                      }).toList(),
                                    )
                                  else if (question.type == 'upload')
                                      GestureDetector(
                                        onTap: answerStatus == 1
                                            ? null
                                            : () {
                                          ImagePickerHelper.showImagePicker(
                                            context: context,
                                            onImageSelected: (File imageFile) {
                                              ref.read(selectedAnswersProvider.notifier).updateAnswer(index, imageFile.path);
                                            },
                                          );
                                        },
                                        child: Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.9,
                                            height: 200,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black38),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: answer != null && answer is String && answer.isNotEmpty
                                                ? Image.file(
                                              File(answer),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            )
                                                : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                                                SizedBox(width: 10),
                                                Text('画像をアップロードする', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                const SizedBox(height: 16),
                                const Divider(height: 32),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () => handleSaveOrSubmit(0),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue,
                                ),
                                width: 140,
                                height: 50,
                                child: Center(
                                  child: Text('保　　存', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.blue,
                              ),
                              width: 140,
                              height: 50,
                              child: Center(
                                child: Text('提　　出', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
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
