import 'calendar_single.dart';

class CalendarSingleResponse {
  final int code;
  final String message;
  final List<CalendarSingle> data;

  CalendarSingleResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory CalendarSingleResponse.fromJson(Map<String, dynamic> json) {
    return CalendarSingleResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((e) => CalendarSingle.fromJson(e))
          .toList(),
    );
  }
}
