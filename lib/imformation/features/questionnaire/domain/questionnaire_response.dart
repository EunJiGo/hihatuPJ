import 'questionnaire.dart';

// 전체 응답(JSON 응답 전체 구조)의 모델
class QuestionnaireResponse {
  final int code;
  final String message;
  final List<Questionnaire> data;

  QuestionnaireResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuestionnaireResponse.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResponse(
      code: json['code'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => Questionnaire.fromJson(e))
          .toList(),
    );
  }
}
