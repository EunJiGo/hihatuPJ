import '../../../domain/calendar_single.dart';

/// 반복 규칙을 일본어 문자열로 변환
String? repeatDetail(CalendarSingle ev) {
  switch (ev.repeat) {
    case 'daily':
      return '毎日';
    case 'weekly':
    case 'biweekly':
      if (ev.repeatWeekdays.isEmpty) return '指定なし';
      final map = {1: '月', 2: '火', 3: '水', 4: '木', 5: '金', 6: '土', 7: '日'};
      final days = ev.repeatWeekdays.map((d) => map[d] ?? '$d').join('·');
      return (ev.repeat == 'biweekly') ? '隔週 ${days}曜日' : '毎週 ${days}曜日';
    case 'monthly':
      if (ev.repeatMonthDays.isEmpty) return '指定なし';
      final days = ev.repeatMonthDays.map((d) => '$d日').join('·');
      return '毎月 $days';
    case 'yearly':
      final m = ev.repeatYearMonth;
      final d = ev.repeatYearDay;
      if (m == null || d == null) return '指定なし';
      return '毎年 ${m}月 ${d}日';
    case 'custom':
      if (ev.customDates.isEmpty) return null;
      final preview = ev.customDates.take(3).join(', ');
      final more = ev.customDates.length > 3 ? ' 外 ${ev.customDates.length - 3}件' : '';
      return '$preview$more';
    default:
      return null;
  }
}
