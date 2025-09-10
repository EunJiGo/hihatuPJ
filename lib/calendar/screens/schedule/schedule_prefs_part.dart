part of '../schedule_screen.dart';

extension _PrefsAndHelpers on _ScheduleScreenState {

  // 필터/월 보존용 키
  static const _kIncludeMeKey     = 'filter_include_me_v1';
  static const _kPersonIdsKey     = 'filter_person_ids_v1';
  static const _kEquipIdsKey      = 'filter_equipment_ids_v1';
  static const _kDisplayMonthKey  = 'display_month_v1'; // ISO8601(1일 정규화)

  /// 필터 & 월 저장
  Future<void> _saveFilterPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIncludeMeKey, _includeMe);
    await prefs.setStringList(
      _kPersonIdsKey,
      _selectedPersonIds.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      _kEquipIdsKey,
      _selectedEquipIds.map((e) => e.toString()).toList(),
    );
    // 월도 기억(사용자가 원하면 유지되도록). 1일로 정규화해서 저장
    final dm = DateTime(_displayMonth.year, _displayMonth.month, 1);
    await prefs.setString(_kDisplayMonthKey, dm.toIso8601String());
  }

  /// 필터 & 월 복원(+ 칩 재구성 & 데이터 재펫치)
  Future<void> _loadFilterPrefsAndApply() async {
    final prefs = await SharedPreferences.getInstance();

    final incMe = prefs.getBool(_kIncludeMeKey);
    final people = prefs.getStringList(_kPersonIdsKey);
    final equips = prefs.getStringList(_kEquipIdsKey);
    final disp   = prefs.getString(_kDisplayMonthKey);

    setState(() {
      if (incMe != null) _includeMe = incMe;

      _selectedPersonIds
        ..clear()
        ..addAll((people ?? const []).map((e) => int.tryParse(e)).whereType<int>());

      _selectedEquipIds
        ..clear()
        ..addAll((equips ?? const []).map((e) => int.tryParse(e)).whereType<int>());

      if (disp != null) {
        final d = DateTime.tryParse(disp);
        if (d != null) {
          _displayMonth = DateTime(d.year, d.month, 1);
          _pivotDate    = DateTime(d.year, d.month, 1);
        }
      }

      // 마스터(_employees/_equipments)가 있어야 라벨이 예쁘게 붙음.
      // 그래도 없으면 임시 라벨(社員{id}, 設備{id})로 칩 구성.
      _rebuildScopeChipsFromSelections();
    });

    await _reFetch(recomputeMonth: true); // 파란/녹색/회색 점 재계산
  }

  /// 현재 선택 상태로 칩(_scopes) 리스트를 다시 만들어줌
  void _rebuildScopeChipsFromSelections() {
    final meChip = CalendarScopeItem(
      type: ScopeType.me, id: 'me', label: '自分', enabled: _includeMe,
    );

    final personChips = _selectedPersonIds.map((id) {
      final emp = _employees.firstWhere(
            (e) => e.id == id,
        orElse: () => Employee(
          id: id, name: '社員$id', kana: '', departments: const [],
          position: '', searchTokens: const [],
        ),
      );
      return CalendarScopeItem(
        type: ScopeType.person, id: '$id', label: emp.name, enabled: true,
      );
    });

    final equipChips = _selectedEquipIds.map((id) {
      final eq = _equipments.firstWhere(
            (e) => e.id == id,
        orElse: () => Equipment(id: id, name: '設備$id', kana: '', departments: const []),
      );
      return CalendarScopeItem(
        type: ScopeType.equipment, id: '$id', label: eq.name, enabled: true,
      );
    });

    _scopes = [meChip, ...personChips, ...equipChips];
  }

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
