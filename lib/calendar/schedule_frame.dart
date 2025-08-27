import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _iosBlue = Color(0xFF007AFF);
const _iosRed = Color(0xFFFF3B30);
const _iosBg = Color(0xFFF2F2F7);
const _iosLabel = Color(0xFF1C1C1E);
const _iosSecondary = Color(0xFF8E8E93);

// 상단에 상수로 빼두면 재사용 쉬움
const double _railWidth = 56.0;
const double _hourHeight = 80.0; // 타임라인과 동일

// 공통 시간 기준
const int _minHour = 8;
const int _maxHour = 19;

enum SelectionMode { single, pair }

class ScheduleFrame extends StatefulWidget {
  const ScheduleFrame({super.key});

  @override
  State<ScheduleFrame> createState() => _ScheduleFrameState();
}

class _ScheduleFrameState extends State<ScheduleFrame> {
  bool _isMonthView = true; // 월간 ↔ 주간/시간표
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _pivotDate = DateTime.now(); // 주간 앵커
  List<DateTime> _selectedDays = []; // 주간에서 표시할 날짜들(최대 2개)

  SelectionMode _mode = SelectionMode.pair; // 기본: 여러날 (pair)

  final _timeScroll = ScrollController();

  DateTime _dateOnly(DateTime x) => DateTime(x.year, x.month, x.day);

// 탭/이동 시 호출: 모드에 맞게 [d] 또는 [d, d+1]
  void _computeSelectionByMode(DateTime d) {
    final base = _dateOnly(d);

    if (_mode == SelectionMode.single) {
      _selectedDays = [base];
      _pivotDate = base;             // 주간 스트립은 해당 주 유지
    } else {
      final next = base.add(const Duration(days: 1));
      _selectedDays = [base, next];  // [당일, 익일]
      _pivotDate = base;             // 토요일이어도 다음 주로 넘기지 않음(요구사항 반영)
    }

    // (선택) 월간 복귀 시에도 일관되게 보이려면:
    _displayMonth = DateTime(_pivotDate.year, _pivotDate.month, 1);
  }


  void _computePairSelection(DateTime d) {
    final base = _dateOnly(d);
    final next = base.add(const Duration(days: 1));

    // 항상 [당일, 익일]
    _selectedDays = [base, next];

    // pivot을 '항상' 선택한 날짜로 유지 (토요일이어도 주간 스트립은 같은 주를 보여줌)
    _pivotDate = base;

    // 토요일을 탭하면 다음날(일요일) 주로 보여주기 위해 피벗을 next로 이동
    // (Dart: 1=Mon .. 6=Sat, 7=Sun)
    // _pivotDate = (base.weekday == DateTime.saturday) ? next : base;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + delta, 1);
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_timeScroll.hasClients) _timeScroll.jumpTo((9 - _minHour) * _hourHeight); // 9시 근처
    });
  }

  DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);
  bool _same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  // ====== 상단(AppBar + 큰 월 제목(월간일 때만)) ======
  Widget _buildHeader() {
    final yearStr = '${_displayMonth.year}年';
    // 주간 화면일 때는 _pivotDate 기준으로 월을 표시
    final monthStrForWeekly = '${_pivotDate.month}月';

    return Column(
      children: [
        // AppBar: 월간=년도 / 주간=월
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: _iosLabel,
                onPressed: () {
                  if (_isMonthView) {
                    setState(() {
                      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
                    });
                  } else {
                    setState(() {
                      // 주간→월간 복귀 시, 주간에서 보고 있던 달을 월간에도 반영
                      _displayMonth = DateTime(_pivotDate.year, _pivotDate.month, 1);
                      _isMonthView = true;
                      _selectedDays = [];
                    });
                  }
                },
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isMonthView ? yearStr : monthStrForWeekly, // 월간: 2025년 / 주간: 8월
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _iosLabel,
                    ),
                  ),
                ),
              ),

              // ⬇️ 여기! 기존 IconButton(Icons.menu_rounded) 대신 교체
              Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: const PopupMenuThemeData(
                    color: Colors.white,              // 메뉴 배경 흰색
                    surfaceTintColor: Colors.white,   // M3 틴트 제거
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  highlightColor: Color(0xFFF2F2F2),   // 눌림/호버 아주 연한 회색
                  hoverColor: Color(0xFFF2F2F2),
                  splashColor: Colors.transparent,     // 물결 제거(선택)
                ),
                child: PopupMenuButton<SelectionMode>(
                  icon: const Icon(Icons.menu_rounded, color: _iosLabel),
                  position: PopupMenuPosition.under,     // 아이콘 '아래'로
                  offset: const Offset(0, 8),            // 살짝 간격
                  onSelected: (m) {
                    setState(() {
                      _mode = m;
                      final base = _selectedDays.isNotEmpty
                          ? _dateOnly(_selectedDays.first)
                          : _dateOnly(_pivotDate);
                      if (_mode == SelectionMode.single) {
                        _selectedDays = [base];
                        _pivotDate = base;
                      } else {
                        _selectedDays = [base, base.add(const Duration(days: 1))];
                        _pivotDate = base;
                      }
                      _displayMonth = DateTime(_pivotDate.year, _pivotDate.month, 1);
                    });
                  },
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: SelectionMode.single,
                      checked: _mode == SelectionMode.single,
                      child: const Text('하루'),
                    ),
                    CheckedPopupMenuItem(
                      value: SelectionMode.pair,
                      checked: _mode == SelectionMode.pair,
                      child: const Text('여러날'),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.search_rounded),color: _iosLabel, onPressed: () {}),
              IconButton(icon: const Icon(CupertinoIcons.add), color: _iosBlue,  onPressed: () {}),
            ],
          ),
        ),



        // 큰 “8월”은 월간에서만
        if (_isMonthView)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              '${_displayMonth.month}월',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _iosLabel,
              ),
            ),
          ),

        // 고정 요일 줄
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
          child: Row(
            children: List.generate(7, (i) {
              const labels = ['日', '月', '火', '水', '木', '金', '土'];
              final isSun = i == 0;
              final isSat = i == 6;
              final c = isSun ? _iosRed : (isSat ? _iosBlue : _iosSecondary);
              return Expanded(
                child: Center(
                  child: Text(labels[i], style: TextStyle(color: c, fontWeight: FontWeight.w700)),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ====== 월간 그리드 ======
  Widget _buildMonth() {
    final first = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final days = List.generate(42, (i) => _d(start.add(Duration(days: i))));
    final today = _d(DateTime.now());

    const rows = 6;
    const cols = 7;
    const hPad = 8.0;     // 좌우 패딩
    const vPad = 8.0;     // 상하 패딩
    const spacing = 4.0;  // 셀 사이 여백

    return Expanded(
      child: LayoutBuilder(
        builder: (context, cons) {
          // 사용 가능한 영역(패딩/간격 제외)에서 셀 폭·높이 계산
          final availableW = cons.maxWidth - hPad * 2 - spacing * (cols - 1);
          final availableH = cons.maxHeight - vPad * 2 - spacing * (rows - 1);
          final cellW = availableW / cols;
          final cellH = availableH / rows;
          final ratio = cellW / cellH; // ← childAspectRatio

          return GestureDetector(
              behavior: HitTestBehavior.opaque, // 빈 영역도 스와이프 잡도록
              onVerticalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0; // +아래로, -위로
                if (v.abs() < 80) return;               // 임계치(튜닝 가능)
                if (v < 0) {
                  _shiftMonth(1); // 위로 스와이프 → 다음 달
                } else {
                  _shiftMonth(-1); // 아래로 스와이프 → 이전 달
                }
                // (선택) HapticFeedback.selectionClick();
              },
            child: SizedBox( // LayoutBuilder 안에서는 Expanded 쓰지 말고 크기 고정
              width: cons.maxWidth,
              height: cons.maxHeight,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // 고정 그리드
                    itemCount: rows * cols,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: ratio, // ← 핵심!
                    ),
                    itemBuilder: (context, i) {
                      final d = days[i];
                      final inMonth = d.month == _displayMonth.month;
                      final isToday = _same(d, today);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMonthView = false;
                            _computeSelectionByMode(d); // 네가 쓰는 선택 함수
                          });
                        },
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? _iosRed.withValues(alpha:0.12)  // 오늘이면 연한 붉은색 동그라미
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: inMonth ? _iosLabel : _iosSecondary.withValues(alpha:0.5),
                                ),
                              ),
                            ),
                          ),
                        ),

                      );
                    },
                  ),
                ),
              ),
            );
        },
      ),
    );
  }


  // ====== 주간 + 선택일 라벨 + 시간표 ======
  Widget _buildWeekAndTimeline() {
    // 주간 일~토
    List<DateTime> weekOf(DateTime a0) {
      final a = _d(a0);
      final start = a.subtract(Duration(days: a.weekday % 7));
      return List.generate(7, (i) => _d(start.add(Duration(days: i))));
    }

    final week = weekOf(_pivotDate);
    final today = _d(DateTime.now());

    void onTapWeekDate(DateTime d) {
      setState(() {
        _computeSelectionByMode(d);
      });
    }

    void shiftWeek(int deltaWeeks) {
      final deltaDays = 7 * deltaWeeks;
      setState(() {
        // 피벗 이동 기준일
        final base = _dateOnly(_pivotDate).add(Duration(days: deltaDays));
        if (_mode == SelectionMode.single) {
          _selectedDays = [base];
        } else {
          _selectedDays = [base, base.add(const Duration(days: 1))];
        }
        _pivotDate = base;
        _displayMonth = DateTime(base.year, base.month, 1);
      });
    }

    final picked = _selectedDays.isEmpty
        ? (_mode == SelectionMode.single
        ? [_dateOnly(_pivotDate)]
        : [_dateOnly(_pivotDate), _dateOnly(_pivotDate).add(const Duration(days: 1))])
        : _selectedDays;

    return Expanded(
      child: Column(
        children: [
          // 주간 날짜 스트립
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final vx = details.velocity.pixelsPerSecond.dx;
              if (vx < -200) {
                // 왼쪽으로 플릭 → 다음 주 (예: 10~16 → 17~23)
                shiftWeek(1);
              } else if (vx > 200) {
                // 오른쪽으로 플릭 → 이전 주 (예: 10~16 → 3~9)
                shiftWeek(-1);
              }
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: week.map((d) {
                  final isSelected = picked.any((x) => _same(x, d));
                  final isToday = _same(d, today);
                  final dotBg = isSelected
                      ? _iosBlue
                      : (isToday ? _iosRed.withValues(alpha: 0.12) : Colors.transparent);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTapWeekDate(d), // ← 기존 탭은 그대로
                      child: Column(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(color: dotBg, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '${d.day}',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _iosLabel,
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
          ),


          // 선택 날짜 라벨 (예: 8月8日（水）  8月9日（木）)
          Container(
            color: Colors.white,
            child: _SelectedDaysHeader(days: picked),
          ),

          // 시간표
          Expanded(child: _Timeline(days: picked, controller: _timeScroll)),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _iosBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _isMonthView ? _buildMonth() : _buildWeekAndTimeline(),
          ],
        ),
      ),
    );
  }
}

class _SelectedDaysHeader extends StatelessWidget {
  const _SelectedDaysHeader({required this.days});
  final List<DateTime> days;

  String _jpShortW(DateTime d) =>
      const ['日', '月', '火', '水', '木', '金', '土'][0 + (d.weekday % 7)];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // 적당히
      child: Row(
        children: [
          const SizedBox(width: _railWidth), // ← 시간 레일과 동일하게 맞춤
          // 오른쪽 영역: 타임라인과 똑같이 컬럼폭 계산
          Expanded(
            child: LayoutBuilder(
              builder: (context, cons) {
                final colCount = days.length.clamp(1, 2);
                final colWidth = cons.maxWidth / colCount;

                return Stack(
                  children: [
                    // 라벨을 정확히 각 컬럼 중앙에
                    Row(
                      children: List.generate(colCount, (i) {
                        final d = days[i];
                        return SizedBox(
                          width: colWidth,
                          child: Center(
                            child: Text(
                              '${d.month}月${d.day}日（${_jpShortW(d)}）',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _iosLabel,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }),
                    ),
                    // 가운데 세로선 (2일일 때만)
                    if (colCount == 2)
                      Positioned(
                        left: colWidth, // ← 타임라인의 세로 구분선과 같은 좌표
                        top: 6,
                        bottom: 6,
                        child: Container(
                          width: 1,
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====== 시간표(왼쪽 시간 레일 + 오른쪽 타임라인) ======
class _Timeline extends StatelessWidget {
  const _Timeline({required this.days, required this.controller});
  final List<DateTime> days; // 1~2개
  final ScrollController controller;

  double yFromHour(double hour) => (hour - _minHour) * _hourHeight;
  double hFromRange(double startHour, double endHour) => (endHour - startHour) * _hourHeight;


  double _clamp(double x, double lo, double hi) => x < lo ? lo : (x > hi ? hi : x);

  Positioned? clippedEventBox({
    required double rawStartHour, // 7.5 가능
    required double rawEndHour,   // 20.0 가능
    required double left,
    required double width,
    required Widget child,
  }) {
    final s = _clamp(rawStartHour, _minHour.toDouble(), _maxHour.toDouble());
    final e = _clamp(rawEndHour, _minHour.toDouble(), _maxHour.toDouble());
    if (e <= s) return null; // 화면에 안 보임
    return Positioned(
      left: left,
      width: width,
      top: yFromHour(s),
      height: hFromRange(s, e),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final hours = List.generate(25, (i) => i); // 00:00 ~ 24:00
    // final hours = List.generate(12, (i) => i + 8); // 8,9,...19
    final hours = List.generate(_maxHour - _minHour + 1, (i) => i + _minHour);
    final totalHeight = hours.length * _hourHeight;


    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: controller,  // ✅ 하나의 스크롤러로 왼/오른쪽을 함께 스크롤
        child: SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 왼쪽 시간 레일 (스크롤과 함께 내려감)
              SizedBox(
                width: _railWidth,
                child: Column(
                  children: hours.map((h) {
                    return SizedBox(
                      height: _hourHeight,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6, top: 2),
                          child: Text(
                            '${h.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(
                              color: _iosSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── 오른쪽 타임라인 (그리드+이벤트) - 같은 스크롤 안에 있음
              Expanded(
                child: LayoutBuilder(
                  builder: (context, cons) {
                    final colCount = days.length.clamp(1, 2);
                    final colWidth = cons.maxWidth / colCount;

                    return Stack(
                      children: [
                        // 1) 수평 그리드 라인
                        for (int i = 0; i < hours.length; i++)
                          Positioned(
                            top: i * _hourHeight,
                            left: 0,
                            right: 0,
                            child: Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ),

                        // 2) (2일 표시 시) 중앙 세로 구분선
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

                        // 3) (데모) 이벤트 박스들 — 실제 데이터로 교체 예정
                        for (int col = 0; col < colCount; col++) ...[
                          // 예시: 10:00~11:30
                          Positioned(
                            left: col * colWidth + 8,
                            width: colWidth - 16,
                            top: yFromHour(10.0),           // 8시 기준 좌표
                            height: hFromRange(10.0, 11.5), // 8시 기준 높이
                            child: const _EventBox(title: '会議室A'),
                          ),

                          // (선택) 예시: 7:30~8:30 처럼 범위를 스치는 이벤트는 clippedEventBox로
                          // if (col == 0)
                          //   if (clippedEventBox(
                          //     rawStartHour: 7.5, rawEndHour: 8.5,
                          //     left: col * colWidth + 8,
                          //     width: colWidth - 16,
                          //     child: const _EventBox(title: '朝会'),
                          //   ) case final w?) w,

                          // 2일 모드일 때 두 번째 예시
                          if (colCount > 1)
                            Positioned(
                              left: col * colWidth + 8,
                              width: colWidth - 16,
                              top: yFromHour(14.0),
                              height: hFromRange(14.0, 15.0),
                              child: const _EventBox(title: '打合せ'),
                            ),
                        ]
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

class _EventBox extends StatelessWidget {
  const _EventBox({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _iosBlue.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // TODO: 이벤트 디테일로 이동
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: _iosBlue.withValues(alpha: 0.8), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _iosLabel,
            ),
          ),
        ),
      ),
    );
  }
}


