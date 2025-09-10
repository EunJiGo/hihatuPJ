import 'package:flutter/material.dart';
import '../logic/recurrence.dart';
import '../ui/schedule_list_view.dart';

/// 리스트 모드: ScheduleListBody 래퍼 (동작 동일)
class ListBody extends StatelessWidget {
  const ListBody({
    super.key,
    required this.days,
    required this.byDay,
    required this.focusDay,
    required this.hideEmptyDays,
    required this.preserveAnchorDay,
    required this.onNearEdge,
    required this.onTapOccurrence,
    required this.onTopDayChanged,
  });

  final List<DateTime> days;
  final Map<DateTime, List<Occurrence>> byDay;
  final DateTime focusDay;
  final bool hideEmptyDays;
  final DateTime? preserveAnchorDay;

  /// 스크롤 가장자리 접근시 확장
  final void Function(NearEdge edge, DateTime anchor) onNearEdge;

  /// 일정 탭
  final Future<void> Function(Occurrence occ) onTapOccurrence;

  /// 리스트 상단 날짜 변경 콜백
  final void Function(DateTime day) onTopDayChanged;

  @override
  Widget build(BuildContext context) {
    return ScheduleListBody(
      days: days,
      byDay: byDay,
      focusDay: focusDay,
      hideEmptyDays: hideEmptyDays,
      preserveAnchorDay: preserveAnchorDay,
      onNearEdge: onNearEdge,
      onTapOccurrence: onTapOccurrence,
      onTopDayChanged: onTopDayChanged,
    );
  }
}
