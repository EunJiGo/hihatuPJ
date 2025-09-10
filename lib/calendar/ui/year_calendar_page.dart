import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/styles.dart';
import 'package:hihatu_project/calendar/types.dart';
import 'shared/header.dart';

class YearCalendarPage extends StatefulWidget {
  const YearCalendarPage({
    super.key,
    required this.year,
    required this.currentY,
    required this.currentM,
    required this.selectedM,
    this.onTapSearch,
    this.onTapAdd,
  });

  final int year;
  final int currentY;
  final int currentM;
  final int selectedM;

  final VoidCallback? onTapSearch;
  final VoidCallback? onTapAdd;

  @override
  State<YearCalendarPage> createState() => _YearCalendarPageState();
}

class _YearCalendarPageState extends State<YearCalendarPage> {
  late int _year; // 화면에 표시할 연도 상태

  @override
  void initState() {
    super.initState();
    _year = widget.year;
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v.abs() < 80) return; // 민감도(임계값) — 취향대로 조정

    setState(() {
      if (v < 0) {
        // 위로 플릭 → 다음 해
        _year += 1;
      } else {
        // 아래로 플릭 → 이전 해
        _year -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: iosBg,
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: _onVerticalDragEnd, // 세로 스와이프 연결
        child: Column(
          children: [
            // 1) 상단 툴바 (검색/추가만)
            ScheduleHeader(
              variant: HeaderVariant.year,
              isMonthView: true,
              displayMonth: DateTime(_year, 1, 1),
              pivotDate: DateTime.now(),
              mode: SelectionMode.single,
              onTapPrev: () {},
              onChangeMode: (_) {},
              onTapSearch: widget.onTapSearch ?? () {},
              onTapAdd: widget.onTapAdd ?? () {},
              onSwitchToMonthFromWeek: () {},
              onTapThisMonth: () {},
              onSelectMonthFromYear: (_, __) {},
            ),

            // 2) 연도 타이틀은 여기서 직접
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 2),
              child: Text(
                '$_year年',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _year == widget.currentY
                      ? iosRed.withValues(alpha: 0.80)
                      : iosLabel,
                ),
              ),
            ),
            Divider(
              color: Colors.black12, // 선 색
              thickness: 1, // 선 두께
              height: 0, // 위아래 여백 포함 높이
              indent: 10, // 왼쪽 여백
              endIndent: 10, // 오른쪽 여백
            ),
            // 3) 미니 달력 그리드
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const crossCount = 3; // 열: 3
                  const mainCount = 4;  // 행: 4

                  // 바깥 그리드 패딩/간격 (붙여서 꽉 채우고 싶으면 0으로)
                  const gridHPad = 10.0;
                  const gridVPad = 10.0;
                  const crossSpacing = 0.0;
                  const mainSpacing  = 0.0;

                  final gridW = constraints.maxWidth - gridHPad * 2;
                  final gridH = constraints.maxHeight - gridVPad * 2;

                  // 각 타일의 '목표' 폭/높이 (그리드 영역을 정확히 3x4로 나눔)
                  final tileW = (gridW - crossSpacing * (crossCount - 1)) / crossCount;
                  final tileH = (gridH - mainSpacing  * (mainCount  - 1)) / mainCount;

                  final tileAspect = tileW / tileH;

                  const months = [1,2,3,4,5,6,7,8,9,10,11,12];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(gridHPad, gridVPad, gridHPad, gridVPad),
                    child: GridView.builder(
                      // ✅ 스크롤 완전 차단
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.zero,
                      itemCount: 12,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        mainAxisSpacing: mainSpacing,
                        crossAxisSpacing: crossSpacing,
                        childAspectRatio: tileAspect, // 실제 영역 기준 종횡비
                      ),
                      itemBuilder: (context, idx) {
                        final m = months[idx];
                        final isThisMonth = (_year == widget.currentY && m == widget.currentM);
                        final isSelectedMonth = (m == widget.selectedM);

                        return _YearMonthTile(
                          year: _year,
                          month: m,
                          isThisMonth: isThisMonth,
                          isSelectedMonth: isSelectedMonth,
                          onTap: () {
                            Navigator.pop<({int year, int month})>(context, (year: _year, month: m));
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YearMonthTile extends StatelessWidget {
  const _YearMonthTile({
    required this.year,
    required this.month,
    required this.isThisMonth,
    required this.isSelectedMonth,
    required this.onTap,
  });

  final int year;
  final int month;
  final bool isThisMonth;
  final bool isSelectedMonth;
  final VoidCallback onTap;

  static const List<String> _weekday = ['日','月','火','水','木','金','土'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final firstWeekday =
        firstDay.weekday % 7; // 0:Sun ~ 6:Sat (Dart는 Mon=1..Sun=7)
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // 달력 셀(앞쪽 공백 + 일수)
    final totalCells = firstWeekday + daysInMonth;
    final trailing = (totalCells % 7 == 0) ? 0 : (7 - (totalCells % 7));

    // AFTER ✅ growable 리스트로 생성
    final cells = List<int?>.filled(firstWeekday, null, growable: true)
      ..addAll(List<int>.generate(daysInMonth, (i) => i + 1))
      ..addAll(List<int?>.filled(trailing, null, growable: true));


    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isSelectedMonth ? iosBlue : Colors.white,
          width: isSelectedMonth ? 2 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          // padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 이거 없으면 월은 가운데 정렬됨
            children: [
              // 월 타이틀
              Text(
                '$month月',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelectedMonth
                      ? FontWeight.w800
                      : FontWeight.w700,
                  // color: isSelectedMonth ? iosBlue : iosLabel,
                  color: isThisMonth
                      ? iosRed.withValues(alpha: 0.80)
                      : iosLabel,
                ),
                textAlign: TextAlign.left, // ★ 혹시 모를 텍스트 정렬 보강
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // 요일 헤더 (日~土)
              SizedBox(
                height: 14, // 요일 헤더(고정 높이로 공간 절약)
                child: Row(
                  children: List.generate(7, (i) {
                    final isSun = i == 0, isSat = i == 6;
                    final c = isSun ? iosRed : (isSat ? iosBlue : iosSecondary);
                    return Expanded(
                      child: Center(
                        child: Text(
                          _weekday[i],
                          style: TextStyle(
                            fontSize: 9,
                            color: c,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cells.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,
                  ),
                  itemBuilder: (_, i) {
                    final day = cells[i];
                    if (day == null) return const SizedBox.shrink();
                    final isToday = _isToday(year, month, day);
                    return Center(
                      child: Container(
                        width: 18,  // ← 원하는 크기로 조절 (텍스트보다 넉넉히)
                        height: 18,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? iosRed.withValues(alpha: 0.40)
                              : Colors.transparent,
                        ),
                        child: Transform.translate(
                          offset: const Offset(0, - 1), // y축으로 1px 정도 내림 : 1 / y축으로 1px 정도 올림 : -1
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: iosLabel,
                            ),
                          ),
                        ),
                      ),
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

  bool _isToday(int y, int m, int d) {
    final now = DateTime.now();
    return now.year == y && now.month == m && now.day == d;
  }
}
