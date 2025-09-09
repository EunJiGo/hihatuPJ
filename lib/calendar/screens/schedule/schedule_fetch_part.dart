part of schedule_screen;

extension _ScheduleFetchPart on _ScheduleScreenState {
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

  Future<void> _loadCalendar() async {
    if (_loading) return;
    _loading = true;
    setState(() {});
    try {
      final res = await _futureCalendar;
      _events = res.list ?? [];
      if (_isMonthView) {
        _recomputeMonthBadges();
        _computeGlobalBounds();
      } else {
        setState(() {});
      }
    } catch (e, st) {
      debugPrint('fetch error: $e\n$st');
    } finally {
      _loading = false;
      setState(() {});
    }
  }

  Future<void> _reFetch({bool recomputeMonth = false}) async {
    if (_loading) return;
    _loading = true;
    setState(() {});
    try {
      final res = await fetchCalendarSingleList(true);
      _events = res.list ?? [];
      if (recomputeMonth || _isMonthView) {
        _recomputeMonthBadges();
        _computeGlobalBounds();
      } else {
        setState(() {});
      }
    } catch (e, st) {
      debugPrint('re-fetch error: $e\n$st');
    } finally {
      _loading = false;
      setState(() {});
    }
  }

  void _recomputeMonthBadges() {
    _eventCountByDay = computeBadgeCounts(
      displayMonth: _displayMonth,
      events: _events,
    );
    debugLogMonthBadges(displayMonth: _displayMonth, events: _events);
    setState(() {});
  }
}
