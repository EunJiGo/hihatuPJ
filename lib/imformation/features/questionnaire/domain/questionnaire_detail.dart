class QuestionnaireDetail {
  final int id;
  final String title;
  final String description;
  final String startFrom;
  final String deadline;
  final List<QuestionItem> questions;
  final int status; // 0: 보존, 1: 제출
  final String? createdAt;

  bool get isSaved => createdAt != null && status == 0;
  bool get isSubmitted => status == 1;
  bool get isNew => createdAt == null;

  QuestionnaireDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.startFrom,
    required this.deadline,
    required this.questions,
    required this.status,
    required this.createdAt,
  });

  factory QuestionnaireDetail.fromJson(Map<String, dynamic> json) {
    return QuestionnaireDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startFrom: json['startfrom'] ?? '',
      deadline: json['deadline'] ?? '',
      questions: (json['questions'] as List)
          .map((q) => QuestionItem.fromJson(q))
          .toList(),
      status: json['status'] ?? 0,
      createdAt: json['created_at'],
    );
  }
}

class QuestionItem {
  final String text;
  final String type;
  final List<String> options;

  QuestionItem({
    required this.text,
    required this.type,
    required this.options,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    return QuestionItem(
      text: json['text'] ?? '',
      type: json['type'] ?? 'text',
      options: List<String>.from(json['options'] ?? []),
    );
  }
}
