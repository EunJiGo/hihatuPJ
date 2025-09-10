// 반복 전개 엔진 (expand)
import '../domain/calendar_single.dart';
import 'time_utils.dart';

class Occurrence {
  final CalendarSingle src; // 원본 일정
  final DateTime startLocal; // 이번 발생의 사작시간(로컬기준)
  final DateTime endLocal; // 이번 발생의 종료시간(로컬기준)
  Occurrence(this.src, this.startLocal, this.endLocal);
}

// 반복 1회 길이(시:분 기준). 시작==종료면 1분 처리, 종료<시작이면 +24h.
Duration _perOccurrenceDuration(DateTime startL, DateTime endL) {
  final a = Duration(
    hours: startL.hour,
    minutes: startL.minute,
    seconds: startL.second,
  );
  final b = Duration(
    hours: endL.hour,
    minutes: endL.minute,
    seconds: endL.second,
  );
  final raw = b - a;
  if (raw == Duration.zero) return const Duration(minutes: 1);
  // .isNegative: Duration 객체가 음수인지를 검사하는 속성
  // raw.isNegative는 “자정 넘어가는 이벤트”가 있을 때만 발생
  return raw.isNegative ? raw + const Duration(days: 1) : raw;
}

// events들의 start, end 시간과 로컬 시간인 windowStart, windowEnd을 비교해서
// 겹치는 Occurrence객체들을 리스트화 해서 반환
List<Occurrence> expandOccurrencesForWindow(
  List<CalendarSingle> events, {
  required DateTime windowStart,
  required DateTime windowEnd,
}) {
  final out = <Occurrence>[];
  for (final e in events) {
    out.addAll(
      _expandByRepeat(e, windowStart: windowStart, windowEnd: windowEnd),
    );
  }
  return out;
}

List<Occurrence> _expandByRepeat(
  CalendarSingle e, {
  required DateTime windowStart,
  required DateTime windowEnd,
}) {
  final startL = parseUtcToLocal(e.start); // 로컬 시간으로 변환
  final endL = parseUtcToLocal(e.end); // 로컬 시간으로 변환
  final rep = (e.repeat).toLowerCase(); // toLowerCase() : 소문자로 변환해주는 함수

  final seriesStart = dateOnly(startL); // 시간 제외하고 날짜만
  final seriesEnd = dateOnly(endL);

  // none이면 startL→endL 실제 차이.
  // -> startL:2025-09-03 11:00 / endL: 2025-09-04 17:00라면 duration(startL, endL)은 30
  // 반복이면, 시작·끝의 시·분·초만 보고 끝이 시작보다 “앞서 보이면” +24h 보정(자정 넘김 처리) → 항상 양수 지속시간.
  // -> startL:2025-09-03 11:00 / endL: 2025-10-03 12:00 (한달동안 매일 반복) 라면 시간은(during=2)
  final dur = rep == 'none'
      ? duration(startL, endL)
      : _perOccurrenceDuration(startL, endL);

  final out = <Occurrence>[];
  void emitIfVisible(DateTime s, DateTime t) {
    if (intersects(s, t, windowStart, windowEnd)) out.add(Occurrence(e, s, t));
  }

  switch (rep) {
    case 'none':
      emitIfVisible(startL, endL);
      break;

    case 'daily':
      {
        var d = seriesStart; // 시간 제외하고 날짜만
        while (!d.isAfter(seriesEnd)) {
          final s = combineLocal(
            d,
            startL,
          ); // 개시날, 개시시간(로컬용) ex)2025-09-02 01:30:00.000
          final t = s.add(dur); // 종요일, 종료시간(로컬용)
          emitIfVisible(s, t);
          d = d.add(const Duration(days: 1));
        }
      }
      break;

    case 'weekly':
      {
        final wds = (e.repeatWeekdays)
            .map(server2DartWeek)
            .toSet(); // 만약 0(日), 3(水)라면 7, 3으로 변환됨
        if (wds.isEmpty) wds.add(startL.weekday);

        for (final wd in wds) {
          // 3, 7
          var d = seriesStart; // 2025.9.3
          // 1) 시리즈 시작일부터, 원하는 요일(wd)을 만날 때까지 하루씩 전진
          while (d.weekday != wd) {
            d = d.add(const Duration(days: 1));
            if (d.isAfter(seriesEnd)) break; // 안전 장치: 이미 범위 끝이면 중단
          }
          while (!d.isAfter(seriesEnd)) {
            final s = combineLocal(d, startL);
            final t = s.add(dur);
            emitIfVisible(s, t);
            d = d.add(const Duration(days: 7));
          }
        }
      }
      break;

    case 'biweekly':
      {
        final wds = (e.repeatWeekdays).map(server2DartWeek).toSet();
        if (wds.isEmpty) wds.add(startL.weekday);

        int weeksBetween(DateTime a, DateTime b) =>
            dateOnly(b).difference(dateOnly(a)).inDays ~/ 7;

        for (final wd in wds) {
          var d = seriesStart;
          while (d.weekday != wd) {
            d = d.add(const Duration(days: 1));
            if (d.isAfter(seriesEnd)) break;
          }
          while (!d.isAfter(seriesEnd)) {
            if (weeksBetween(seriesStart, d) % 2 == 0) {
              final s = combineLocal(d, startL);
              final t = s.add(dur);
              emitIfVisible(s, t);
            }
            d = d.add(const Duration(days: 7));
          }
        }
      }
      break;

    case 'monthly':
      {
        final days = <int>{...e.repeatMonthDays}; // 매월 1일, 15일, 31일 이런식
        if (days.isEmpty) days.add(startL.day);

        var y = seriesStart.year, m = seriesStart.month;
        final endYM = DateTime(seriesEnd.year, seriesEnd.month);

        while (!DateTime(y, m).isAfter(endYM)) {
          for (final md in days) {
            if (dateExists(y, m, md)) {
              final d = DateTime(y, m, md);
              if (!d.isBefore(seriesStart) && !d.isAfter(seriesEnd)) {
                final s = combineLocal(d, startL);
                final t = s.add(dur);
                emitIfVisible(s, t);
              }
            }
          }
          m += 1;
          if (m > 12) {
            m = 1;
            y += 1;
          }
        }
      }
      break;

    case 'yearly':
      {
        // 매년 9월 1일, 11월 1일 -> 복수 안됨
        final month = e.repeatYearMonth ?? startL.month;
        final day = e.repeatYearDay ?? startL.day;
        var y = seriesStart.year; // 2025
        while (y <= seriesEnd.year) {
          // 2030
          if (dateExists(y, month, day)) {
            // 2025.9.1
            final d = DateTime(y, month, day);
            if (!d.isBefore(seriesStart) && !d.isAfter(seriesEnd)) {
              final s = combineLocal(d, startL);
              final t = s.add(dur);
              emitIfVisible(s, t);
            }
          }
          y += 1;
        }
      }
      break;

    // "customDates": ["2025-09-02", "2025-09-08", "2025-09-14"]
    case 'custom':
      {
        for (final sDateStr in (e.customDates)) {
          final p = sDateStr.split('-'); // 처음으로는 p = [2025, 9, 2]
          if (p.length != 3) continue;
          final y = int.tryParse(p[0]),
              m = int.tryParse(p[1]),
              d = int.tryParse(p[2]);
          if (y == null || m == null || d == null)
            continue; // 건너뜀 : 즉, 다음 sDateStr로 넘어감
          if (!dateExists(y, m, d)) continue; // 건너뜀 : 즉, 다음 sDateStr로 넘어감

          final date = DateTime(y, m, d);
          if (!date.isBefore(seriesStart) && !date.isAfter(seriesEnd)) {
            final s = combineLocal(date, startL);
            final t = s.add(dur);
            emitIfVisible(s, t);
          }
        }
      }
      break;

    default:
      emitIfVisible(startL, endL);
  }
  return out;
}
