import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/ui/event_detail/sections/repeat_info.dart';
import 'package:hihatu_project/calendar/domain/calendar_single.dart';
import 'package:hihatu_project/calendar/styles.dart';
import 'chips.dart';

// 제목, 기간, 반복, 공개칩
class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key, required this.event, required this.period, required this.isSecret});
  final CalendarSingle event;
  final String period;
  final bool isSecret;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title.isEmpty ? '(タイトルなし)' : event.title,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 25),
            softWrap: true,
          ),
          const SizedBox(height: 8),
          Text(
            period,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w400, fontSize: 14, color: iosLabel.withValues(alpha: 0.65),
            ),
          ),
          RepeatInfo(ev: event), // 기존 _RepeatInfo

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  buildChip(
                    icon: isSecret ? Icons.lock : Icons.lock_open,
                    label: isSecret ? '秘' : '公',
                    background: (isSecret ? Colors.amber.withValues(alpha: .4) : iosBlue.withValues(alpha: .18)),
                    foreground: (isSecret ? Colors.brown : iosBlue),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
