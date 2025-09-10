/// UTC → JST 변환 (UTC +9)
DateTime toJst(DateTime utc) {
  return utc.toUtc().add(const Duration(hours: 9));
}

/// JST → UTC 변환도 필요할 수 있음
DateTime fromJst(DateTime jst) {
  return jst.subtract(const Duration(hours: 9)).toUtc();
}
