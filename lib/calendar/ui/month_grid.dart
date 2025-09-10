// 월 그리드 + 점 렌더
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/logic/time_utils.dart';
import 'package:hihatu_project/calendar/styles.dart';
import 'package:hihatu_project/calendar/types.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.displayMonth,
    required this.eventCountByDay,
    required this.onTapDate,
    this.badgesByDay,
    this.equipmentBadges,
    this.peopleBadges,
  });

  final DateTime displayMonth;
  final Map<DateTime, int> eventCountByDay;
  final ValueChanged<DateTime> onTapDate;
  final Map<DateTime, MonthBadge>? badgesByDay;
  final Map<DateTime, int>? equipmentBadges; // 설비(회의실, 설비)
  final Map<DateTime, int>? peopleBadges;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(displayMonth.year, displayMonth.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final days = List.generate(
        42, (i) => dateOnly(start.add(Duration(days: i))));
    final today = dateOnly(DateTime.now());

    const rows = 6,
        cols = 7;
    const hPad = 8.0,
        vPad = 8.0,
        spacing = 4.0;

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
                final d = days[i]; // 오늘 셀의 날짜(이미 dateOnly)
                final inMonth = d.month == displayMonth.month;
                final isToday = _same(d, today);

                final blueCount = eventCountByDay[d] ?? 0; // 🔵 파란 점 개수
                final greenCount = peopleBadges?[d] ?? 0; // 🟢 녹색 점 개수 (int로!)
                final grayCount = equipmentBadges?[d] ?? 0; // ⚪️ 회색 점 개수 (int로!)

                return GestureDetector(
                  onTap: () => onTapDate(d),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // 프로젝트에 withValues 확장 써왔으면 유지, 기본 Flutter면 withOpacity(0.25)로 바꾸면 됨
                          color: isToday
                              ? iosRed.withValues(alpha: 0.25)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: inMonth ? iosLabel : iosSecondary
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      // 🔵 파란 점(이벤트 개수)
                      _eventDots(blueCount),
                      // 🟢 녹색 점(다른 사원 예약 개수)
                      _peopleDots(greenCount),
                      // ⚪️ 회색 점(설비 예약 개수)
                      _equipDots(grayCount),
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

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // 파란 점: 개수 기반(최대 3개 + +N)
  Widget _eventDots(int count) {
    if (count <= 0) return const SizedBox.shrink();
    final show = count.clamp(1, 3);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(show, (_) =>
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: const BoxDecoration(
                    color: iosBlue, shape: BoxShape.circle),
              )),
          if (count > 3)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                '+${count - 3}',
                style: const TextStyle(fontSize: 10,
                    color: iosSecondary,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // 초록 점: 사람(선택한 사원들) 개수
  Widget _peopleDots(int count) {
    if (count <= 0) return const SizedBox.shrink();
    final show = count.clamp(1, 3);
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
            show,
                (_) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: const BoxDecoration(
                color: scheduleGreen, // ✅ styles.dart에 추가한 초록색
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (count > 3) const SizedBox(width: 2),
          if (count > 3)
            Text(
              '+${count - 3}',
              style: const TextStyle(
                fontSize: 10,
                color: iosSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }


// 회색 점: 개수 기반(최대 3개 + +N)
  Widget _equipDots(int count) {
    if (count <= 0) return const SizedBox.shrink();
    final show = count.clamp(1, 3);
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(show, (_) =>
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: const BoxDecoration(
                    color: iosSecondary, shape: BoxShape.circle),
              )),
          if (count > 3)
            const SizedBox(width: 2),
          if (count > 3)
            Text(
              '+${count - 3}',
              style: const TextStyle(fontSize: 10,
                  color: iosSecondary,
                  fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
