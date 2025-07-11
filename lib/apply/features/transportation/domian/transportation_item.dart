class TransportationItem {
  final int id;
  final String? goals;
  final String? destination;
  final int amount;
  final bool twice;
  final String? reason;
  final String expenseType;
  final String reviewStatus;
  final String? railwayName;
  final String? durationStart;
  final int status;
  final bool imageCompressed;
  final String? payDay;
  final int year;
  final String? durationEnd;
  final String submissionStatus;
  final int month;
  final String? image;
  final String? toStation;
  final String? payTo;
  final String? projectName;
  final String? commuteDuration;
  final String createdAt;
  final String updatedAt;
  final String? fromStation;
  final String employeeId;

  TransportationItem({
    required this.id,
    this.goals,
    this.destination,
    required this.amount,
    required this.twice,
    this.reason,
    required this.expenseType,
    required this.reviewStatus,
    this.railwayName,
    this.durationStart,
    required this.status,
    required this.imageCompressed,
    this.payDay,
    required this.year,
    this.durationEnd,
    required this.submissionStatus,
    required this.month,
    this.image,
    this.toStation,
    this.payTo,
    this.projectName,
    this.commuteDuration,
    required this.createdAt,
    required this.updatedAt,
    this.fromStation,
    required this.employeeId,
  });

  factory TransportationItem.fromJson(Map<String, dynamic> json) {
    return TransportationItem(
      id: json['id'],
      goals: json['goals'],
      destination: json['destination'],
      amount: json['amount'],
      twice: json['twice'],
      reason: json['reason'],
      expenseType: json['expense_type'],
      reviewStatus: json['review_status'],
      railwayName: json['railway_name'],
      durationStart: json['duration_start'],
      status: json['status'],
      imageCompressed: json['image_compressed'],
      payDay: json['pay_day'],
      year: json['year'],
      durationEnd: json['duration_end'],
      submissionStatus: json['submission_status'],
      month: json['month'],
      image: json['image'],
      toStation: json['to_station'],
      payTo: json['pay_to'],
      projectName: json['project_name'],
      commuteDuration: json['commute_duration'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      fromStation: json['from_station'],
      employeeId: json['employee_id'],
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
    };
  }
}
