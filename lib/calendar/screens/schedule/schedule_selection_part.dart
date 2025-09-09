part of schedule_screen;

extension _ScheduleSelectionPart on _ScheduleScreenState {

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

  void _enterListAt(DateTime focusDay) {
    final base = dateOnly(focusDay);
    _mode = SelectionMode.list;
    _isMonthView = false;
    _pivotDate = base;
    _selectedDays = [base];
    _displayMonth = DateTime(base.year, base.month, 1);
    _initListWindow();
    setState(() {});
  }

  void _shiftWeek(int deltaWeeks) {
    final next = _pivotDate.add(Duration(days: 7 * deltaWeeks));
    _pivotDate = dateOnly(next);
    _displayMonth = DateTime(_pivotDate.year, _pivotDate.month, 1);
    if (_mode != SelectionMode.list) {
      _selectedDays = (_mode == SelectionMode.single)
          ? [dateOnly(_pivotDate)]
          : [dateOnly(_pivotDate), dateOnly(_pivotDate).add(const Duration(days: 1))];
    }
    setState(() {});
  }
}
