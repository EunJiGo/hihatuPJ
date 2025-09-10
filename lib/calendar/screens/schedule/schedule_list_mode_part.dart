part of '../schedule_screen.dart';

extension _ListModeWindow on _ScheduleScreenState {
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
    if (!_listMin.isAfter(_globalMin)) return;
    _extending = true;

    final targetMin = _listMin.subtract(_ScheduleScreenState._chunk);
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
    if (!_listMax.isBefore(_globalMax)) return;
    _extending = true;

    final targetMax = _listMax.add(_ScheduleScreenState._chunk);
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

      _anchorToPreserve = null;
      setState(() {});
    }
    _extending = false;
  }
}
