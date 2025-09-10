import 'employee.dart';

class EmployeeResponse {
  final int code;
  final String message;
  final List<Employee> data;

  EmployeeResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((e) => Employee.fromJson(e))
          .toList(),
    );
  }
}
