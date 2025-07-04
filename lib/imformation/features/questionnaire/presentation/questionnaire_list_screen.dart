import 'package:flutter/material.dart';
import 'package:hihatu_project/base/base_screen.dart';
import 'package:hihatu_project/imformation/features/questionnaire/presentation/questionnaire_detail_screen.dart';
import 'package:intl/intl.dart';
import '../data/fetch_questionnaire.dart';
import '../domain/questionnaire.dart';
import '../domain/questionnaire_response.dart';

class QuestionnaireListScreen extends StatefulWidget {
  const QuestionnaireListScreen({super.key});

  @override
  State<QuestionnaireListScreen> createState() =>
      _QuestionnaireListScreenState();
}

class _QuestionnaireListScreenState extends State<QuestionnaireListScreen> {
  late final Future<QuestionnaireResponse> futureQuestionnaire;

  @override
  void initState() {
    super.initState();
    futureQuestionnaire = fetchQuestionnaireList();
  }

  String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('yyyy.MM.dd').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Container(
        // padding: const EdgeInsets.all(10),
        // color: Colors.white,
        child: FutureBuilder<QuestionnaireResponse>(
          future: futureQuestionnaire,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Center(child: Text('アンケートが見つかりません'));
            } else {
              final List<Questionnaire> list = snapshot.data!.data;

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuestionDetailScreen(questionnaireId: item.id),
                        ),
                      );
                    },
                    child: Container(
                      // margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 타이틀 + 상태
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    // Icon(
                                    //   Icons.local_offer_outlined,
                                    //   color: Colors.blue, // 파란색
                                    //   size: 20, // 원하는 크기로 조정
                                    // ),
                                    // Image.asset(
                                    //   'assets/images/add/title_label.png',
                                    //   width: 20,
                                    //   height: 20,
                                    // ),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              item.answered == 1
                                  ? Image.asset(
                                    'assets/images/information/correct/correct.png',
                                    height: 22,
                                    width: 22,
                                  )
                                  : item.saved == 1
                                  ? Icon(
                                    Icons.warning_amber_outlined,
                                    color: Colors.amber,
                                    size: 25,
                                  )
                                  : Icon(
                                    Icons.error_outline, // 동그라미 안에 느낌표 형태
                                    color: Colors.red,
                                    size: 25,
                                  ),

                              // Container(
                              //       child: Image.asset(
                              //         'assets/images/information/warning/warning.png',
                              //         height: 20,
                              //         width: 20,
                              //       ),
                              //     ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 날짜
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.schedule,
                                // 또는 Icons.access_time, Icons.calendar_today
                                size: 14,
                                color:
                                    item.answered == 1
                                        ? Colors.green
                                        : item.saved == 1
                                        ? Colors.amber
                                        : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${formatDate(item.deadline)}まで',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
