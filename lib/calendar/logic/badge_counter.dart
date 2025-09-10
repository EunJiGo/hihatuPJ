// 날짜별 스케줄 카운트 계산해서 월간 캘린더에 파란색 점 보여줄 수 있도록 하는 함수
import '../domain/calendar_single.dart';
import 'time_utils.dart';
import 'recurrence.dart';

Map<DateTime, int> computeBadgeCounts({
  required DateTime displayMonth,
  required List<CalendarSingle> events,
}) {
  final windowStart = DateTime(displayMonth.year, displayMonth.month, 1);
  final windowEnd   = DateTime(displayMonth.year, displayMonth.month,
      daysInMonth(displayMonth.year, displayMonth.month), 23, 59, 59);

  // 월의1일부터 월의 마지막일까지의 해당되는 Occurrence 객체 리스트
  final occ = expandOccurrencesForWindow(events, windowStart: windowStart, windowEnd: windowEnd);

  final map = <DateTime, int>{};

  for (final o in occ) {
    for (final d in eachLocalDateCovered(o.startLocal, o.endLocal)) { // [2025-09-04, 2025-09-05]
      if (d.year == displayMonth.year && d.month == displayMonth.month) {
        final key = DateTime(d.year, d.month, d.day);
        map[key] = (map[key] ?? 0) + 1;
      }
    }
  }
  return map;
}

/// 선택한 사원(employeeIds)이 포함된 이벤트가 있는 날짜를 카운트해서
/// 월간 캘린더에서 "초록 동그라미" 표시용으로 쓴다.
Map<DateTime, int> computePeopleBadges({
  required DateTime displayMonth,
  required List<CalendarSingle> events,
  required Set<int> selectedPersonIds,
}) {
  if (selectedPersonIds.isEmpty) return <DateTime, int>{};

  final windowStart = DateTime(displayMonth.year, displayMonth.month, 1);
  final windowEnd   = DateTime(
    displayMonth.year, displayMonth.month,
    daysInMonth(displayMonth.year, displayMonth.month),
    23, 59, 59,
  );

  final occ = expandOccurrencesForWindow(
    events,
    windowStart: windowStart,
    windowEnd: windowEnd,
  );

  final idsAsString = selectedPersonIds.map((e) => e.toString()).toSet();
  final map = <DateTime, int>{};

  for (final o in occ) {
    final ppl = o.src.people ?? const <Map<String, dynamic>>[];
    final hasSelected = ppl.any((m) {
      final pid = (m['person_id'] ?? '').toString();
      return idsAsString.contains(pid);
    });
    if (!hasSelected) continue;

    for (final d in eachLocalDateCovered(o.startLocal, o.endLocal)) {
      if (d.year == displayMonth.year && d.month == displayMonth.month) {
        final key = DateTime(d.year, d.month, d.day);
        map[key] = (map[key] ?? 0) + 1;
      }
    }
  }
  return map;
}

/// 선택한 설비(equipmentIds)가 1개라도 포함된 이벤트가 있는 날짜를 true로 마킹해서
/// 월간 캘린더에서 "회색 동그라미" 표시용으로 쓴다.
Map<DateTime, int> computeEquipmentBadges({
  required DateTime displayMonth,       // 1일 정규화된 달
  required List<CalendarSingle> events, // 사람/설비 합쳐진 리스트(_events)
  required Set<int> equipmentIds,       // 선택된 설비 ID들(_selectedEquipIds)
}) {
  if (equipmentIds.isEmpty) return <DateTime, int>{};

  final windowStart = DateTime(displayMonth.year, displayMonth.month, 1);
  final windowEnd   = DateTime(
    displayMonth.year,
    displayMonth.month,
    daysInMonth(displayMonth.year, displayMonth.month),
    23, 59, 59,
  );

  // 월 범위로 Occurrence 확장 (멀티데이/반복 고려)
  final occ = expandOccurrencesForWindow(
    events,
    windowStart: windowStart,
    windowEnd: windowEnd,
  );

  bool _occHasAnySelectedEquipment(Occurrence o) {
    // 1) 이벤트의 equipments 배열에 선택된 설비가 포함되면 OK
    for (final m in o.src.equipments) {
      final raw = m['equipment_id'] ?? m['id'];
      final id = CalendarSingle.toInt(raw);
      if (id != null && equipmentIds.contains(id)) return true;
    }
    // 2) 탑레벨 equipment_id 매칭도 허용
    final top = o.src.equipmentId;
    if (top != null && equipmentIds.contains(top)) return true;

    return false;
  }

  final map = <DateTime, int>{};

  for (final o in occ) {
    if (!_occHasAnySelectedEquipment(o)) continue;

    // 이 오커런스가 덮는 날짜마다 +1
    for (final d in eachLocalDateCovered(o.startLocal, o.endLocal)) {
      if (d.year == displayMonth.year && d.month == displayMonth.month) {
        final key = DateTime(d.year, d.month, d.day); // dateOnly 키
        map[key] = (map[key] ?? 0) + 1;
      }
    }
  }
  return map;
}



