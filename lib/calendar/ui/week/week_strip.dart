// 주간 날짜 스트립(일~토 숫자 줄 + 파란 동그라미 강조)
import 'package:flutter/material.dart';
import '../styles.dart';
import '../logic/time_utils.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.pivotDate,
    required this.selectedDays,
    required this.onTapDate,
    required this.onSwipePrevWeek,
    required this.onSwipeNextWeek,
  });

  final DateTime pivotDate;
  final List<DateTime> selectedDays;
  final ValueChanged<DateTime> onTapDate;
  final VoidCallback onSwipePrevWeek;
  final VoidCallback onSwipeNextWeek;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // 일(0) 시작 주 계산(Sun~Sat). 필요시 Mon-start로 바꿔도 됨.
  List<DateTime> _weekOf(DateTime a0) {
    final a = dateOnly(a0);
    final start = a.subtract(Duration(days: a.weekday % 7));
    return List.generate(7, (i) => dateOnly(start.add(Duration(days: i))));
  }

  @override
  Widget build(BuildContext context) {
    final week = _weekOf(pivotDate);
    final today = dateOnly(DateTime.now());

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final vx = details.velocity.pixelsPerSecond.dx;
        if (vx < -200) {
          onSwipeNextWeek(); // 왼쪽으로 → 다음주
        } else if (vx > 200) {
          onSwipePrevWeek(); // 오른쪽으로 → 지난주
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: week.map((d) {
            final isSelected = selectedDays.any((x) => _sameDay(x, d));
            final isToday = _sameDay(d, today);
            final bg = isSelected
                ? iosBlue
                : (isToday ? iosRed.withValues(alpha:0.12) : Colors.transparent);
            final fg = isSelected ? Colors.white : iosLabel;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTapDate(d),
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '${d.day}',
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
