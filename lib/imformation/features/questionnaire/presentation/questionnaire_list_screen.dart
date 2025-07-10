import 'package:flutter/material.dart';
import 'package:hihatu_project/base/base_screen.dart';
import 'package:hihatu_project/imformation/features/questionnaire/presentation/detail/questionnaire_detail_screen.dart';
import 'package:intl/intl.dart';
import '../../../../utils/dialog/warning_dialog.dart';
import '../data/fetch_questionnaire.dart';
import '../domain/questionnaire.dart';
import '../domain/questionnaire_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/questionnaire_list_provider.dart';
import '../state/questionnaire_status_legend_filter_provider.dart.dart';
// 기타 import는 그대로 유지

class QuestionnaireListScreen extends ConsumerStatefulWidget {
  const QuestionnaireListScreen({super.key});

  @override
  ConsumerState<QuestionnaireListScreen> createState() =>
      _QuestionnaireListScreenState();
}

class _QuestionnaireListScreenState
    extends ConsumerState<QuestionnaireListScreen> {
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
    final filterSet = ref.watch(questionnaireFilterSetProvider);

    final sortedList = [...list]; // 원본을 복사해서 정렬

    sortedList.sort((a, b) {
      // 1. 상태 우선순위 비교 (미작성: 0, 저장됨: 1, 제출됨: 2)
      int getStatusRank(Questionnaire q) {
        if (q.answered == 1) return 2; // 제출 완료
        if (q.saved == 1) return 1; // 작성 중
        return 0; // 미작성
      }

      int statusA = getStatusRank(a);
      int statusB = getStatusRank(b);

      if (statusA != statusB) {
        return statusA.compareTo(statusB); // 낮은 값(미작성)이 우선
      }

      // 2. 상태 같으면 마감일 빠른 순으로 정렬
      DateTime deadlineA = DateTime.tryParse(a.deadline) ?? DateTime.now();
      DateTime deadlineB = DateTime.tryParse(b.deadline) ?? DateTime.now();
      return deadlineA.compareTo(deadlineB); // 가까운 날짜가 우선
    });

    // 필터링
    final filteredList = sortedList.where((item) {
      final isExpired =
          DateTime.tryParse(item.deadline)?.isBefore(DateTime.now()) ?? false;

      if (filterSet.isEmpty) return true;

      final statusId = isExpired
          ? 3
          : item.answered == 1
          ? 2
          : item.saved == 1
          ? 1
          : 0;

      return filterSet.contains(statusId);
    }).toList();

    return Container(
      color: Color(0xFFEFF2F4),
      child:
          list.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  final isExpired =
                      DateTime.tryParse(
                        item.deadline,
                      )?.isBefore(DateTime.now()) ??
                      false; // 제출기한 지났는지 여부

                  return GestureDetector(
                    onTap: () {
                      if (isExpired) {
                        // 만료되었으면 경고 다이얼로그
                        warningDialog(
                          context,
                          '提出期限切れ',
                          'このアンケートの提出期限は過ぎています。',
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => QuestionDetailScreen(
                                  questionnaireId: item.id,
                                ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isExpired ? Colors.black12 : Colors.white30,
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
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isExpired
                                                  ? Colors.black26
                                                  : Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              item.answered == 1
                                  ? Icon(
                                    Icons.check_circle_outline,
                                    color:
                                        isExpired
                                            ? Colors.black12
                                            : Colors.greenAccent,
                                    size: 25,
                                  )
                                  : item.saved == 1
                                  ? Icon(
                                    Icons.warning_amber_outlined,
                                    color:
                                        isExpired
                                            ? Colors.black12
                                            : Colors.amber,
                                    size: 25,
                                  )
                                  : Icon(
                                    Icons.error_outline,
                                    color:
                                        isExpired ? Colors.black12 : Colors.red,
                                    size: 25,
                                  ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color:
                                    item.answered == 1
                                        ? isExpired
                                            ? Colors.black26
                                            : Colors.green
                                        : item.saved == 1
                                        ? isExpired
                                            ? Colors.black26
                                            : Colors.amber
                                        : isExpired
                                        ? Colors.black26
                                        : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${formatDate(item.deadline)}まで',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isExpired
                                          ? Colors.black26
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
