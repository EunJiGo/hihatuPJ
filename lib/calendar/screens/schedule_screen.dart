import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hihatu_project/calendar/widgets/event_detail_page.dart';
import 'package:hihatu_project/calendar/widgets/schedule_list_view.dart';
import 'package:hihatu_project/calendar/widgets/week_strip.dart';
import 'package:hihatu_project/calendar/widgets/year_calendar_page.dart';
import 'data/fetch_calendar_single_list.dart';
import 'domain/calendar_single.dart';
import 'domain/calendar_single_response.dart';
import 'logic/occurrence_expander.dart';
import 'logic/recurrence.dart';
import 'styles.dart';
import 'logic/time_utils.dart';
import 'logic/badge_counter.dart';
import 'logic/debug_logger.dart';
import 'ui/shared/header.dart';
import 'widgets/month_grid.dart';
import 'widgets/selected_days_header.dart';
import 'widgets/week_timeline.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<CalendarSingleResponse> _futureCalendar; // 첫 로딩용 API Future 핸들
  bool _loading = false; // 중복 fetch 방지 플래그
  bool _isMonthView = true; // true: 시작은 월간 뷰

  // 상태 추가
  late DateTime _listMin;
  late DateTime _listMax;
  late DateTime _globalMin; // 전체 이벤트의 최소 날짜(로컬 자정)
  late DateTime _globalMax; // 전체 이벤트의 최대 날짜(로컬 자정)
  List<DateTime> _days = [];
  Map<DateTime, List<Occurrence>> _byDay = {};
  DateTime? _anchorToPreserve;
  bool _extending = false; // 동시 확장 방지
  // 확장 단위
  static const _chunk = Duration(days: 180);

  static const _kModeKey = 'selection_mode_v1';

  // 월간 뷰의 표시중인 달을을 항ㅅ항 1일로 정규화
  DateTime _displayMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _pivotDate = DateTime.now(); // 주간/일간 전환의 기준일(주간 스트립과 타임라인에서 중심 날짜).
  List<DateTime> _selectedDays = []; // 사용자가 탭해서 고른 날짜들. 비어 있으면 내부 규칙으로 계산.
  SelectionMode _mode = SelectionMode.single; // single: 주간캘린더에서 일자 하나만, pair: 주간캘린더에서 일자 두 개 볼 수 있게 구분해놓은 것
  Future<void> _saveMode(SelectionMode m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kModeKey, modeToInt(m));
  }

  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kModeKey);
    if (v != null) {
      setState(() => _mode = intToMode(v));
    }
  }


  final _timeScroll = ScrollController(); // 주간 타임라인의 세로 스크롤 컨트롤러.

  List<CalendarSingle> _events = []; // 서버에서 받아온 원본 일정 목록.
  Map<DateTime, int> _eventCountByDay = {}; // 월간 그리드의 날짜별 점(개수) 렌더용 데이터.

  // 계산 프로퍼티
  // 선택된 날짜들을 항상 1~2개로 반환하는 헬퍼(중복 로직 제거용)
  List<DateTime> get _effectiveDays => _selectedDays.isEmpty
      ? (_mode == SelectionMode.single
            ? [dateOnly(_pivotDate)]
            : [
                dateOnly(_pivotDate),
                dateOnly(_pivotDate).add(const Duration(days: 1)),
              ])
      : _selectedDays;

  DateTime get _focusDayForList => DateTime(
    _selectedDays.isNotEmpty ? _selectedDays.first.year : _pivotDate.year,
    _selectedDays.isNotEmpty ? _selectedDays.first.month : _pivotDate.month,
    _selectedDays.isNotEmpty ? _selectedDays.first.day : _pivotDate.day,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 첫 프레임 이후 주간 타임라인 스크롤을 오전 9시로 점프
      if (_timeScroll.hasClients) {
        final offset = (9 - minHour) * hourHeight;
        if (offset > 0) _timeScroll.jumpTo(offset);
      }
    });

    _futureCalendar = fetchCalendarSingleList(true);
    _loadCalendar();
    _loadSavedMode(); // 마지막 메뉴선택 불러오기(single, pair, list)
  }

  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // _ScheduleScreenState 내부에 추가
  DateTime _parseLocal(Object? v) {
    if (v is DateTime) return v.toLocal();
    if (v is String) {
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt.toLocal();
    }
    // 파싱 실패 시 지금 시각(혹은 적당한 기본값)으로
    return DateTime.now();
  }

  void _computeGlobalBounds() {
    if (_events.isEmpty) {
      final today = _dOnly(DateTime.now());
      _globalMin = today;
      _globalMax = today;
      return;
    }
    DateTime minD = DateTime(9999);
    DateTime maxD = DateTime(0);
    for (final e in _events) {
      // 프로젝트의 파서로 로컬 시간으로 변환(이미 갖고 있으면 그걸 사용)
      final s = _parseLocal(e.start); // or DateTime.parse(...) + toLocal()
      final t = _parseLocal(e.end);
      final sd = _dOnly(s);
      final td = _dOnly(t);
      if (sd.isBefore(minD)) minD = sd;
      if (td.isAfter(maxD)) maxD = td;
    }
    _globalMin = minD;
    _globalMax = maxD;
  }

  void _initListWindow() {
    final focus = dateOnly(_focusDayForList);
    // 포커스 ± 청크, but 글로벌 범위로 클램프
    _listMin = _dOnly(focus.subtract(_chunk));
    if (_listMin.isBefore(_globalMin)) _listMin = _globalMin;

    _listMax = _dOnly(focus.add(_chunk));
    if (_listMax.isAfter(_globalMax)) _listMax = _globalMax;

    _days = buildDaySpan(windowStart: _listMin, windowEnd: _listMax);
    _byDay = occurrencesByDay(events: _events, days: _days);
    _anchorToPreserve = null;
  }

  Future<void> _extendPast(DateTime anchorDay) async {
    if (_extending) return;
    if (!_listMin.isAfter(_globalMin)) return; // 이미 첫날
    _extending = true;

    final targetMin = _listMin.subtract(_chunk);
    final newMin = targetMin.isBefore(_globalMin) ? _globalMin : targetMin;

    final extDays = buildDaySpan(
      windowStart: newMin,
      windowEnd: _listMin.subtract(const Duration(days: 1)),
    );
    if (extDays.isNotEmpty) {
      final extMap = occurrencesByDay(events: _events, days: extDays);
      _days = [...extDays, ..._days];
      _byDay = {...extMap, ..._byDay};
      _listMin = newMin;

      // ✅ 여기!
      final anchorLocal = anchorDay;
      _anchorToPreserve = anchorLocal;
      setState(() {});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_anchorToPreserve == anchorLocal) {
          setState(() => _anchorToPreserve = null);
        }
      });
    }
    _extending = false;
  }

  Future<void> _extendFuture(DateTime anchorDay) async {
    if (_extending) return;
    if (!_listMax.isBefore(_globalMax)) return; // 이미 마지막날
    _extending = true;

    final targetMax = _listMax.add(_chunk);
    final newMax = targetMax.isAfter(_globalMax) ? _globalMax : targetMax;

    final extDays = buildDaySpan(
      windowStart: _listMax.add(const Duration(days: 1)),
      windowEnd: newMax,
    );
    if (extDays.isNotEmpty) {
      final extMap = occurrencesByDay(events: _events, days: extDays);
      _days = [..._days, ...extDays];
      _byDay = {..._byDay, ...extMap};
      _listMax = newMax;
      // _anchorToPreserve = anchorDay;
      _anchorToPreserve = null;
      setState(() {});
    }
    _extending = false;
  }

  // 월간 그리드에 찍을 점(일정 개수)을 다시 계산해서 상태에 반영 / 로그도 출력
  Future<void> _loadCalendar() async {
    try {
      final res =
          await _futureCalendar; // _futureCalendar는 앞에서 만들어둔 API 호출 Future 객체
      _events = res.data;
      _recomputeMonthBadges();
      _computeGlobalBounds(); // ← 추가 (로딩/갱신 후 전체 범위 갱신)
    } catch (e, st) {
      debugPrint('fetch error: $e\n$st');
    }
    setState(() {});
  }

  // 다시 가져오기(갱신) 공통 루틴
  Future<void> _reFetch({bool recomputeMonth = false}) async {
    if (_loading) return; // 중복 요청 방지
    _loading = true;
    setState(() {});

    try {
      final res = await fetchCalendarSingleList(true); // ★ 유일한 API 호출
      _events = res.data;

      // 월간 점 다시 만들지 여부
      if (recomputeMonth || _isMonthView) {
        _recomputeMonthBadges();
        _computeGlobalBounds(); // ← 추가 (로딩/갱신 후 전체 범위 갱신)
      } else {
        setState(() {}); // 일/여러날은 build에서 occurrencesByDay가 즉시 반영됨
      }
    } catch (e, st) {
      debugPrint('fetch error: $e\n$st');
    } finally {
      _loading = false;
      setState(() {});
    }
  }

  // 월간 뷰에 스케줄 개수만틈 파란색 점 나타내게(3개이상면 +n)
  void _recomputeMonthBadges() {
    _eventCountByDay = computeBadgeCounts(
      displayMonth: _displayMonth,
      events: _events,
    );
    debugLogMonthBadges(displayMonth: _displayMonth, events: _events);
    setState(() {});
  }

  // 선택 로직(single(1개) vs pair(2개))
  void _computeSelectionByMode(DateTime d) {
    final base = dateOnly(d);
    if (_mode == SelectionMode.single) {
      _selectedDays = [base];
      _pivotDate = base;
    } else {
      final next = base.add(const Duration(days: 1));
      _selectedDays = [base, next];
      _pivotDate = base;
    }
    _displayMonth = DateTime(_pivotDate.year, _pivotDate.month, 1);
    setState(() {});
  }

  void _shiftMonth(int delta) async {
    _displayMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month + delta,
      1,
    );
    setState(() {}); // UI 먼저 반영
    await _reFetch(recomputeMonth: true); // ★ 월간 점 다시 계산까지
  }

  // 주간 이동 헬퍼
  void _shiftWeek(int deltaWeeks) async {
    final base = dateOnly(_pivotDate).add(Duration(days: 7 * deltaWeeks));
    if (_mode == SelectionMode.single) {
      _selectedDays = [base];
    } else {
      _selectedDays = [base, base.add(const Duration(days: 1))];
    }
    _pivotDate = base;
    _displayMonth = DateTime(base.year, base.month, 1);
    setState(() {});
    await _reFetch(); // ★ 슬라이드마다 재호출
  }

  Future<void> _openYearCalendar(BuildContext context) async {
    final result = await Navigator.of(context).push<({int year, int month})>(
      MaterialPageRoute(
        builder: (_) => YearCalendarPage(
          year: _displayMonth.year,
          currentY: DateTime.now().year,
          currentM: DateTime.now().month,
          selectedM: _displayMonth.month,
        ),
      ),
    );
    if (result != null) {
      // 연간 뷰에서 월 선택 → 월간으로 이동
      _isMonthView = true;
      _displayMonth = DateTime(result.year, result.month, 1);
      _pivotDate = DateTime(result.year, result.month, 1);
      _selectedDays = [];
      setState(() {});
      await _reFetch(recomputeMonth: true);
    }
  }

  void _enterListAt(DateTime focusDay) {
    final base = dateOnly(focusDay);
    _mode = SelectionMode.list;
    _isMonthView = false;
    _selectedDays = [base];
    _pivotDate = base;

    // ★ 리스트 상태 초기화 → 새 포커스 기준으로 윈도우 재구성하게 함
    _days.clear();
    _byDay.clear();
    _anchorToPreserve = null;

    setState(() {});
    _saveMode(_mode);
  }

  @override
  Widget build(BuildContext context) {
    final dayOccMap = occurrencesByDay(events: _events, days: _effectiveDays);
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: iosBg,
      body: SafeArea(
        child: Column(
          children: [
            ScheduleHeader(
              variant: _isMonthView ? HeaderVariant.month : HeaderVariant.week,
              // 새 enum 사용: month / week
              isMonthView: _isMonthView,
              displayMonth: _displayMonth,
              pivotDate: _pivotDate,
              mode: _mode,
              hideWeekdayLabels: _mode == SelectionMode.list,
              // ★ 리스트에서 요일 라벨 숨김
              onTapPrev: () => _shiftMonth(-1),
              // (선택) 주간 뷰에서만 의미 있게 쓰려면 유지, 월간에서는 더 이상 호출되지 않음
              onChangeMode: (m) async {
                // ① 모드 먼저 반영
                _mode = m;

                // ② 리스트 모드로 전환할 때만 리스트 입장 로직 호출
                if (m == SelectionMode.list) {
                  _enterListAt(_pivotDate);  // 현재 pivot 유지하고 리스트로
                  setState(() {});
                  await _reFetch();
                  return;
                }

                // ③ 주간 모드(単一日/複数日)는 '현재 pivot(리스트에서 스크롤로 바뀐 값)' 기준으로 전환
                final base = dateOnly(_pivotDate);
                _selectedDays = (m == SelectionMode.single)
                    ? [base]
                    : [base, base.add(const Duration(days: 1))];

                _isMonthView = false; // 주간 영역 보여주기
                _displayMonth = DateTime(base.year, base.month, 1);

                setState(() {});
                await _reFetch();
              },
              onTapSearch: () {},
              onTapAdd: () {},
              onSwitchToMonthFromWeek: () async {
                _displayMonth = DateTime(_pivotDate.year, _pivotDate.month, 1);
                _isMonthView = true;
                _selectedDays = [];
                setState(() {});
                await _reFetch(recomputeMonth: true); // ★ 월간로 전환 시 재호출 + 점 갱신
              },
              onTapThisMonth: () async {
                final now = DateTime.now();
                // 월간 보기에 고정하고 현재 달로 이동
                _isMonthView = true;
                _displayMonth = DateTime(now.year, now.month, 1);
                // (권장) 주간 전환 시 기준이 되도록 pivot도 오늘로
                _pivotDate = now;
                // (선택) 월간에서는 선택 해제
                _selectedDays = [];
                setState(() {});
                // 서버에서 다시 가져오고 월 배지 재계산
                await _reFetch(recomputeMonth: true);
              },
              // ★ 연간 페이지에서 월 선택했을 때: 해당 월의 월간 캘린더로 이동
              onSelectMonthFromYear: (year, month) async {
                _isMonthView = true;
                _displayMonth = DateTime(year, month, 1);
                _pivotDate = DateTime(year, month, 1); // 주간 전환 기준일 동기화(원하면 유지)
                _selectedDays = []; // 월간에서는 선택 비움(선호에 따라 유지 가능)
                setState(() {});
                await _reFetch(recomputeMonth: true);
              },
              // // ★ 추가: 연도 그리드에서 월 선택 시 처리
              // onSelectMonthFromYear: (year, month) async {
              //   _isMonthView = true;
              //   _displayMonth = DateTime(year, month, 1);
              //   // 월간에서는 선택 해제(원하면 유지 가능)
              //   _selectedDays = [];
              //   // 주간 전환의 기준일도 해당 월 1일로 맞추거나, today 유지하고 싶으면 바꿔도 됨
              //   _pivotDate = DateTime(year, month, 1);
              //   setState(() {});
              //   await _refetch(recomputeMonth: true);
              // },
            ),

            // 월/주 뷰 전환 영역
            Expanded(
              child: _isMonthView
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragEnd: (d) {
                        final v = d.primaryVelocity ?? 0;
                        if (v.abs() < 80) return;
                        v < 0 ? _shiftMonth(1) : _shiftMonth(-1);
                      },
                      child: MonthGrid(
                        displayMonth: _displayMonth,
                        eventCountByDay: _eventCountByDay,
                        // onTapDate: (d) async {
                        //   _isMonthView = false;
                        //   _computeSelectionByMode(d); // 선택/피벗 갱신
                        //   setState(() {});
                        //   await _reFetch(); // ★ 전개는 build에서 occurrencesByDay가 처리
                        // },
                        onTapDate: (d) async {
                          if (_mode == SelectionMode.list) {
                            // 리스트 모드일 때만 목록 화면으로 진입
                            _enterListAt(d);
                            await _reFetch();
                            return;
                          }
                          // 단일/복수 모드에선 주간 화면 유지 + 날짜만 갱신
                          _isMonthView = false;
                          _computeSelectionByMode(d);
                          setState(() {});
                          await _reFetch();
                        },
                      ),
                    )
                  : (_mode == SelectionMode.list)
                  ? Builder(
                      builder: (context) {
                        // 리스트 모드 진입 시 한 번 초기화
                        if (_days.isEmpty) {
                          _initListWindow();
                        }

                        return ScheduleListBody(
                          days: _days,
                          byDay: _byDay,
                          focusDay: _focusDayForList,
                          // ← 기존 스냅 동작 유지
                          hideEmptyDays: true,
                          // ← 빈 날 숨김 유지
                          preserveAnchorDay: _anchorToPreserve,
                          // 확장 후 튐 방지
                          onNearEdge: (edge, anchor) {
                            if (edge == NearEdge.top) {
                              _extendPast(anchor);
                            } else {
                              _extendFuture(anchor);
                            }
                          },
                          onTapOccurrence: (occ) async {
                            // 헤더 타이틀용 pivot: 이벤트 시작일(로컬)을 넘기면 충분
                            final pivotForHeader = DateTime(
                              occ.startLocal.year,
                              occ.startLocal.month,
                              occ.startLocal.day,
                            );

                            final changed = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailPage(
                                      event: occ.src, // CalendarSingle
                                      pivotJst: pivotForHeader, // 헤더에 쓸 기준일
                                    ),
                                  ),
                                );

                            // 삭제/수정 등 변경되었으면 재조회 + 현재 날짜를 앵커로 고정
                            if (changed == true && mounted) {
                              _anchorToPreserve = DateTime(
                                occ.startLocal.year,
                                occ.startLocal.month,
                                occ.startLocal.day,
                              );
                              await _reFetch(); // 월 배지까지 건드릴 필요 없으면 recomputeMonth: false
                              setState(() {}); // 리스트 데이터 반영
                              // 필요 시 _anchorToPreserve는 이후 build 한 번 돌고 null로 자동 초기화 로직 유지
                            }
                          },
                          onTopDayChanged: (day) {
                            final base = dateOnly(day);
                            // 스크롤로 달이 바뀌면 헤더 기준일/표시월을 같이 바꿔둔다
                            if (base != dateOnly(_pivotDate) ||
                                _displayMonth.year != base.year ||
                                _displayMonth.month != base.month) {
                              setState(() {
                                _pivotDate = base;
                                _displayMonth = DateTime(base.year, base.month, 1);
                              });
                            }
                          },
                        );
                      },
                    )
                  : Column(
                      children: [
                        // ✅ 요일 줄 + 날짜(주간 스트립) — 파란 동그라미 강조 포함
                        WeekStrip(
                          pivotDate: _pivotDate,
                          selectedDays: _effectiveDays,
                          // onTapDate: (d) async {
                          //   _computeSelectionByMode(d); // 선택/피벗 갱신
                          //   setState(() {});
                          //   await _reFetch(); // ★ 전개는 build에서 occurrencesByDay가 처리
                          // },
                          onTapDate: (d) async {
                            if (_mode == SelectionMode.list) {
                              // 리스트 모드면 리스트로
                              _enterListAt(d);
                            } else {
                              // 단일/복수 모드면 날짜만 바꿔서 주간 뷰 유지
                              _computeSelectionByMode(d);
                              setState(() {});
                            }
                            await _reFetch();
                          },
                          onSwipePrevWeek: () => _shiftWeek(-1),
                          onSwipeNextWeek: () => _shiftWeek(1),
                        ),

                        // 선택한 날짜 라벨 (예: 8月8日（水）  8月9日（木）)
                        SelectedDaysHeader(days: _effectiveDays),

                        // 시간표(혹은 나중에 DayList로 전환)
                        Expanded(
                          child: WeekTimeline(
                            days: _effectiveDays,
                            controller: _timeScroll,
                            dayOccurrences: dayOccMap, // ★ 전달!
                            onRefreshRequested: () async {
                              await _reFetch(); // 이미 있는 재조회 함수면 그대로 사용
                              // 없다면:
                              // final res = await fetchCalendarSingleList(true);
                              // setState(() { _events = res.data; /* 월간이면 배지도 다시 계산 */ });
                            },
                          ),
                        ),
                      ],
                    ),
            ),

            // 자신, 다른 사람, 회의실(설비별) -> 선택해서 예약 내역 볼 수 있게

          ],
        ),
      ),
    );
  }
}
