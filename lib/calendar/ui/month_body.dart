import 'package:flutter/material.dart';
import '../types.dart';
import '../ui/month_grid.dart';

/// 월간: 제스처 + MonthGrid (동작 동일)
class MonthBody extends StatelessWidget {
  const MonthBody({
    super.key,
    required this.displayMonth,
    required this.eventCountByDay,
    required this.onTapDate,
    required this.onShiftMonth,
    this.badgesByDay,
    this.equipmentBadges,
    this.peopleBadges
  });

  final DateTime displayMonth;
  final Map<DateTime, int> eventCountByDay;

  // 기존 시그니처 유지(Future<void> 반환). MonthGrid는 void 콜백이므로 아래에서 어댑트함.
  final Future<void> Function(DateTime) onTapDate;

  /// 음수: 이전 달, 양수: 다음 달
  final void Function(int delta) onShiftMonth;

  final Map<DateTime, MonthBadge>? badgesByDay;

  // ⬅ 추가: 설비 필터 매칭 여부 맵 (day-only 키)
  final Map<DateTime, int>? equipmentBadges;
  final Map<DateTime, int>? peopleBadges;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v.abs() < 80) return; // 기존 임계값 그대로
        v < 0 ? onShiftMonth(1) : onShiftMonth(-1);
      },
      child: MonthGrid(
        displayMonth: displayMonth,
        eventCountByDay: eventCountByDay,
        badgesByDay: badgesByDay,
        equipmentBadges: equipmentBadges,
        peopleBadges: peopleBadges,
        // MonthGrid는 ValueChanged<DateTime> (void) 이므로, 반환 무시하도록 감싸서 전달
        onTapDate: (d) { onTapDate(d); },
      ),
    );
  }
}
