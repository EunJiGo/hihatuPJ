part of '../schedule_screen.dart';

extension _PrefsAndHelpers on _ScheduleScreenState {
  // ---- 모드 저장/복원 ----
  Future<void> _saveMode(SelectionMode m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ScheduleScreenState._kModeKey, modeToInt(m));
  }

  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_ScheduleScreenState._kModeKey);
    if (v != null) {
      setState(() => _mode = intToMode(v));
    }
  }

  // ---- 날짜 헬퍼 ----
  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _parseLocal(Object? v) {
    if (v is DateTime) return v.toLocal();
    if (v is String) {
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt.toLocal();
    }
    return DateTime.now();
  }

  // ---- 계산 프로퍼티 빌더 ----
  List<DateTime> _computeEffectiveDays(List<DateTime> selected, SelectionMode mode, DateTime pivot) {
    if (selected.isEmpty) {
      final base = dateOnly(pivot);
      return (mode == SelectionMode.single)
          ? [base]
          : [base, base.add(const Duration(days: 1))];
    }
    return selected;
  }

  DateTime _computeFocusDayForList(List<DateTime> selected, DateTime pivot) {
    final src = selected.isNotEmpty ? selected.first : pivot;
    return DateTime(src.year, src.month, src.day);
  }
}
