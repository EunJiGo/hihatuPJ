import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/utils/dialog/warning_dialog.dart';
import 'package:hihatu_project/imformation/features/questionnaire/presentation/detail/questionnaire_detail_screen.dart';
import 'package:hihatu_project/imformation/features/questionnaire/domain/questionnaire.dart';
import 'package:hihatu_project/imformation/features/questionnaire/state/questionnaire_list_provider.dart';
import 'package:hihatu_project/imformation/features/questionnaire/state/questionnaire_status_legend_filter_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionnaireListProvider.notifier).loadQuestionnaires();
    });
  }

  // ✨ 하루 끝(23:59:59) 기준 만료 판단
  bool _isExpiredEndOfDay(String deadlineStr) {
    final d = DateTime.tryParse(deadlineStr);
    if (d == null) return false;
    final local = d.isUtc ? d.toLocal() : d;
    final eod = DateTime(local.year, local.month, local.day, 23, 59, 59);
    return DateTime.now().isAfter(eod);
  }

  int calcStatusId(Questionnaire q) {
    if (q.answered == 1) return 2; // 작성완료 최우선
    final expired = _isExpiredEndOfDay(q.deadline);
    if (expired) return 3;         // 제출기간지남(미작성/작성중)
    if (q.saved == 1) return 1;    // 작성중
    return 0;                      // 미작성
  }

  // ✨ 정렬 안전성: 파싱 실패 시 고정 큰값
  DateTime _parseOrMax(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return DateTime(9999);
    final local = d.isUtc ? d.toLocal() : d;
    return DateTime(local.year, local.month, local.day, 23, 59, 59);
  }

  String formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final local = dt.isUtc ? dt.toLocal() : dt;
      return DateFormat('yyyy.MM.dd').format(local);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(questionnaireListProvider);
    final filterSet = ref.watch(questionnaireFilterSetProvider);

    // 하루 끝(EOD) 기준으로 로컬시간 마감시각 계산
    DateTime _deadlineEOD(String s) {
      final d = DateTime.tryParse(s);
      if (d == null) return DateTime.fromMillisecondsSinceEpoch(0); // 파싱 실패는 가장 과거 취급
      final local = d.isUtc ? d.toLocal() : d;
      return DateTime(local.year, local.month, local.day, 23, 59, 59);
    }

    bool _isExpired(Questionnaire q) => q.answered != 1 && DateTime.now().isAfter(_deadlineEOD(q.deadline));

    int _statusOrder(Questionnaire q) {
      // 기간 안 지난 그룹 내부 순서: 미작성(0) → 작성중(1) → 작성완료(2)
      if (q.answered == 1) return 2;
      if (_isExpired(q)) return 99; // 만료는 별도 그룹이므로 큰값
      if (q.saved == 1) return 1;
      return 0; // 미작성
    }

// ----------------- 여기부터 정렬 -----------------
    final sortedList = [...list]..sort((a, b) {
      final expiredA = _isExpired(a);
      final expiredB = _isExpired(b);

      // 1) 기간 안 지난 것 먼저
      if (expiredA != expiredB) return expiredA ? 1 : -1;

      // 2) 기간 안 지난 그룹: 상태 우선순위 0→1→2
      if (!expiredA && !expiredB) {
        final oa = _statusOrder(a);
        final ob = _statusOrder(b);
        if (oa != ob) return oa.compareTo(ob);

        // 3) 같은 상태면 최신순(마감일 내림차순)
        final da = _deadlineEOD(a.deadline);
        final db = _deadlineEOD(b.deadline);
        return db.compareTo(da); // 내림차순
      }

      // 4) 기간 지난 그룹: 제출기간 최신(내림차순)
      final da = _deadlineEOD(a.deadline);
      final db = _deadlineEOD(b.deadline);
      return db.compareTo(da); // 내림차순
    });


    final filteredList = sortedList.where((item) {
      final statusId = calcStatusId(item);
      return filterSet.contains(statusId);
    }).toList();

    return Container(
      color: const Color(0xFFEFF2F4),
      child: list.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : filteredList.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: Colors.black54, size: 35),
            Text('表示できる安否確認はありません。',
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      )
          : ListView.separated(
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) =>
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final item = filteredList[index];
          final statusId = calcStatusId(item);
          final isExpired = statusId == 3;

          // ✨ 상태별 아이콘을 단일 소스로 결정
          final trailingIcon = () {
            switch (statusId) {
              case 2:
                return const Icon(Icons.check_circle_outline,
                    size: 18, color: Colors.green);
              case 1:
                return const Icon(Icons.warning_amber_outlined,
                    size: 18, color: Colors.amber);
              case 0:
                return const Icon(Icons.error_outline,
                    size: 18, color: Colors.red);
              default:
                return const Icon(Icons.event_busy,
                    size: 18, color: Colors.black38);
            }
          }();

          return GestureDetector(
            onTap: () {
              if (isExpired) {
                warningDialog(context, '提出期限切れ', 'このアンケートの提出期限は過ぎています。');
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuestionDetailScreen(questionnaireId: item.id),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 상태 아이콘 (✨ trailingIcon만 사용)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title=='' ? '(タイトルなし）': item.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isExpired
                                ? Colors.black38
                                : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailingIcon,
                    ],
                  ),
                  const SizedBox(height: 5),
                  // 마감일
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        isExpired
                            ? Icons.event_busy
                            : Icons.calendar_today,
                        color: isExpired
                            ? Colors.black38
                            : (item.answered == 1
                              ? Colors.black38 // 제출 완료 → 회색
                              : Color(0xFF0253B3)), // 미작성/작성중 + 기한 전 → 오렌지,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${formatDate(item.deadline)}まで',
                        style: TextStyle(
                          fontSize: 13,
                          color: isExpired
                              ? Colors.black38
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
