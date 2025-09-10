// lib/calendar/ui/scope/equipment_picker_page.dart
import 'package:flutter/material.dart';
import '../../domain/equipment.dart';
import '../../styles.dart';

class EquipmentPickerPage extends StatefulWidget {
  const EquipmentPickerPage({
    super.key,
    required this.equipments,
    required this.initiallySelected,
    this.allowedDepartments = const {},   // 선택된 참가자(또는 작성자)의 부서 집합
    this.enforceEligibility = false,      // true면 부서 미자격 설비는 체크 불가(비활성)
  });

  /// 설비 마스터 전체
  final List<Equipment> equipments;

  /// 이미 선택되어 있는 equipment_id 집합
  final Set<int> initiallySelected;

  /// 예약 자격이 있는 부서 집합(예: 선택된 참가자들의 부서 union)
  final Set<String> allowedDepartments;

  /// 부서 자격 체크를 적용할지 여부
  final bool enforceEligibility;

  @override
  State<EquipmentPickerPage> createState() => _EquipmentPickerPageState();
}

class _EquipmentPickerPageState extends State<EquipmentPickerPage> {
  final _query = TextEditingController();
  late final Set<int> _checked; // 선택된 equipment_id 집합

  @override
  void initState() {
    super.initState();
    _checked = {...widget.initiallySelected};
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(Equipment e, String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase();
    return e.name.toLowerCase().contains(lower)
        || (e.kana ?? '').toLowerCase().contains(lower);
  }

  bool _eligible(Equipment e) {
    if (!widget.enforceEligibility) return true;
    // allowedDepartments 비어있으면 제한 없음으로 간주
    if (widget.allowedDepartments.isEmpty) return true;
    // 설비의 departments가 비었으면 전사공용으로 간주(또는 정책에 맞게 false로 변경 가능)
    if (e.departments.isEmpty) return true;
    // 교집합이 있으면 사용 가능
    return e.departments.any(widget.allowedDepartments.contains);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim();

    final list = widget.equipments
        .where((e) => _matches(e, q))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('設備追加', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
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
                    hintText: '検索（設備名 / カナ / ルール）',
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
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final e = list[i];
                final canUse = _eligible(e);
                final checked = _checked.contains(e.id);

                final deptText = e.departments.isEmpty
                    ? '（部署制限なし）'
                    : e.departments.join('・');

                return CheckboxListTile(
                  value: checked,
                  onChanged: canUse
                      ? (v) => setState(() {
                    if (v == true) {
                      _checked.add(e.id);
                    } else {
                      _checked.remove(e.id);
                    }
                  })
                      : null, // 비자격이면 비활성
                  title: Text(
                    e.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: canUse ? null : Colors.black38,
                    ),
                  ),
                  subtitle: Text(
                    deptText,
                    style: TextStyle(
                      fontSize: 12,
                      color: canUse ? Colors.black54 : Colors.black26,
                    ),
                  ),
                  activeColor: iosBlue,  // 체크박스가 선택됐을 때 색
                  checkColor: Colors.white,  // 체크 표시(✔) 색
                  dense: true,
                  secondary: canUse
                      ? null
                      : const Icon(Icons.block, size: 16, color: Colors.black26),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
