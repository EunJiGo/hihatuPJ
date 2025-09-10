/// commuter：날짜·역 문자열
import 'package:intl/intl.dart';

final _jpDateFmt = DateFormat('y年M月d日', 'ja_JP');

extension JpDate on DateTime {
  String toJpYMD() => _jpDateFmt.format(this);
  DateTime endDateForMonths(int months) =>
      DateTime(year, month + months, day).subtract(const Duration(days: 1));
}

extension StationsX on List<String> {
  String flow() => where((s) => s.trim().isNotEmpty).join(' → ');
  int transferCount() => (length - 2).clamp(0, 999);
}
