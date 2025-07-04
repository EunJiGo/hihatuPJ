class Questionnaire {
  final int id;
  final String title;
  final String startFrom;
  final String deadline;
  final String answeredAt;
  final int answered;
  final int saved;

  Questionnaire({
    required this.id,
    required this.title,
    required this.startFrom,
    required this.deadline,
    required this.answeredAt,
    required this.answered,
    required this.saved,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      startFrom: json['startfrom'] ?? '',
      deadline: json['deadline'] ?? '',
      answeredAt: json['answered_at'] ?? '',
      answered: json['answered'] ?? 0,
      saved: json['saved'] ?? 0,
    );
  }
}
