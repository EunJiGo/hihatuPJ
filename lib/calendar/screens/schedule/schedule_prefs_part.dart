part of schedule_screen;


extension _SchedulePrefs on _ScheduleScreenState {
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

  DateTime _parseLocal(Object? v) {
    if (v is DateTime) return v.toLocal();
    if (v is String) {
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt.toLocal();
    }
    return DateTime.now();
  }
}
