import 'package:hihatu_project/mypage/suggestion/domain/suggestion_detail.dart';

class SuggestionDetailResponse {
  final int code;
  final String message;
  final SuggestionDetail data;

  SuggestionDetailResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuggestionDetailResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionDetailResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: SuggestionDetail.fromJson(json['data'] as Map<String, dynamic>), // ★ Map으로 파싱
      // data: TransportationItem.fromJson(json['data']),
    );
  }
}
