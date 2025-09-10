/// 일본식 요일 라벨
const _weekdayJp = ['月', '火', '水', '木', '金', '土', '日'];

/// 날짜(JST) → "YYYY年M月D日 曜日" 문자열
String formatDateJst(DateTime dt) {
  return '${dt.year}年${dt.month}月${dt.day}日 ${_weekdayJp[dt.weekday - 1]}曜日';
}

/// 날짜(JST) → "H時" or "H時M分"
String formatHmJst(DateTime dt) {
  final m = dt.minute;
  return m == 0 ? '${dt.hour}時' : '${dt.hour}時${m}分';
}

/// 범위(JST) 포맷
String formatRangeJst(DateTime s, DateTime e) {
  final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
  return sameDay
      ? '${formatDateJst(s)}\n${formatHmJst(s)}から ${formatHmJst(e)}まで'
      : '${formatDateJst(s)} ${formatHmJst(s)}から\n${formatDateJst(e)} ${formatHmJst(e)}まで';
}
