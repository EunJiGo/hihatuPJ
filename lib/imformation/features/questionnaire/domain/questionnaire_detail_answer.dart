class QuestionnaireDetailAnswer {
  final int id;
  final String title;
  final String startFrom;
  final String deadline;
  final String? answeredAt;
  final int answered;
  final int saved;

  QuestionnaireDetailAnswer({
    required this.id,
    required this.title,
    required this.startFrom,
    required this.deadline,
    required this.answeredAt,
    required this.answered,
    required this.saved,
  });

  factory QuestionnaireDetailAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionnaireDetailAnswer(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      startFrom: json['startfrom'] ?? '',
      deadline: json['deadline'] ?? '',
      answeredAt: json['answered_at'],
      answered: json['answered'] ?? 0,
      saved: json['saved'] ?? 0,
    );
  }
}
