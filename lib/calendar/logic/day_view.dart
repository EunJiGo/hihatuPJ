// 일간 전개 유틸 (클리핑 + 섹션 빌드)
import 'package:hihatu_project/calendar/domain/calendar_single.dart';
import 'time_utils.dart';
import 'recurrence.dart';

/// 하루(또는 여러날) 리스트에 쓰기 위한 전개+클리핑 유틸
/// 하루(또는 여러날) 뷰에서 보여줄 Occurrence를 전개하고,
/// 각 날짜 경계로 클리핑한 뒤, 섹션(키=날짜) 별로 묶어 정렬하는 유팅


/// [s,e]를 [day]의 00:00~23:59:59 범위로 자름. 교차 없으면 null.
Occurrence? _clipOccurrenceToDay(Occurrence o, DateTime day) { // (수정) 비슷한 로직이 있었음, 하나로 합칠지 고민해보기
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd   = DateTime(day.year, day.month, day.day, 23, 59, 59, 999); // (수정) 하나로 통일
  if (!intersects(o.startLocal, o.endLocal, dayStart, dayEnd)) return null;

  final cs = o.startLocal.isBefore(dayStart) ? dayStart : o.startLocal;
  final ce = o.endLocal.isAfter(dayEnd) ? dayEnd : o.endLocal;
  return Occurrence(o.src, cs, ce); // day에 맞춘 새로운 하루날짜
}

/// [days]에 대한 리스트용 섹션 데이터 생성.
/// key: 날짜(DateTime, dateOnly), value: 그 날에 보이는 발생(클리핑 완료, 시작시간 기준 정렬)
Map<DateTime, List<Occurrence>> buildDaySections({
  required List<CalendarSingle> events, // 원번데이터(true를 보내서 서버에서 받은 데이터)
  required List<DateTime> days, // 선택한 날짜(지금은 1개 또는 2개)
}) {
  if (events.isEmpty || days.isEmpty) return {};

  final sortedDays = [...days]..sort();
  final windowStart = DateTime(sortedDays.first.year, sortedDays.first.month, sortedDays.first.day);
  final windowEnd   = DateTime(sortedDays.last.year,  sortedDays.last.month,  sortedDays.last.day, 23, 59, 59);

  // 윈도우에 교차하는 List<Occurrence>를 전개
  final occ = expandOccurrencesForWindow(events, windowStart: windowStart, windowEnd: windowEnd);

  final map = <DateTime, List<Occurrence>>{};
  for (final d in sortedDays) { // 날짜별로 이벤트들을 모으는 핵심 루프
    final key = DateTime(d.year, d.month, d.day); // 자정으로 초기화
    final list = <Occurrence>[];

    // occ에는 그 윈도우 전체(= 선택한 날짜 구간)와 겹치는 Occurrence들이 들어 있음
    // 하루만 선택했다면 → 그 하루에 해당하는 Occurrence 리스트
    // 이틀 이상 선택했다면 → 그 여러 날 범위에 해당하는 Occurrence 리스트
    for (final o in occ) {
      final clipped = _clipOccurrenceToDay(o, d);
      if (clipped != null) list.add(clipped);
    }

    // 시작시각이 동일하고 종료 시각이 같을 때, 제목 순으로 정렬한다
    // 시작 시각 → 종료 시각 → 제목 순 정렬
    list.sort((a, b) {
      final byStart = a.startLocal.compareTo(b.startLocal);
      if (byStart != 0) return byStart;
      final byEnd = a.endLocal.compareTo(b.endLocal);
      if (byEnd != 0) return byEnd;
      return (a.src.title).compareTo(b.src.title);
    });

    map[key] = list;
  }
  return map;
}