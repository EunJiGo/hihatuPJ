// 서버 이벤트를 “로컬타임 발생들”로 전개하고, 선택한 날짜(1~2일)별로 잘라서 돌려줌
import 'package:hihatu_project/calendar/logic/recurrence.dart';
import 'package:hihatu_project/calendar/logic/time_utils.dart';
import '../domain/calendar_single.dart';

DateTime _localDate(DateTime t) => DateTime(t.year, t.month, t.day);

/// 선택한 days(1~2일) 범위만 잘라서 날짜별로 묶어 반환.
/// 같은 날에 걸치도록 [00:00 ~ 23:59:59.999]로 클리핑해줌.
Map<DateTime, List<Occurrence>> occurrencesByDay({
  required List<CalendarSingle> events, // 전체 이벤트가 들ㅇ옴
  required List<DateTime> days,
  // 하루 선택 : days = [DateTime(2025, 9, 3)];
  // 이틀 선택 : days = [DateTime(2025, 9, 3), DateTime(2025, 9, 4)];

}) {
  if (days.isEmpty) return {};
  final dayKeys = days.map((d) => DateTime(d.year, d.month, d.day)).toList()
    ..sort();
  final ws = DateTime(
    dayKeys.first.year,
    dayKeys.first.month,
    dayKeys.first.day,
  );
  final we = DateTime(
    dayKeys.last.year,
    dayKeys.last.month,
    dayKeys.last.day,
    23,
    59,
    59,
    999,
  );

  final occAll = expandOccurrencesForWindow(
    events,
    windowStart: ws,
    windowEnd: we,
  );

  //
  final map = <DateTime, List<Occurrence>>{
    for (final d in dayKeys) d: <Occurrence>[],
  };

  for (final o in occAll) {
    var d = _localDate(o.startLocal);
    final endD = _localDate(o.endLocal);
    while (!d.isAfter(endD)) {
      final key = DateTime(d.year, d.month, d.day);
      if (map.containsKey(key)) {
        final dayStart = DateTime(d.year, d.month, d.day);
        final dayEnd = DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
        final s = o.startLocal.isBefore(dayStart) ? dayStart : o.startLocal;
        final t = o.endLocal.isAfter(dayEnd) ? dayEnd : o.endLocal;
        map[key]!.add(Occurrence(o.src, s, t));
      }
      d = d.add(const Duration(days: 1));
    }
  }

  for (final k in map.keys) {
    map[k]!.sort((a, b) => a.startLocal.compareTo(b.startLocal));
  }
  return map;
}

// 윈도우 안 모든 날짜 배열 만들기
List<DateTime> buildDaySpan({
  required DateTime windowStart,
  required DateTime windowEnd,
}) {
  final start = dateOnly(windowStart);
  final end   = dateOnly(windowEnd);
  final days = <DateTime>[];
  for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
    days.add(d);
  }
  return days;
}

// occurrencesByDay 결과에 "비는 날"도 넣기
Map<DateTime, List<Occurrence>> padEmptyDays({
  required Map<DateTime, List<Occurrence>> byDay,
  required List<DateTime> days,
}) {
  final out = <DateTime, List<Occurrence>>{...byDay};
  for (final d in days) {
    out.putIfAbsent(d, () => <Occurrence>[]);
  }
  return out;
}


