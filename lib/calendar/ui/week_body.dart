import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/ui/selected_days_header.dart';
import 'package:hihatu_project/calendar/ui/week/week_strip.dart';
import 'package:hihatu_project/calendar/ui/week/week_timeline.dart';
import 'package:hihatu_project/calendar/logic/recurrence.dart';

// ====== UI 빌더: 주간/일간 모드 ======
class WeekBody extends StatelessWidget {
  const WeekBody({
    super.key,
    required this.pivotDate,
    required this.effectiveDays,
    required this.dayOccMap,
    required this.onTapDate,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onRefresh,
    required this.timeScroll,
  });

  final DateTime pivotDate;
  final List<DateTime> effectiveDays;
  final Map<DateTime, List<Occurrence>> dayOccMap;
  final Future<void> Function(DateTime) onTapDate;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final Future<void> Function() onRefresh;
  final ScrollController timeScroll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WeekStrip(
          pivotDate: pivotDate,
          selectedDays: effectiveDays,
          onTapDate: onTapDate,
          onSwipePrevWeek: onPrevWeek,
          onSwipeNextWeek: onNextWeek,
        ),
        SelectedDaysHeader(days: effectiveDays),
        Expanded(
          child: WeekTimeline(
            days: effectiveDays,
            controller: timeScroll,
            dayOccurrences: dayOccMap,
            onRefreshRequested: onRefresh,
          ),
        ),
      ],
    );
  }
}
