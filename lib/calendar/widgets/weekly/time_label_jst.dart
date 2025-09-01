import '../../../utils/date/date_utils.dart';

DateTime _toJst(DateTime utc) => utc.toUtc().add(const Duration(hours: 9));

String _hhmm(DateTime jst) {
  String two(int x) => x.toString().padLeft(2, '0');
  return '${two(jst.hour)}:${two(jst.minute)}';
}

/// === [ADD] 주간 캘린더용 라벨 생성 규칙 ===
/// - start=end 같은 날짜  -> "HH:mm – HH:mm"
/// - start!=end 다른 날짜 -> day==start 인 날만 "HH:mm", 그 외 null(표시 안 함)
String? timeLabelForDayJst({
  required String? startRawUtc, // ISO-8601 UTC ("...Z")
  required String? endRawUtc,   // ISO-8601 UTC ("...Z")
  required DateTime dayJst,     // 해당 열의 JST 날짜(00:00)
}) {
  final sUtc = parseUtc(startRawUtc);
  final eUtc = parseUtc(endRawUtc);
  if (sUtc == null || eUtc == null) return null;

  final sJ = _toJst(sUtc);
  final eJ = _toJst(eUtc);

  final sDate = DateTime(sJ.year, sJ.month, sJ.day);
  final eDate = DateTime(eJ.year, eJ.month, eJ.day);

  final sameDay = sDate == eDate;

  if (sameDay) {
    return '${_hhmm(sJ)} – ${_hhmm(eJ)}';
  } else {
    if (dayJst == sDate) return _hhmm(sJ); // 시작일만 표시
    return null;                            // 중간/끝날은 표시 안 함
  }
}
