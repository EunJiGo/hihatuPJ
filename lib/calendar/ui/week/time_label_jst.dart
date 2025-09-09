import 'package:intl/intl.dart';
import '../../../utils/date/date_utils.dart'; // parseUtc 사용

DateTime _toJst(DateTime utc) => utc.toUtc().add(const Duration(hours: 9));
String _hhmm(DateTime jst) => DateFormat('HH:mm').format(jst);

/// 주간 캘린더용 라벨 규칙
/// - start=end 같은 날짜  -> "HH:mm – HH:mm"
/// - start!=end 다른 날짜 -> dayJst==start 인 날만 "HH:mm", 그 외 null
String? timeLabelForDayJst({
  required String? startRawUtc, // ISO8601 UTC ("...Z")
  required String? endRawUtc,   // ISO8601 UTC ("...Z")
  required DateTime dayJst,     // 이 칸의 JST 날짜 (00:00)
}) {
  final sUtc = parseUtc(startRawUtc);
  final eUtc = parseUtc(endRawUtc);
  if (sUtc == null || eUtc == null) return null;

  final sJ = _toJst(sUtc);
  final eJ = _toJst(eUtc);

  final sDate = DateTime(sJ.year, sJ.month, sJ.day);
  final eDate = DateTime(eJ.year, eJ.month, eJ.day);

  if (sDate == eDate) {
    return '${_hhmm(sJ)} – ${_hhmm(eJ)}'; // 단일일 이벤트
  } else {
    return dayJst == sDate ? _hhmm(sJ) : null; // 멀티데이: 시작일만
  }
}