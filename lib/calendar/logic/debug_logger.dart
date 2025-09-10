// 디버그 로그 출력
import 'package:flutter/material.dart';
import '../domain/calendar_single.dart';
import 'time_utils.dart';
import 'recurrence.dart';
import 'badge_counter.dart';

void debugLogMonthBadges({
  required DateTime displayMonth,
  required List<CalendarSingle> events,
}) {
  final first = DateTime(displayMonth.year, displayMonth.month, 1); // 해당 월 1일 00:00:00
  final last  = DateTime(displayMonth.year, displayMonth.month + 1, 0, 23, 59, 59); // 이번달 마지막 날의 23:59:59
  debugPrint('------ DEBUG BADGES for ${displayMonth.year}-${displayMonth.month.toString().padLeft(2,"0")}');
  debugPrint('Window: ${fmtYmdHm(first)} ~ ${fmtYmdHm(last)} (local)');

  if (events.isEmpty) { debugPrint('No events.'); return; }

  debugPrint('== RAW EVENTS ==');
  for (final e in events) {
    debugPrint('  [id=${e.id}] ${e.title} repeat=${e.repeat} '
        'start=${e.start} end=${e.end} '
        'wks=${e.repeatWeekdays} mons=${e.repeatMonthDays} '
        'ym=${e.repeatYearMonth} yd=${e.repeatYearDay} '
        'custom=${e.customDates}');
  }

  final occ = expandOccurrencesForWindow(events, windowStart: first, windowEnd: last);
  debugPrint('== EXPANDED OCCURRENCES (in/over window) ==  count=${occ.length}');
  for (final o in occ) {
    final cover = eachLocalDateCovered(o.startLocal, o.endLocal).toList();
    final coverDays = cover.map(fmtYmd).join(', ');
    debugPrint('  - [id=${o.src.id}] ${o.src.title} '
        '${fmtYmdHm(o.startLocal)} ~ ${fmtYmdHm(o.endLocal)} '
        'covers: $coverDays');
  }

  final map = computeBadgeCounts(displayMonth: displayMonth, events: events);
  final keys = map.keys.toList()..sort();
  debugPrint('== BADGE RESULT (date -> count) ==');
  if (keys.isEmpty) {
    debugPrint('  (no dots)');
  } else {
    for (final d in keys) {
      debugPrint('  ${fmtYmd(d)} -> ${map[d]}');
    }
  }
  debugPrint('------ END DEBUG ------');
}
