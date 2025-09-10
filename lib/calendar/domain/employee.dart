class Employee {
  final int id;
  final String name;
  final String kana;
  final String position;
  final List<String> departments;
  final List<String> searchTokens; // customizeRules 분해

  const Employee({
    required this.id,
    required this.name,
    required this.kana,
    required this.position,
    required this.departments,
    required this.searchTokens,
  });

  factory Employee.fromJson(Map<String, dynamic> j) {
    final rules = (j['customizeRules'] as String?)?.trim() ?? '';
    final tokens = rules.isEmpty
        ? const <String>[]
        : rules.split('/').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Employee(
      id: (j['employee_id'] as num).toInt(),
      name: (j['name'] as String?)?.trim() ?? '',
      kana: (j['kana'] as String?)?.trim() ?? '',
      position: (j['position'] as String?)?.trim() ?? '',
      departments: (j['departments'] as List?)?.map((e) => (e as String).trim()).toList().cast<String>() ?? const <String>[],
      searchTokens: tokens,
    );
  }
}
