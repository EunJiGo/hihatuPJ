// 월 그리드 + 점 렌더
import 'package:flutter/material.dart';
import '../logic/time_utils.dart';
import '../styles.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.displayMonth,
    required this.eventCountByDay,
    required this.onTapDate,
  });

  final DateTime displayMonth;
  final Map<DateTime, int> eventCountByDay;
  final ValueChanged<DateTime> onTapDate;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(displayMonth.year, displayMonth.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final days  = List.generate(42, (i) => dateOnly(start.add(Duration(days: i))));
    final today = dateOnly(DateTime.now());

    const rows = 6, cols = 7;
    const hPad = 8.0, vPad = 8.0, spacing = 4.0;

    return LayoutBuilder(
      builder: (context, cons) {
        final availableW = cons.maxWidth - hPad * 2 - spacing * (cols - 1);
        final availableH = cons.maxHeight - vPad * 2 - spacing * (rows - 1);
        final cellW = availableW / cols;
        final cellH = availableH / rows;
        final ratio = cellW / cellH;

        return SizedBox(
          width: cons.maxWidth,
          height: cons.maxHeight,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows * cols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: ratio,
              ),
              itemBuilder: (context, i) {
                final d = days[i];
                final inMonth = d.month == displayMonth.month;
                final isToday = _same(d, today);
                final count = eventCountByDay[dateOnly(d)] ?? 0;

                return GestureDetector(
                  onTap: () => onTapDate(d),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday ? iosRed.withValues(alpha: 0.25) : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: inMonth ? iosLabel : iosSecondary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      _eventDots(count),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  bool _same(DateTime a, DateTime b) => a.year==b.year && a.month==b.month && a.day==b.day;

  Widget _eventDots(int count) {
    if (count <= 0) return const SizedBox.shrink();
    final show = count.clamp(1, 3);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(show, (_) => Container(
            width: 6, height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: const BoxDecoration(color: iosBlue, shape: BoxShape.circle),
          )),
          if (count > 3)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text('+${count - 3}',
                style: const TextStyle(fontSize: 10, color: iosSecondary, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
