class SuggestionItem {
  final int id;
  final String message;
  final String employeeId;
  final String createdAt;
  final String status;
  final String name;
  final String? page;

  SuggestionItem({
    required this.id,
    required this.message,
    required this.employeeId,
    required this.createdAt,
    required this.status,
    required this.name,
    this.page,
  });

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    return SuggestionItem(
      id: json['id'],
      message: json['message'] ?? '',
      employeeId: json['employee_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
      name: json['name'] ?? '',
      page: json['page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'employee_id': employeeId,
      'created_at': createdAt,
      'status': status,
      'name': name,
      'page': page,
    };
  }
}
