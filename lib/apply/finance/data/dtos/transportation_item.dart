class TransportationItem {
  final int? id;
  final String goals;
  final String destination;
  final int amount;
  final bool twice;
  final String reason;
  final String expenseType;
  final String reviewStatus;
  final String railwayName;
  final String durationStart;
  final int status;
  final bool imageCompressed;
  final String payDay;
  final int year;
  final String durationEnd;
  final String submissionStatus;
  final int month;
  final String image;
  final String toStation;
  final String payTo;
  final String projectName;
  final String commuteDuration;
  final String createdAt;
  final String updatedAt;
  final String fromStation;
  final String employeeId;
  final String via;

  TransportationItem({
    this.id,
    required this.goals,
    required this.destination,
    required this.amount,
    required this.twice,
    required this.reason,
    required this.expenseType,
    required this.reviewStatus,
    required this.railwayName,
    required this.durationStart,
    required this.status,
    required this.imageCompressed,
    required this.payDay,
    required this.year,
    required this.durationEnd,
    required this.submissionStatus,
    required this.month,
    required this.image,
    required this.toStation,
    required this.payTo,
    required this.projectName,
    required this.commuteDuration,
    required this.createdAt,
    required this.updatedAt,
    required this.fromStation,
    required this.employeeId,
    required this.via,
  });

  factory TransportationItem.fromJson(Map<String, dynamic> json) {
    return TransportationItem(
      id: json['id'],
      goals: json['goals'] ?? '',
      destination: json['destination'] ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      twice: json['twice'] ?? false,
      reason: json['reason'] ?? '',
      expenseType: json['expense_type'] ?? '',
      reviewStatus: json['review_status'] ?? '',
      railwayName: json['railway_name'] ?? '',
      durationStart: json['duration_start'] ?? '',
      status: json['status'] ?? 0,
      imageCompressed: json['image_compressed'] ?? false,
      payDay: json['pay_day'] ?? '',
      year: json['year'] ?? 0,
      durationEnd: json['duration_end'] ?? '',
      submissionStatus: json['submission_status'] ?? '',
      month: json['month'] ?? 0,
      image: json['image'] ?? '',
      toStation: json['to_station'] ?? '',
      payTo: json['pay_to'] ?? '',
      projectName: json['project_name'] ?? '',
      commuteDuration: json['commute_duration'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      fromStation: json['from_station'] ?? '',
      employeeId: json['employee_id'] ?? '',
      via: json['via'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goals': goals,
      'destination': destination,
      'amount': amount,
      'twice': twice,
      'reason': reason,
      'expense_type': expenseType,
      'review_status': reviewStatus,
      'railway_name': railwayName,
      'duration_start': durationStart,
      'status': status,
      'image_compressed': imageCompressed,
      'pay_day': payDay,
      'year': year,
      'duration_end': durationEnd,
      'submission_status': submissionStatus,
      'month': month,
      'image': image,
      'to_station': toStation,
      'pay_to': payTo,
      'project_name': projectName,
      'commute_duration': commuteDuration,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'from_station': fromStation,
      'employee_id': employeeId,
      'via': via,
    };
  }
}
