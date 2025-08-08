import 'package:hihatu_project/mypage/suggestion/domain/suggestion_item.dart';

class SuggestionResponse {
  final int code;
  final String message;
  final List<SuggestionItem> data;

  SuggestionResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((item) => SuggestionItem.fromJson(item))
          .toList(),
      // data: TransportationItem.fromJson(json['data']),
    );
  }
}
