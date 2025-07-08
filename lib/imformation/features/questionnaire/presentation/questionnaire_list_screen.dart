import 'package:flutter/material.dart';
import 'package:hihatu_project/base/base_screen.dart';
import 'package:hihatu_project/imformation/features/questionnaire/presentation/questionnaire_detail_screen.dart';
import 'package:intl/intl.dart';
import '../data/fetch_questionnaire.dart';
import '../domain/questionnaire.dart';
import '../domain/questionnaire_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/questionnaire_list_provider.dart';
// 기타 import는 그대로 유지

class QuestionnaireListScreen extends ConsumerStatefulWidget {
  const QuestionnaireListScreen({super.key});

  @override
  ConsumerState<QuestionnaireListScreen> createState() => _QuestionnaireListScreenState();
}

class _QuestionnaireListScreenState extends ConsumerState<QuestionnaireListScreen> {
  @override
  void initState() {
    super.initState();
    // 프로바이더 통해 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionnaireListProvider.notifier).loadQuestionnaires();
    });
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
    // 상태관리에서 데이터 받아오기
    final list = ref.watch(questionnaireListProvider);

    return BaseScreen(
      child: Container(
        child: list.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionDetailScreen(
                      questionnaireId: item.id,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
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
                            ? Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 25)
                            : item.saved == 1
                            ? Icon(Icons.warning_amber_outlined, color: Colors.amber, size: 25)
                            : Icon(Icons.error_outline, color: Colors.red, size: 25),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: item.answered == 1
                              ? Colors.green
                              : item.saved == 1
                              ? Colors.amber
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${formatDate(item.deadline)}まで',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
