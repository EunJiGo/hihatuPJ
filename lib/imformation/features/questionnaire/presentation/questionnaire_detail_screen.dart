import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hihatu_project/base/base_screen.dart';
import '../../../../utils/image_picker_helper.dart';
import '../data/fetch_questionnaire_detail.dart';
import '../data/fetch_questionnaire_detail_answer.dart';
import '../data/fetch_save_questionnaire_answer.dart';
import '../domain/questionnaire_detail.dart';
import '../domain/questionnaire_detail_answer_response.dart';
import '../domain/questionnaire_detail_response.dart';

class QuestionDetailScreen extends StatefulWidget {
  final int questionnaireId;

  const QuestionDetailScreen({super.key, required this.questionnaireId});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late Future<QuestionnaireDetailResponse> futureDetail;
  late Future<QuestionnaireDetailAnswerResponse> futureAnswer;

  List<dynamic> selectedAnswers = [];
  bool isInitialized = false;
  int answerStatus = 0; // 보존 or 제출
  List<TextEditingController> textControllers = []; // 텍스트에 대한 답변



// 📁 lib/questionnaire/ui/question_detail_screen.dart

// ✅ 기존 코드 생략
// 아래 코드를 기존 QuestionDetailScreen 클래스 안에 추가하세요.

  void handleSaveOrSubmit(int status) async {
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
              onPressed: () => Navigator.pop(context),
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
  void initState() {
    super.initState();
    futureDetail = fetchQuestionnaireDetail(widget.questionnaireId);
    futureAnswer = fetchQuestionnaireDetailAnswer(widget.questionnaireId);

    Future.wait([futureDetail, futureAnswer]).then((results) {
      final detail = results[0] as QuestionnaireDetailResponse;
      final answerResponse = results[1] as QuestionnaireDetailAnswerResponse;

      final questions = detail.data.questions;
      final answers = answerResponse.data?.answers;

      // 이건 null을 제거하하는 것

      // selectedAnswers = List.generate(questions.length, (i) {
      //   final type = questions[i].type;
      //   if (answers != null && i < answers.length) {
      //     var ans = answers[i];
      //     if (type == 'check') {
      //       if (ans is List) {
      //         return ans
      //             .where((e) => e != null)
      //             .map((e) => e.toString())
      //             .toList();
      //       } else {
      //         return <String>[];
      //       }
      //     } else {
      //       return ans?.toString();
      //     }
      //   } else {
      //     return type == 'check' ? <String>[] : null;
      //   }
      // });

      // null을 유지하면서 저장
      selectedAnswers = List.generate(questions.length, (i) {
        final type = questions[i].type;
        if (answers != null && i < answers.length) {
          var ans = answers[i];
          if (type == 'check') {
            if (ans is List) {
              // null 포함 그대로 받아서 List<String?>로 캐스팅
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

      // 질문이 준비되면 textControllers 생성 (text 타입 질문만)
      textControllers = List.generate(questions.length, (i) {
        if (questions[i].type == 'text') {
          return TextEditingController(
            text:
                selectedAnswers[i] != null ? selectedAnswers[i].toString() : '',
          );
        } else {
          return TextEditingController();
        }
      });

      setState(() {
        answerStatus = answerResponse.data?.status ?? 0; // 보존 or 제출
        isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          AppBar(
            title: const Text('アンケート詳細'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
          ),
          Expanded(
            child: FutureBuilder<QuestionnaireDetailResponse>(
              future: futureDetail,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('データが存在しません'));
                }

                final QuestionnaireDetail detail = snapshot.data!.data;

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(detail.description),
                    Expanded(
                      child: ListView.builder(
                        itemCount: detail.questions.length,
                        itemBuilder: (context, index) {
                          final question = detail.questions[index];
                          final answer =
                              selectedAnswers.length > index
                                  ? selectedAnswers[index]
                                  : null;

                          final currentIndex = index; // 체크박스의 index를 안전하게 저장

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
                                        selectedAnswers[index] = value;
                                      },
                                    )
                                  // TextField(
                                  //   maxLines: null,
                                  //   controller: TextEditingController(
                                  //     text:
                                  //         answer != null
                                  //             ? answer.toString()
                                  //             : '',
                                  //   ),
                                  //   decoration: InputDecoration(
                                  //     hintText: '回答を入力してください',
                                  //     border: OutlineInputBorder(),
                                  //   ),
                                  //   readOnly:
                                  //       answerStatus ==
                                  //       1, // readOnly가 true이면 텍스트필드가 아닌 필드 형식
                                  // )
                                  else
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black45,
                                        ),
                                      ),
                                      child: Text(
                                        answer.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    )
                                else if (question.type == 'select')
                                  DropdownButtonFormField<String>(
                                    value:
                                        (answer is String &&
                                                question.options.contains(
                                                  answer,
                                                ))
                                            ? answer
                                            : null,
                                    items:
                                        question.options
                                            .toSet()
                                            .map(
                                              (opt) => DropdownMenuItem(
                                                value: opt,
                                                child: Text(opt),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        answerStatus == 1
                                            ? null // 🔒 선택 불가
                                            : (value) {
                                              setState(() {
                                                selectedAnswers[index] = value;
                                              });
                                              print(value); // 선택한 값이 출력됨
                                            },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '選択してください',
                                    ),
                                  )
                                else if (question.type == 'check')
                                  Column(
                                    children:
                                        question.options.asMap().entries.map((
                                          entry,
                                        ) {
                                          final optIndex = entry.key;
                                          final opt = entry.value;
                                          final List<String?> checkedList =
                                              List<String?>.from(
                                                answer ??
                                                    List.filled(
                                                      question.options.length,
                                                      null,
                                                    ),
                                              );

                                          return CheckboxListTile(
                                            title: Text(opt),
                                            value:
                                                checkedList[optIndex] != null,
                                            onChanged:
                                                answerStatus == 1
                                                    ? null
                                                    : (bool? checked) {
                                                      if (checked == null)
                                                        return;
                                                      setState(() {
                                                        checkedList[optIndex] =
                                                            checked
                                                                ? opt
                                                                : null;
                                                        selectedAnswers[currentIndex] =
                                                            List.from(
                                                              checkedList,
                                                            );
                                                        print(
                                                          checkedList,
                                                        ); // 디버깅 출력
                                                      });
                                                    },
                                          );
                                        }).toList(),
                                  )
                                // else if (question.type == 'upload')
                                // ListTile(
                                //   title: const Text('画像をアップロードする'),
                                //   subtitle: Text(
                                //     answer != null
                                //         ? answer.toString()
                                //         : question.text,
                                //   ),
                                //   trailing: const Icon(Icons.camera_alt),
                                //   onTap:  answerStatus == 1
                                //   ? null // 🔒 선택 불가
                                //       : () {
                                //     ImagePickerHelper.showImagePicker(
                                //       context: context,
                                //       onImageSelected: (File imageFile) {
                                //         setState(() {
                                //           selectedAnswers[index] = imageFile.path;
                                //           print(imageFile.path);
                                //         });
                                //       },
                                //     );
                                //   },
                                // ),
                                else if (question.type == 'upload')
                                  GestureDetector(
                                    onTap:
                                        answerStatus == 1
                                            ? null
                                            : () {
                                              ImagePickerHelper.showImagePicker(
                                                context: context,
                                                onImageSelected: (
                                                  File imageFile,
                                                ) {
                                                  setState(() {
                                                    selectedAnswers[index] =
                                                        imageFile.path;
                                                    print(imageFile.path);
                                                  });
                                                },
                                              );
                                            },
                                    child: Center(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.9,
                                        height: 200,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black38,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child:
                                            answer != null &&
                                                    answer is String &&
                                                    answer.isNotEmpty
                                                ? Image.file(
                                                  File(answer),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                )
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons.camera_alt,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '画像をアップロードする',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16,
                                                      ),
                                                    ),
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
                              onTap: () => handleSaveOrSubmit(0), // 保存
                              // onTap: () {
                              //   print('answers: ${selectedAnswers}');
                              // },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                // color: Colors.blue, // color와 decoration를 같이 쓰면 안됨
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue,
                                ),
                                width: 140,
                                height: 50,
                                child: Center(
                                  child: Text(
                                    '保　　存',
                                    style: TextStyle(
                                        fontSize: 20,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
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
                                child: Text(
                                  '提　　出',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
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
