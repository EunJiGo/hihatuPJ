import 'package:hihatu_project/imformation/features/questionnaire/domain/questionnaire_detail_answer.dart';

class QuestionnaireDetailAnswerResponse {
  final int code;
  final String message;
  final QuestionnaireDetailAnswer? data;

  QuestionnaireDetailAnswerResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuestionnaireDetailAnswerResponse.fromJson(Map<String, dynamic> json) {
    return QuestionnaireDetailAnswerResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: json['data'] != null ? QuestionnaireDetailAnswer.fromJson(json['data']) : null,
    );
  }
}
