part of schedule_screen;

// ===== 확장 (State 클래스 전용) =====
extension _FetchAndCompute on _ScheduleScreenState {
  Future<void> _loadCalendar() async {
    try {
      final res = await _futureCalendar;
      _events = res.data;
      // _recomputeMonthBadges();
      debugPrint('[equip] selectedIds=$_selectedEquipIds');
      // 처음에도 전 스코프 병합 + _myEvents 캐시 갱신
      await _fetchEventsAccordingToScopes();

      _recomputeMonthCaches();
      _computeGlobalBounds();
    } catch (e, st) {
      debugPrint('fetch error: $e\n$st');
    }
    setState(() {});
  }

  Future<void> _reFetch({bool recomputeMonth = false}) async {
    if (_loading) return;
    _loading = true;
    setState(() {});

    try {
      // await _fetchEventsAccordingToScopes();
      //
      // final res = await fetchCalendarSingleList(null, true);
      // _events = res.data;

      // 이 함수가 _events(전체)와 _myEvents(내 일정)까지 갱신해줍니다.
      await _fetchEventsAccordingToScopes();


      if (recomputeMonth || _isMonthView) {
        _recomputeMonthCaches();
        _computeGlobalBounds();
      } else {
        // ✅ 리스트 모드면 캐시 재계산 (주간은 build에서 즉시 반영됨)
        if (_mode == SelectionMode.list) {
          if (_days.isEmpty) {
            _initListWindow(); // 최초 진입 케이스 커버
          } else {
            _byDay = occurrencesByDay(events: _events, days: _days);
            // 필요하면 스크롤 위치 보존
            _anchorToPreserve ??= _focusDayForList;
          }
        }
        setState(() {});
      }
    } catch (e, st) {
      debugPrint('fetch error: $e\n$st');
    } finally {
      _loading = false;
      setState(() {});
    }
  }

  void _recomputeMonthCaches() {
    // 🔵 파란 점: “내 일정”만
    _eventCountByDay = _includeMe
        ? computeBadgeCounts(displayMonth: _displayMonth, events: _myEvents)
        : <DateTime, int>{}; // 自分 off면 파란 점 숨김

    // 🟢 초록 점(선택 사원들)
    _peopleBadges = computePeopleBadges(
      displayMonth: _displayMonth,
      events: _events,                 // 전체(나+사람+설비)에서 필터
      selectedPersonIds: _selectedPersonIds,
    );

    // ⚪️ 회색 점: 선택한 회의실 합계 (전체 이벤트에서 필터)
    _equipmentBadges = computeEquipmentBadges(
      displayMonth: _displayMonth,
      events: _events,
      equipmentIds: _selectedEquipIds,
    );

    debugPrint(
      'blue total=${_eventCountByDay.length} blue sample=${_eventCountByDay.entries.take(5).toList()}',
    );
    debugPrint(
      'gray total=${_equipmentBadges.length}  graysample=${_equipmentBadges.entries.take(5).toList()}',
    );
    debugPrint(
      'greeng total=${_peopleBadges.length}  graysample=${_peopleBadges.entries.take(5).toList()}',
    );
  }

  void _recomputeMonthBadges() {
    _eventCountByDay = computeBadgeCounts(
      displayMonth: _displayMonth,
      events: _events,
    );
    debugLogMonthBadges(displayMonth: _displayMonth, events: _events);
    setState(() {});
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
      final s = _parseLocal(e.start);
      final t = _parseLocal(e.end);
      final sd = _dOnly(s);
      final td = _dOnly(t);
      if (sd.isBefore(minD)) minD = sd;
      if (td.isAfter(maxD)) maxD = td;
    }
    _globalMin = minD;
    _globalMax = maxD;
  }

  // schedule_fetch_part.dart (같은 라이브러리 어디든 추가)
  List<CalendarSingle> _dedupSingles(Iterable<CalendarSingle> items) {
    final seen = <String>{};
    final out = <CalendarSingle>[];
    for (final e in items) {
      // id + 시작/끝 같은 키로 중복 판단
      final key = '${e.id}-${e.start}-${e.end}';
      if (seen.add(key)) {
        out.add(e);
      }
    }
    return out;
  }

  Future<List<CalendarSingle>> _fetchEventsAccordingToScopes() async {
    final merged = <CalendarSingle>[];
    var my = <CalendarSingle>[]; // 🔵 내 일정만 따로 담아둔다

    // 1) 나(自分)
    if (_includeMe) {
      final r = await fetchCalendarSingleList(null, true);
      my = r.data;
      merged.addAll(my);
    }

    // 2) 사람들
    for (final pid in _selectedPersonIds) {
      final r = await fetchCalendarSingleList('$pid', true);
      merged.addAll(r.data);
    }

    // 3) 설비(회의실)
    for (final eqId in _selectedEquipIds) {
      final r = await fetchCalendarDevice(eqId.toString(), true);
      // 응답에 equipments가 이미 꽉 들어오므로 그대로 add
      merged.addAll(r.data);
    }

    // 4) dedupe
    final dedupedAll = _dedupSingles(merged);
    final dedupedMy = _includeMe ? _dedupSingles(my) : <CalendarSingle>[];

    // 5) ✅ 여기서 상태 캐시까지 갱신 (side-effect)
    _events = dedupedAll; // 전체(나/사람/설비)
    _myEvents = dedupedMy; // 내 일정만

    return dedupedAll;
  }
}
