bool isExpiredEndOfDay(String deadlineStr) {
  final d = DateTime.tryParse(deadlineStr);
  if (d == null) return false;
  final local = d.isUtc ? d.toLocal() : d;
  final eod = DateTime(local.year, local.month, local.day, 23, 59, 59);
  return DateTime.now().isAfter(eod);
}
