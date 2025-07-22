class TransportationSave {
  final DateTime date;
  final String fromStation;
  final String toStation;
  final bool twice;
  final String railwayName;
  final int amount;
  final String goals;
  final String image;

  final String submissionStatus;
  final String reviewStatus;

  TransportationSave({
    required this.date,
    required this.fromStation,
    required this.toStation,
    required this.twice,
    required this.railwayName,
    required this.amount,
    required this.goals,
    required this.image,
    required this.submissionStatus,
    required this.reviewStatus,
  });

  Map<String, dynamic> toJson() {
    final todayStr = _formatDate(date);
    final nowStr = DateTime.now().toIso8601String();

    return {
      "employee_id": "admins",
      "month": date.month,
      "year": date.year,
      "expense_type": "single", // "交通費" → API에서는 "single" 로 기대할 수 있음
      "pay_day": todayStr,
      "goals": goals,
      "destination": railwayName, // 임의 값 지정
      "railway_name": railwayName,
      "from_station": fromStation,
      "to_station": toStation,
      "from": "", // 누락된 항목 추가
      "to": "",   // 누락된 항목 추가
      "via": "",
      "twice": twice,
      "commute_duration": "",
      "project_name": "",
      "duration_start": null,
      "duration_end": null,
      "pay_to": "",
      "amount": amount,
      "image": image,
      "submission_status": submissionStatus,
      "review_status": reviewStatus,
      "update": false,
      "id": null,
    };
  }

  static String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
