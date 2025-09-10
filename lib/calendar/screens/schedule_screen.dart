library schedule_screen;

import 'package:flutter/material.dart' hide ListBody;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hihatu_project/calendar/ui/event_detail/event_detail_page.dart';
import 'package:hihatu_project/calendar/ui/schedule_list_view.dart';

import '../data/fetch_calendar_single_list.dart';
import '../data/fetch_employee.dart';
import '../data/fetch_equipment.dart';
import '../data/fetch_calendar_device.dart';
import '../domain/calendar_single.dart';
import '../domain/calendar_single_response.dart';
import '../domain/employee.dart';
import '../domain/equipment.dart';
import '../logic/occurrence_expander.dart';
import '../logic/recurrence.dart';
import '../styles.dart';
import '../logic/time_utils.dart';
import '../logic/badge_counter.dart';
import '../logic/debug_logger.dart';
import '../types.dart';
import '../ui/month_body.dart';
import '../ui/scope/calendar_scope.dart';
import '../ui/scope/calendar_scope_bar.dart';
import '../ui/scope/equipment_picker_page.dart';
import '../ui/scope/people_picker_page.dart';
import '../ui/shared/header.dart';
import '../ui/week_body.dart';
import '../ui/list_body.dart';

// ====== 파트 구성 ======
part 'schedule/schedule_prefs_part.dart';

part 'schedule/schedule_fetch_part.dart';

part 'schedule/schedule_list_mode_part.dart';

part 'schedule/schedule_selection_part.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // ====== API & 로딩 상태 ======
  late Future<CalendarSingleResponse> _futureCalendar;
  bool _loading = false;

  // ====== 보기 상태 ======
  bool _isMonthView = true;
  static const _kModeKey = 'selection_mode_v1';
  SelectionMode _mode = SelectionMode.single;

  // ====== 시간/선택 상태 ======
  DateTime _pivotDate = DateTime.now(); // 주/일 전환 기준일
  List<DateTime> _selectedDays = []; // 유저가 직접 고른 날짜

  // 월간 뷰에서 현재 표시 중인 달(항상 1일 정규화)
  DateTime _displayMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  // 주간 타임라인 스크롤
  final _timeScroll = ScrollController();

  // ====== 데이터 ======
  List<CalendarSingle> _events = []; // 서버 원본 일정
  List<CalendarSingle> _myEvents = []; // “내 일정”만 따로 보관
  Map<DateTime, int> _eventCountByDay = {}; // 월간 점(개수)

  Map<DateTime, MonthBadge> _monthBadges = {}; // ⬅ 추가

  // ====== 리스트 모드(무한 스크롤) 윈도우 ======
  late DateTime _listMin;
  late DateTime _listMax;
  late DateTime _globalMin; // 전체 이벤트 최소 (로컬 자정)
  late DateTime _globalMax; // 전체 이벤트 최대 (로컬 자정)
  List<DateTime> _days = [];
  Map<DateTime, List<Occurrence>> _byDay = {};
  DateTime? _anchorToPreserve;
  bool _extending = false;
  static const _chunk = Duration(days: 180);

  // ====== 스코프 데이터 / 선택 상태 ======
  List<Employee> _employees = [];
  List<Equipment> _equipments = [];

  // 상태필드
  Map<DateTime, int> _equipmentBadges = <DateTime, int>{};
  Map<DateTime, int> _peopleBadges = <DateTime, int>{};

  bool _includeMe = true; // “自分” on/off
  final Set<int> _selectedPersonIds = {}; // employee_id
  final Set<int> _selectedEquipIds = {}; // equipment_id

  // ====== 계산 프로퍼티 ======
  List<DateTime> get _effectiveDays =>
      _computeEffectiveDays(_selectedDays, _mode, _pivotDate);

  DateTime get _focusDayForList =>
      _computeFocusDayForList(_selectedDays, _pivotDate);

  // ====== 하단 스코프 바 상태(칩 데이터) ======
  List<CalendarScopeItem> _scopes = const [
    CalendarScopeItem(type: ScopeType.me, id: 'me', label: '自分', enabled: true),
  ];

  // ====== 생명주기 ======
  @override
  void initState() {
    super.initState();
    // 오전 9시로 타임라인 점프
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_timeScroll.hasClients) {
        final offset = (9 - minHour) * hourHeight;
        if (offset > 0) _timeScroll.jumpTo(offset);
      }
    });
    _futureCalendar = fetchCalendarSingleList(null, true);
    _loadCalendar(); // 최초 로딩
    _loadSavedMode(); // 마지막 모드 복원
    _loadScopes(); // 스코프용 마스터 로딩
  }

  @override
  void dispose() {
    _timeScroll.dispose();
    super.dispose();
  }

  // ====== 스코프 마스터 로딩 ======
  Future<void> _loadScopes() async {
    try {
      final emps = await fetchEmployee();
      final eqs = await fetchEquipment();
      setState(() {
        _employees = emps.data;
        _equipments = eqs.data;
      });
    } catch (e) {
      debugPrint('scope load error: $e');
    }
  }

  // ====== 스코프 바 액션들 ======
  void _toggleMe() async {
    setState(() {
      final i = _scopes.indexWhere((e) => e.type == ScopeType.me);
      if (i >= 0) {
        _scopes = List.of(_scopes);
        _scopes[i] = _scopes[i].copyWith(enabled: !_scopes[i].enabled);
      }
      _includeMe = _scopes.any((e) => e.type == ScopeType.me && e.enabled);
    });
    await _reFetch(recomputeMonth: true); //  반드시
  }

  void _removeScope(CalendarScopeItem item) async {
    setState(() {
      _scopes = List.of(_scopes)
        ..removeWhere((e) => e.type == item.type && e.id == item.id);
      if (item.type == ScopeType.person) {
        final id = int.tryParse(item.id.toString());
        if (id != null) _selectedPersonIds.remove(id);
      } else if (item.type == ScopeType.equipment) {
        final id = int.tryParse(item.id.toString());
        if (id != null) _selectedEquipIds.remove(id);
      }
    });
    await _reFetch(recomputeMonth: true); //  반드시
  }

  Future<void> _openScopePicker() async {
    final action = await showModalBottomSheet<_ScopeAction>(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => const _ScopeActionSheet(),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _ScopeAction.toggleMe:
        _toggleMe();
        break;

      case _ScopeAction.addPeople:
        {
          // 사람 선택: 실데이터 + 초기선택 넘겨서 Set<int> 받아오기
          final pickedIds = await Navigator.push<Set<int>>(
            context,
            MaterialPageRoute(
              builder: (_) => PeoplePickerPage(
                employees: _employees, // fetchEmployee() 결과
                initiallySelected: _selectedPersonIds, // 현재 선택 상태
              ),
            ),
          );
          if (pickedIds == null) return;

          setState(() {
            // 내부 선택 상태 동기화
            _selectedPersonIds
              ..clear()
              ..addAll(pickedIds);

            // 하단 Scope 칩(사람) 재구성: id는 문자열로!
            final personScopes = pickedIds.map((id) {
              final emp = _employees.firstWhere(
                (e) => e.id == id,
                orElse: () => Employee(
                  id: id,
                  name: '社員$id',
                  kana: '',
                  departments: const [],
                  position: '',
                  searchTokens: [],
                ),
              );
              return CalendarScopeItem(
                type: ScopeType.person,
                id: '$id', // ← 문자열 변환 중요!!
                label: emp.name,
                enabled: true,
              );
            }).toList();

            // 기존 사람 칩 제거 후 다시 추가
            _scopes = [
              ..._scopes.where((e) => e.type != ScopeType.person),
              ...personScopes,
            ];
          });
          await _reFetch(recomputeMonth: true);
          break;
        }

      case _ScopeAction.addEquipments:
        {
          // 설비 선택: 실데이터 + 초기선택 + (선택) 부서자격 union 넘겨서 Set<int> 받아오기
          final pickedEqIds = await Navigator.push<Set<int>>(
            context,
            MaterialPageRoute(
              builder: (_) => EquipmentPickerPage(
                equipments: _equipments,
                // fetchEquipment() 결과
                initiallySelected: _selectedEquipIds,
                // 현재 선택 상태
                allowedDepartments: _allowedDeptUnion(),
                // 선택된 사람들의 부서 합집합(정책에 따라)
                enforceEligibility: true, // 부서자격 강제
              ),
            ),
          );
          if (pickedEqIds == null) return;

          debugPrint('[equip] picked from picker = $pickedEqIds');

          setState(() {
            // 내부 선택 상태 동기화
            _selectedEquipIds
              ..clear()
              ..addAll(pickedEqIds);

            // 하단 Scope 칩(설비) 재구성: id는 문자열로!
            final eqScopes = pickedEqIds.map((id) {
              final eq = _equipments.firstWhere(
                (e) => e.id == id,
                orElse: () => Equipment(
                  id: id,
                  name: '設備$id',
                  kana: '',
                  departments: const [],
                ),
              );
              return CalendarScopeItem(
                type: ScopeType.equipment,
                id: '$id', // ← 문자열 변환 중요!!
                label: eq.name,
                enabled: true,
              );
            }).toList();

            // 기존 설비 칩 제거 후 다시 추가
            _scopes = [
              ..._scopes.where((e) => e.type != ScopeType.equipment),
              ...eqScopes,
            ];
          });
          debugPrint('[equip] after setState = $_selectedEquipIds');

          // ✅ 선택 후 바로 재조회 & 회색 배지 갱신
          await _reFetch(recomputeMonth: true);
          break;
        }
    }
  }

  Set<String> _allowedDeptUnion() {
    final s = <String>{};
    for (final emp in _employees) {
      if (_selectedPersonIds.contains(emp.id)) {
        s.addAll(emp.departments);
      }
    }
    return s;
  }

  // ====== 빌드 ======
  @override
  Widget build(BuildContext context) {
    final dayOccMap = occurrencesByDay(events: _events, days: _effectiveDays);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ----- 헤더 -----
            ScheduleHeader(
              variant: _isMonthView ? HeaderVariant.month : HeaderVariant.week,
              isMonthView: _isMonthView,
              displayMonth: _displayMonth,
              pivotDate: _pivotDate,
              mode: _mode,
              hideWeekdayLabels: _mode == SelectionMode.list,
              onTapPrev: () => _shiftMonth(-1),
              onChangeMode: (m) async => _onChangeMode(m),
              onTapSearch: () {},
              onTapAdd: () {},
              onSwitchToMonthFromWeek: () async => _switchToMonthFromWeek(),
              onTapThisMonth: () async => _jumpToThisMonth(),
              onSelectMonthFromYear: (y, m) async =>
                  _onSelectMonthFromYear(y, m),
            ),

            // ----- 본문(월/주/리스트) -----
            Expanded(
              child: _isMonthView
                  ? MonthBody(
                      displayMonth: _displayMonth,
                      eventCountByDay: _eventCountByDay,
                      equipmentBadges: _equipmentBadges,
                      peopleBadges: _peopleBadges,
                      onTapDate: (d) async {
                        if (_mode == SelectionMode.list) {
                          _enterListAt(d);
                          await _reFetch();
                          return;
                        }
                        _isMonthView = false;
                        _computeSelectionByMode(d);
                        setState(() {});
                        await _reFetch();
                      },
                      onShiftMonth: (delta) => _shiftMonth(delta),
                    )
                  : (_mode == SelectionMode.list)
                  ? ListBody(
                      days: _days.isEmpty
                          ? (() {
                              _initListWindow();
                              return _days;
                            }())
                          : _days,
                      byDay: _byDay,
                      focusDay: _focusDayForList,
                      hideEmptyDays: true,
                      preserveAnchorDay: _anchorToPreserve,
                      onNearEdge: (edge, anchor) {
                        if (edge == NearEdge.top) {
                          _extendPast(anchor);
                        } else {
                          _extendFuture(anchor);
                        }
                      },
                      onTapOccurrence: (occ) async {
                        final pivotForHeader = DateTime(
                          occ.startLocal.year,
                          occ.startLocal.month,
                          occ.startLocal.day,
                        );
                        final changed = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => EventDetailPage(
                              event: occ.src,
                              pivotJst: pivotForHeader,
                            ),
                          ),
                        );
                        if (changed == true && mounted) {
                          _anchorToPreserve = DateTime(
                            occ.startLocal.year,
                            occ.startLocal.month,
                            occ.startLocal.day,
                          );
                          await _reFetch();
                          setState(() {});
                        }
                      },
                      onTopDayChanged: (day) {
                        final base = dateOnly(day);
                        if (base != dateOnly(_pivotDate) ||
                            _displayMonth.year != base.year ||
                            _displayMonth.month != base.month) {
                          setState(() {
                            _pivotDate = base;
                            _displayMonth = DateTime(base.year, base.month, 1);
                          });
                        }
                      },
                    )
                  : WeekBody(
                      pivotDate: _pivotDate,
                      effectiveDays: _effectiveDays,
                      dayOccMap: dayOccMap,
                      onTapDate: (d) async {
                        if (_mode == SelectionMode.list) {
                          _enterListAt(d);
                        } else {
                          _computeSelectionByMode(d);
                          setState(() {});
                        }
                        await _reFetch();
                      },
                      onPrevWeek: () => _shiftWeek(-1),
                      onNextWeek: () => _shiftWeek(1),
                      onRefresh: () => _reFetch(),
                      timeScroll: _timeScroll,
                    ),
            ),

            // ----- 하단 스코프 바 -----
            CalendarScopeBar(
              items: _scopes,
              onToggleMe: _toggleMe,
              onTapPlus: _openScopePicker,
              onRemoveItem: _removeScope,
            ),
          ],
        ),
      ),
    );
  }

  // ====== 헤더 액션 핸들러 (동작 동일) ======
  Future<void> _onChangeMode(SelectionMode m) async {
    _mode = m;
    if (m == SelectionMode.list) {
      _enterListAt(_pivotDate);
      setState(() {});
      await _reFetch();
      return;
    }

    final base = dateOnly(_pivotDate);
    _selectedDays = (m == SelectionMode.single)
        ? [base]
        : [base, base.add(const Duration(days: 1))];

    _isMonthView = false;
    _displayMonth = DateTime(base.year, base.month, 1);

    setState(() {});
    await _reFetch();
  }

  Future<void> _switchToMonthFromWeek() async {
    _displayMonth = DateTime(_pivotDate.year, _pivotDate.month, 1);
    _isMonthView = true;
    _selectedDays = [];
    setState(() {});
    await _reFetch(recomputeMonth: true);
  }

  Future<void> _jumpToThisMonth() async {
    final now = DateTime.now();
    _isMonthView = true;
    _displayMonth = DateTime(now.year, now.month, 1);
    _pivotDate = now;
    _selectedDays = [];
    setState(() {});
    await _reFetch(recomputeMonth: true);
  }

  Future<void> _onSelectMonthFromYear(int year, int month) async {
    _isMonthView = true;
    _displayMonth = DateTime(year, month, 1);
    _pivotDate = DateTime(year, month, 1);
    _selectedDays = [];
    setState(() {});
    await _reFetch(recomputeMonth: true);
  }
}

// ====== 임시 액션 시트 ======
enum _ScopeAction { toggleMe, addPeople, addEquipments }

class _ScopeActionSheet extends StatelessWidget {
  const _ScopeActionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.group_add, size: 20,),
            title: const Text('他の社員追加', style: TextStyle(fontSize: 17),),
            onTap: () => Navigator.pop(context, _ScopeAction.addPeople),
            minLeadingWidth: 0,
            visualDensity: const VisualDensity(   // 👈 높이/밀도 조절
              horizontal: -2,                     // 기본 간격에서 줄이기
              vertical: 0,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.meeting_room, size: 20),
            title: const Text('設備追加', style: TextStyle(fontSize: 17),),
            onTap: () => Navigator.pop(context, _ScopeAction.addEquipments),
            minLeadingWidth: 0,
            visualDensity: const VisualDensity(   // 👈 높이/밀도 조절
              horizontal: -2,                     // 기본 간격에서 줄이기
              vertical: 0,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
