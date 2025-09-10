part of '../schedule_screen.dart';

extension _SelectionAndNav on _ScheduleScreenState {
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
  }

  void _enterListAt(DateTime focusDay) {
    final base = dateOnly(focusDay);
    _mode = SelectionMode.list;
    _isMonthView = false;
    _selectedDays = [base];
    _pivotDate = base;

    _days.clear();
    _byDay.clear();
    _anchorToPreserve = null;

    setState(() {});
    _saveMode(_mode);
  }

  // void _shiftMonth(int delta) async {
  //   _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + delta, 1);
  //   setState(() {});                   // UI 먼저
  //   await _reFetch(recomputeMonth: true);
  // }

  Future<void> _shiftMonth(int delta) async {
    final base = DateTime(_displayMonth.year, _displayMonth.month + delta, 1);
    _displayMonth = base;
    _pivotDate = base;
    _selectedDays = [];
    setState(() {});
    await _saveFilterPrefs();              // ← 추가
    await _reFetch(recomputeMonth: true);
  }

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
    await _reFetch();
  }
}
