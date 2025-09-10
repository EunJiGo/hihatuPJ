// lib/calendar/ui/scope/people_picker_page.dart
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/domain/employee.dart';
import 'package:hihatu_project/calendar/styles.dart';

class PeoplePickerPage extends StatefulWidget {
  const PeoplePickerPage({
    super.key,
    required this.employees,
    required this.initiallySelected,
  });

  /// 전체 사원 마스터
  final List<Employee> employees;

  /// 이미 선택되어 있는 employee_id 집합
  final Set<int> initiallySelected;

  @override
  State<PeoplePickerPage> createState() => _PeoplePickerPageState();
}

class _PeoplePickerPageState extends State<PeoplePickerPage> {
  final _query = TextEditingController();

  /// 부서명 -> 펼침 여부
  final Map<String, bool> _expanded = {};

  /// 선택된 employee_id 집합
  late final Set<int> _checked;

  /// 부서명 목록 (정렬)
  late final List<String> _departments;

  /// 부서별 인원 맵 (부서 내 중복 제거)
  late final Map<String, List<Employee>> _byDept;

  static const String _kNoDept = '（部署なし）';

  @override
  void initState() {
    super.initState();
    _checked = {...widget.initiallySelected};
    _buildGroups();
  }

  void _buildGroups() {
    // 부서 목록 수집
    final deptSet = <String>{};
    for (final e in widget.employees) {
      if (e.departments.isEmpty) {
        deptSet.add(_kNoDept);
      } else {
        deptSet.addAll(e.departments);
      }
    }
    final depts = deptSet.toList()..sort();
    _departments = depts;

    // 부서별 인원 맵
    final map = <String, List<Employee>>{};
    for (final d in _departments) {
      map[d] = [];
    }
    for (final e in widget.employees) {
      final ds = e.departments.isEmpty ? <String>[_kNoDept] : e.departments;
      for (final d in ds) {
        final list = map[d]!;
        // 같은 부서에 같은 사람이 중복 추가되지 않도록 guard
        if (!list.any((x) => x.id == e.id)) list.add(e);
      }
    }
    // 이름 기준 정렬
    for (final d in _departments) {
      map[d]!.sort((a, b) => (a.name).compareTo(b.name));
    }
    _byDept = map;

    // 펼침 상태 초기화
    for (final d in _departments) {
      _expanded[d] = false;
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(Employee e, String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase();
    if (e.name.toLowerCase().contains(lower)) return true;
    if (e.kana.toLowerCase().contains(lower)) return true;
    for (final t in (e.searchTokens ?? const [])) {
      if (t.toLowerCase().contains(lower)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim();
    final searching = q.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18), // 👈 크기 줄임
          // padding: const EdgeInsets.only(left: 8), // 좌측 여백 조정
          constraints: const BoxConstraints(),     // 기본 48x48 제한 제거
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '社員追加',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop<Set<int>>(context, _checked);
            },
            child: const Text(
              '追加',
              style: TextStyle(
                color: iosBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 1,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색바
          Container(
            color: iosBg,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Material(
              elevation: 2, // 그림자 강도
              borderRadius: BorderRadius.circular(24),
              child: TextField(
                controller: _query,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  hintText: '検索（名前 / カナ / ルール）',
                  hintStyle: const TextStyle(fontSize: 13 , color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8), // 👈 왼쪽 여백 추가
                    child: const Icon(Icons.search, size: 18),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),

                  // 기본 48x48보다 작게 줄임
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),

          // 목록
          Expanded(
            child: ListView.builder(
              itemCount: _departments.length,
              itemBuilder: (context, index) {
                final dept = _departments[index];
                final all = _byDept[dept] ?? const <Employee>[];
                final list = all.where((e) => _matches(e, q)).toList();

                // 검색 중이면 결과 없는 그룹은 숨김
                if (searching && list.isEmpty) {
                  return const SizedBox.shrink();
                }

                final open = searching ? true : (_expanded[dept] ?? false);

                return Column(
                  children: [
                    _groupTile(
                      deptName: dept,
                      open: open,
                      onToggle: searching
                          ? null
                          : () => setState(() => _expanded[dept] = !open),
                    ),
                    if (open) ...list.map(_personTile),
                    const Divider(height: 0),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupTile({
    required String deptName,
    required bool open,
    VoidCallback? onToggle,
  }) {
    return ListTile(
      dense: true,
      title: Text(
        deptName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      trailing: onToggle == null
          ? null
          : Icon(open ? Icons.expand_less : Icons.expand_more),
      onTap: onToggle,
    );
  }

  Widget _personTile(Employee e) {
    final checked = _checked.contains(e.id);
    return CheckboxListTile(
      value: checked,
      dense: true,
      title: Text(e.name),
      subtitle: e.kana.isNotEmpty
          ? Text(e.kana, style: const TextStyle(fontSize: 12))
          : null,
      activeColor: iosBlue,  // 체크박스가 선택됐을 때 색
      checkColor: Colors.white,  // 체크 표시(✔) 색
      onChanged: (v) => setState(() {
        if (v == true) {
          _checked.add(e.id);
        } else {
          _checked.remove(e.id);
        }
      }),
    );
  }
}
