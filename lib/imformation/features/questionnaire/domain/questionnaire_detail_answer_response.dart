import 'questionnaire.dart';

class QuestionnaireDetailAnswerResponse {
  final int code;
  final String message;
  final List<Questionnaire> data;

  QuestionnaireDetailAnswerResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuestionnaireDetailAnswerResponse.fromJson(Map<String, dynamic> json) {
    return QuestionnaireDetailAnswerResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((e) => Questionnaire.fromJson(e))
          .toList(),
    );
  }
}
