// 공통 날짜/시간 유틸
DateTime dateOnly(DateTime x) => DateTime(x.year, x.month, x.day);
DateTime parseUtcToLocal(String isoZ) => DateTime.parse(isoZ).toLocal();
Duration duration(DateTime a, DateTime b) => b.difference(a);

int daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

// 새롭게 DateTime를 만들어줌
DateTime combineLocal(DateTime d, DateTime timeLike) =>
    DateTime(d.year, d.month, d.day, timeLike.hour, timeLike.minute, timeLike.second);
bool dateExists(int y, int m, int d) => d >= 1 && d <= daysInMonth(y, m);

// 서버 요일(0=일..6=토) → Dart(1=월..7=일)
int server2DartWeek(int s) => s == 0 ? 7 : s;

// 겹치는거 체크
bool intersects(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) =>
    !(aEnd.isBefore(bStart) || aStart.isAfter(bEnd));

Iterable<DateTime> eachLocalDateCovered(DateTime s, DateTime e) sync* {
  var d = dateOnly(s);
  final end = dateOnly(e);
  while (!d.isAfter(end)) {
    yield d;
    d = d.add(const Duration(days: 1));
  }
}

// 디버그 포맷
String fmtYmd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String fmtYmdHm(DateTime d) =>
    '${fmtYmd(d)} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
