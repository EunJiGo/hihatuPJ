import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/fetch_questionnaire.dart';
import '../domain/questionnaire.dart';
import '../domain/questionnaire_response.dart';

class QuestionnaireListScreenEx extends StatefulWidget {
  const QuestionnaireListScreenEx({super.key});

  @override
  State<QuestionnaireListScreenEx> createState() => _QuestionnaireListScreenEXState();
}

class _QuestionnaireListScreenEXState extends State<QuestionnaireListScreenEx> {
  late final Future<QuestionnaireResponse> futureQuestionnaire;

  @override
  void initState() {
    super.initState();
    futureQuestionnaire = fetchQuestionnaireList();
  }

  String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
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

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
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
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.saved == 1 ? '保存済み' : '未保存',
                            style: TextStyle(
                              fontSize: 14,
                              color: item.saved == 1 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 날짜
                      Text(
                        '日付：${formatDate(item.deadline)}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
