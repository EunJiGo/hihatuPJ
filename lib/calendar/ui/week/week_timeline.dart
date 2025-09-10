// 시간표(좌 레일+우 스택)
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/logic/recurrence.dart';
import 'package:hihatu_project/calendar/styles.dart';
import 'package:hihatu_project/calendar/ui/shared/event_box.dart';
import 'package:hihatu_project/calendar/ui/event_detail/event_detail_page.dart';

class WeekTimeline extends StatelessWidget {
  const WeekTimeline({
    super.key,
    required this.days,
    required this.controller,
    required this.dayOccurrences, // 추가(occurrence_expander 위함)
    this.onRefreshRequested, // 새로고침 위함
    this.onTapOccurrence,
  });

  final List<DateTime> days; // 1~2일
  final ScrollController controller;
  final Map<DateTime, List<Occurrence>>
  dayOccurrences; // 추가(occurrence_expander 위함)
  final Future<void> Function()? onRefreshRequested; // 새로고침 위함
  final void Function(Occurrence occ)? onTapOccurrence;

  double _yFromHour(double hour) => (hour - minHour) * hourHeight;

  double _hFromRange(double startHour, double endHour) =>
      (endHour - startHour) * hourHeight;

  double _clamp(double x, double lo, double hi) =>
      x < lo ? lo : (x > hi ? hi : x); // 추가(occurrence_expander 위함)

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(maxHour - minHour + 1, (i) => i + minHour);
    final totalHeight = hours.length * hourHeight;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: controller,
        child: SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 좌측 시간 레일
              SizedBox(
                width: railWidth,
                child: Column(
                  children: hours
                      .map(
                        (h) => SizedBox(
                          height: hourHeight,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6, top: 2),
                              child: Text(
                                '${h.toString().padLeft(2, '0')}:00',
                                style: const TextStyle(
                                  color: iosSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              // 오른쪽 타임라인
              Expanded(
                child: LayoutBuilder(
                  builder: (context, cons) {
                    final colCount = days.length.clamp(1, 2);
                    final colWidth = cons.maxWidth / colCount;

                    return Stack(
                      children: [
                        // 수평 라인
                        for (int i = 0; i < hours.length; i++)
                          Positioned(
                            top: i * hourHeight,
                            left: 0,
                            right: 0,
                            child: Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                        // 중앙 세로선 (2일)
                        if (colCount == 2)
                          Positioned(
                            left: colWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 1,
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ),

                        // 실제 발생 박스들
                        for (int col = 0; col < colCount; col++) ...[
                          _DayColumn(
                            day: DateTime(
                              days[col].year,
                              days[col].month,
                              days[col].day,
                            ),
                            left: col * colWidth + 8,
                            width: colWidth - 16,
                            occs:
                                dayOccurrences[DateTime(
                                  days[col].year,
                                  days[col].month,
                                  days[col].day,
                                )] ??
                                const [],
                            yFromHour: _yFromHour,
                            hFromRange: _hFromRange,
                            clamp: _clamp,
                            onRefreshRequested: onRefreshRequested,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.left,
    required this.width,
    required this.occs,
    required this.yFromHour,
    required this.hFromRange,
    required this.clamp,
    this.onRefreshRequested,
  });

  final DateTime day; // dateOnly
  final double left;
  final double width;
  final List<Occurrence> occs;
  final double Function(double) yFromHour;
  final double Function(double, double) hFromRange;
  final double Function(double, double, double) clamp;
  final Future<void> Function()? onRefreshRequested;

  double _hourOf(DateTime dt) =>
      dt.hour + dt.minute / 60.0 + dt.second / 3600.0;

  @override
  Widget build(BuildContext context) {
    const minBoxPx = 24.0; // 너무 짧은 일정도 보이게 최소 높이

    return Stack(
      children: [for (final o in occs) _buildBox(context, o, minBoxPx)],
    );
  }

  Widget _buildBox(BuildContext context, Occurrence o, double minBoxPx) {
    // 이미 day로 클리핑된 구간이 넘어온 상태
    final startH = _hourOf(o.startLocal);
    final endH = _hourOf(o.endLocal);
    final s = clamp(startH, minHour.toDouble(), maxHour.toDouble());
    final e = clamp(endH, minHour.toDouble(), maxHour.toDouble());
    final top = yFromHour(s);
    final baseH = e > s ? hFromRange(s, e) : 1.0; // ← 1.0 (double)
    final h = baseH < minBoxPx ? minBoxPx : baseH; // ← double 유지
    final dayJst = DateTime(day.year, day.month, day.day);

    return Positioned(
      left: left,
      width: width,
      top: top,
      height: h,
      child: EventBox(
        occurrence: o,
        dayJst: dayJst,
        onTap: (occ) async {
          // ✅ 결과 대기
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => EventDetailPage(event: occ.src, pivotJst: dayJst),
            ),
          );
          if (changed == true && onRefreshRequested != null) {
            await onRefreshRequested!(); // ✅ 부모에 새로고침 요청
          }
        },
      ),
    );
  }
}
