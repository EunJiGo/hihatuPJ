import 'package:intl/intl.dart';

DateTime? parseUtcToJst(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal(); // 기기 로컬 (JST이면 JST)
  } catch (_) {
    return null;
  }
}

/// 마감 안 지났는지 확인
bool isBeforeDeadline(String? rawDeadline) {
  final deadline = parseUtcToJst(rawDeadline);
  if (deadline == null) return true; // 없으면 제한 없음
  return DateTime.now().isBefore(deadline);
}

/// ISO8601 UTC("...Z") → UTC DateTime (보정 없음)
DateTime? parseUtc(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateTime.parse(raw).toUtc();
  } catch (_) {
    return null;
  }
}

/// 표시용: UTC → JST(UTC+9) 벽시계 시각으로 변환해 문자열 생성
String? formatAsJstDate(String? raw) {
  final utc = parseUtc(raw);
  if (utc == null) return null;
  final jst = utc.add(const Duration(hours: 9)); // JST: +09, DST 없음
  return DateFormat('yyyy-MM-dd').format(jst);   // 예: 2025-11-07
}

String? formatAsJstTime(String? raw) {
  final utc = parseUtc(raw);
  if (utc == null) return null;
  final jst = utc.add(const Duration(hours: 9));
  return DateFormat('HH:mm').format(jst);        // 예: 09:30
}

String? formatAsJstDateTime(String? raw) {
  final utc = parseUtc(raw);
  if (utc == null) return null;
  final jst = utc.add(const Duration(hours: 9));
  return DateFormat('yyyy-MM-dd HH:mm').format(jst);
}
