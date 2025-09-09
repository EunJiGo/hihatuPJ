part of schedule_screen;

extension _ScheduleListModePart on _ScheduleScreenState {

  void _initListWindow() {
    final focus = dateOnly(_focusDayForList);
    _listMin = _dOnly(focus.subtract(_ScheduleScreenState._chunk));
    if (_listMin.isBefore(_globalMin)) _listMin = _globalMin;

    _listMax = _dOnly(focus.add(_ScheduleScreenState._chunk));
    if (_listMax.isAfter(_globalMax)) _listMax = _globalMax;

    _days = buildDaySpan(windowStart: _listMin, windowEnd: _listMax);
    _byDay = occurrencesByDay(events: _events, days: _days);
    _anchorToPreserve = null;
  }

  Future<void> _extendPast(DateTime anchorDay) async {
    if (_extending) return;
    _extending = true;
    _anchorToPreserve = anchorDay;
    try {
      final newMin = _listMin.subtract(_ScheduleScreenState._chunk);
      final extDays = buildDaySpan(windowStart: newMin, windowEnd: _listMin);
      final extMap = occurrencesByDay(events: _events, days: extDays);
      _days = [...extDays, ..._days];
      _byDay = {...extMap, ..._byDay};
      _listMin = newMin;
      setState(() {});
    } finally {
      _extending = false;
      _anchorToPreserve = null;
    }
  }

  Future<void> _extendFuture(DateTime anchorDay) async {
    if (_extending) return;
    _extending = true;
    _anchorToPreserve = anchorDay;
    try {
      final newMax = _listMax.add(_ScheduleScreenState._chunk);
      final extDays = buildDaySpan(windowStart: _listMax, windowEnd: newMax);
      final extMap = occurrencesByDay(events: _events, days: extDays);
      _days = [..._days, ...extDays];
      _byDay = {..._byDay, ...extMap};
      _listMax = newMax;
      setState(() {});
    } finally {
      _extending = false;
      _anchorToPreserve = null;
    }
  }
}
