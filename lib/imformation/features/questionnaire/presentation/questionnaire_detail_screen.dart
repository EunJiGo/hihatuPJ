import 'package:flutter/material.dart';
import 'package:hihatu_project/base/base_screen.dart';
import '../data/fetch_questionnaire_detail.dart';
import '../domain/questionnaire_detail.dart';
import '../domain/questionnaire_detail_response.dart';

class QuestionDetailScreen extends StatefulWidget {
  final int questionnaireId; // questionnaireId

  const QuestionDetailScreen({super.key, required this.questionnaireId});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late Future<QuestionnaireDetailResponse> futureDetail;

  @override
  void initState() {
    super.initState();
    futureDetail = fetchQuestionnaireDetail(widget.questionnaireId);
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('データが存在しません'));
                }

                final QuestionnaireDetail detail = snapshot.data!.data;

                return ListView.builder(
                  itemCount: detail.questions.length,
                  itemBuilder: (context, index) {
                    final question = detail.questions[index];

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
                          const SizedBox(height: 12),

                          // 질문 타입별 입력 필드
                          if (question.type == 'text')
                            TextField(
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: '回答を入力してください',
                                border: OutlineInputBorder(),
                              ),
                            )
                          else if (question.type == 'select')
                            DropdownButtonFormField<String>(
                              items:
                                  question.options
                                      .map(
                                        (opt) => DropdownMenuItem(
                                          value: opt,
                                          child: Text(opt),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {},
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '選択してください',
                              ),
                            )
                          else if (question.type == 'check')
                            Column(
                              children:
                                  question.options.map((opt) {
                                    return CheckboxListTile(
                                      title: Text(opt),
                                      value: false,
                                      onChanged: (value) {},
                                    );
                                  }).toList(),
                            )
                          else if (question.type == 'upload')
                            ListTile(
                              title: const Text('画像をアップロードする'),
                              subtitle: Text(question.text),
                              trailing: const Icon(Icons.camera_alt),
                              onTap: () {
                                // 실제 업로드 기능은 나중에
                              },
                            ),

                          const SizedBox(height: 16),
                          const Divider(height: 32),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
