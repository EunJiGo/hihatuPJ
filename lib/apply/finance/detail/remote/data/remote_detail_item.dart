class RemoteDetailItem {
  final DateTime createdAt; // 日付
  final Map<String, dynamic> remoteAllowanceRule;  // 在宅勤務日数・手当

  const RemoteDetailItem({
    required this.createdAt,
    required this.remoteAllowanceRule,
  });

  /// 在宅勤務日数・手当 (계산된 프로퍼티)
  // 라벨 getter
  String get ruleLabel => remoteAllowanceRule['label'] as String;
  // 금액 getter
  int get ruleAmount => remoteAllowanceRule['amount'] as int;
}