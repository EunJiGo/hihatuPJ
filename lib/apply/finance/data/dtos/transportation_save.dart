class TransportationSave {
  final DateTime date;
  final String expenseType;
  final String? fromStation;
  final String? toStation;
  final String? destination;
  final String? via;
  final bool twice;
  final String? railwayName;
  final int? amount;
  final String? goals;
  final String? image;
  final String? durationStart;
  final String? durationEnd;
  final String? commuteDuration;
  final int? id;
  final String? payTo;

  final String submissionStatus;
  final String? reviewStatus;

  TransportationSave({
    required this.date,
    required this.expenseType,
    this.fromStation,
    this.toStation,
    this.destination,
    this.via,
    required this.twice,
    this.railwayName,
    this.amount,
    this.goals,
    this.image,
    this.durationStart,
    this.durationEnd,
    this.commuteDuration,
    this.id,
    this.payTo,
    required this.submissionStatus,
    this.reviewStatus,
  });

  Map<String, dynamic> toJson() {
    final todayStr = _formatDate(date);
    final nowStr = DateTime.now().toIso8601String();

    return {
      "employee_id": "admins",
      "month": date.month,
      "year": date.year,
      "expense_type": expenseType, // "交通費" → API에서는 "single" 로 기대할 수 있음
      "pay_day": todayStr,
      "goals": goals ?? "",
      "destination": destination, // 行先
      "railway_name": railwayName ?? "",
      "from_station": fromStation ?? "",
      "to_station": toStation,
      "from": "", // 누락된 항목 추가
      "to": "",   // 누락된 항목 추가
      "via": via ?? "",
      "twice": twice,
      "commute_duration": commuteDuration ?? "",
      "project_name": "",
      "duration_start": durationStart,
      "duration_end": durationEnd,
      "pay_to": payTo ?? "",
      "amount": amount,
      "image": image ?? "",
      "submission_status": submissionStatus,
      "review_status": reviewStatus ?? "",
      "update": false,
      "id": id,
    };
  }

  static String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
