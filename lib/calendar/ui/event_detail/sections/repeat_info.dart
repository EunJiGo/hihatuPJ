import 'package:flutter/material.dart';
import '../../../domain/calendar_single.dart';
import '../../../styles.dart';
import '../../../../utils/date/date_utils.dart';
import '../utils/event_repeat_formatter.dart';
import '../utils/timezone_to_jst.dart'; // parseUtc

// 반복 UI 두 컴포넌트
class RepeatInfo extends StatelessWidget {
  const RepeatInfo({super.key, required this.ev});
  final CalendarSingle ev;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w400, fontSize: 14, color: iosLabel.withValues(alpha: .65),
    );

    if (ev.repeat != 'custom') {
      final label = repeatDetail(ev); // ← 유틸 함수로 이동
      return Text('繰り返し：${label ?? 'なし'}', style: style);
    }
    return _RepeatCustomDates(dates: ev.customDates, textStyle: style);
  }
}

class _RepeatCustomDates extends StatefulWidget {
  const _RepeatCustomDates({required this.dates, this.textStyle});
  final List<String> dates;
  final TextStyle? textStyle;

  @override
  State<_RepeatCustomDates> createState() => _RepeatCustomDatesState();
}

class _RepeatCustomDatesState extends State<_RepeatCustomDates> {
  bool _expanded = false;
  String _format(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  DateTime? _tryParseUtc(String s) {
    final byUtil = parseUtc(s);
    if (byUtil != null) return byUtil.toUtc();
    final core = DateTime.tryParse(s);
    if (core != null) return (s.length == 10)
        ? DateTime.utc(core.year, core.month, core.day)
        : core.toUtc();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.textStyle;
    final parsed = widget.dates.map(_tryParseUtc).whereType<DateTime>().map(toJst).toList()..sort();
    if (parsed.isEmpty) return Text('繰り返し：なし', style: style);

    final all = parsed.map(_format).toList();
    final preview = all.take(3).toList();
    final rest = all.length - preview.length;
    final showList = _expanded ? all : preview;
    final hasMore = !_expanded && rest > 0;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: RichText(
        text: TextSpan(
          style: style,
          children: [
            const TextSpan(text: '繰り返し：'),
            TextSpan(text: showList.join('、')),
            if (hasMore) ...[
              TextSpan(text: ' 外$rest件 '),
              WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(Icons.expand_more, size: 16, color: style?.color)),
            ],
            if (_expanded)
              WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(Icons.expand_less, size: 16, color: style?.color)),
          ],
        ),
      ),
    );
  }
}
