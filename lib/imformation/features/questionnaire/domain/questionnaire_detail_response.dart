import 'questionnaire_detail.dart';

class QuestionnaireDetailResponse {
  final int code;
  final String message;
  final QuestionnaireDetail data;

  QuestionnaireDetailResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuestionnaireDetailResponse.fromJson(Map<String, dynamic> json) {
    return QuestionnaireDetailResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: QuestionnaireDetail.fromJson(json['data']),
    );
  }
}
