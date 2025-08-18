class TransportationUpdate {
  final int id;
  final String employeeId;
  final String expenseType; // "commute"
  final int? amount;
  final String? commuteDuration; // "1m", "3m", etc.
  final String? durationStart;
  final String? durationEnd;

  final DateTime date;
  final String? fromStation;
  final String? toStation;
  final String? railwayName;
  final String? image;
  final String? projectName;
  final String? via;
  final bool twice;
  final String? reviewStatus;
  final String? submissionStatus;
  final bool update;

  // 옵션 or 사용 안 하는 필드
  final String? destination;
  final String? goals;
  final String? reason;
  final String? payTo;
  final String? period;
  final bool imageCompressed;
  final String? from;
  final String? to;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? payDay;

  TransportationUpdate({
    required this.date,
    required this.id,
    required this.employeeId,
    required this.expenseType,
    this.amount,
    this.commuteDuration,
    this.durationStart,
    this.durationEnd,
    this.payDay,
    this.fromStation,
    this.toStation,
    this.railwayName,
    this.image,
    this.projectName,
    this.via,
    this.twice = false,
    this.reviewStatus,
    this.submissionStatus,
    this.update = true,
    this.destination,
    this.goals,
    this.reason,
    this.payTo,
    this.period,
    this.imageCompressed = false,
    this.from,
    this.to,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final todayStr = _formatDate(date);
    return {
      "id": id,
      "employee_id": employeeId,
      "expense_type": expenseType,
      "amount": amount,
      "commute_duration": commuteDuration,
      "duration_start": durationStart,
      "duration_end": durationEnd,
      "pay_day": todayStr,
      "month": date.month,
      "year": date.year,
      "from_station": fromStation,
      "to_station": toStation,
      "railway_name": railwayName,
      "image": image,
      "project_name": projectName,
      "via": via,
      "twice": twice,
      "review_status": reviewStatus,
      "submission_status": submissionStatus,
      "update": true,
      // optional or unused fields
      "destination": destination,
      "goals": goals,
      "reason": reason,
      "pay_to": payTo,
      "period": period,
      "image_compressed": imageCompressed,
      "from": from,
      "to": to,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  static String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
