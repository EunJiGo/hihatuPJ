class Equipment {
  final int id;
  final String name;
  final String kana;
  final List<String> departments;

  const Equipment({
    required this.id,
    required this.name,
    required this.kana,
    required this.departments,
  });

  factory Equipment.fromJson(Map<String, dynamic> j) {
    return Equipment(
      id: (j['equipment_id'] as num).toInt(),
      name: (j['name'] as String?)?.trim() ?? '',
      kana: (j['kana'] as String?)?.trim() ?? '',
      departments: (j['departments'] as List?)?.map((e) => (e as String).trim()).toList().cast<String>() ?? const <String>[],
    );
  }
}
