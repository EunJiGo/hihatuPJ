String fmtJpDate(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString();
  final d = dt.day.toString();
  return '$y年$m月$d日';
}

// String fmtJpDate(DateTime dt) => _jpDateFmt.format(dt);

String fmtYen(int amount) {
  final s = amount.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    b.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) b.write(',');
  }
  return '${
      b.toString()
  }円';
}

String stationsFlowString(List<String> stations) =>
    stations.where((s) => s.trim().isNotEmpty).join(' → ');
