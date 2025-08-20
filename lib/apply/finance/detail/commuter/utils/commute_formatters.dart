import 'package:intl/intl.dart';

String formatCommuteDuration(String? duration) {
  switch (duration) {
    case '1m':
      return '１ヶ月';
    case '3m':
      return '３ヶ月';
    case '6m':
      return '６ヶ月';
    default:
      return '-';
  }
}

String formatCurrency(int? amount) {
  final formatter = NumberFormat('#,###');
  return formatter.format(amount ?? 0);
}
