// Answer 가져오는 타입에서 질문이 아닌 단순 answers 배열로 정의
class QuestionnaireDetailAnswer {
  final int id;
  final int survey;
  final String employeeId;
  final List<dynamic> answers;
  final int status;
  final String answeredAt;

  QuestionnaireDetailAnswer({
    required this.id,
    required this.survey,
    required this.employeeId,
    required this.answers,
    required this.status,
    required this.answeredAt,
  });

  factory QuestionnaireDetailAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionnaireDetailAnswer(
      id: json['id'] ?? 0,
      survey: json['survey'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      answers: json['answers'] ?? [],
      status: json['status'] ?? 0,
      answeredAt: json['answeredAt'] ?? '',
    );
  }
}
