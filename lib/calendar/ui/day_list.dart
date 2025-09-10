// 하루/여러날 리스트 위젯
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/logic/recurrence.dart';
import 'package:hihatu_project/calendar/styles.dart';

class DayList extends StatelessWidget {
  const DayList({
    super.key,
    required this.sections, // dateOnly -> occurrences
  });

  final Map<DateTime, List<Occurrence>> sections;

  @override
  Widget build(BuildContext context) {
    final days = sections.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final d = days[i];
        final items = sections[d] ?? const <Occurrence>[];
        return _DaySection(date: d, items: items);
      },
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.date, required this.items});
  final DateTime date;
  final List<Occurrence> items;

  String _jpW(DateTime d) => const ['日','月','火','水','木','金','土'][d.weekday % 7];

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 섹션 헤더
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            '${date.month}月${date.day}日（${_jpW(date)}）',
            style: const TextStyle(fontWeight: FontWeight.w800, color: iosLabel),
          ),
        ),
        // 항목들
        ...items.map((o) {
          final title = (o.src.title).isEmpty ? '（無題）' : o.src.title;
          final place = (o.src.place ?? '').trim();
          final time = '${_hhmm(o.startLocal)}–${_hhmm(o.endLocal)}';

          return Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              leading: Container(
                width: 10, height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(color: iosBlue, shape: BoxShape.circle),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: iosLabel)),
              subtitle: Text(
                place.isEmpty ? time : '$time  ·  $place',
                style: const TextStyle(color: iosSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // TODO: 상세로 이동
              },
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
