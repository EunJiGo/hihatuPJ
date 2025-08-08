/// 상세 본체 (logs, replies 포함)
class SuggestionDetail {
  final int id;
  final String employeeId;
  final String name;
  final String message;
  final String? page;
  final String status;
  final String createdAt;
  final List<SuggestionLog> logs;
  final List<SuggestionReply> replies;

  SuggestionDetail({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.message,
    required this.page,
    required this.status,
    required this.createdAt,
    required this.logs,
    required this.replies,
  });

  factory SuggestionDetail.fromJson(Map<String, dynamic> json) {
    return SuggestionDetail(
      id: json['id'] as int,
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      message: json['message'] ?? '',
      page: json['page'], // null 가능
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      logs: ((json['logs'] as List?) ?? const [])
          .map((e) => SuggestionLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      replies: ((json['replies'] as List?) ?? const [])
          .map((e) => SuggestionReply.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'message': message,
      'page': page,
      'status': status,
      'created_at': createdAt,
      'logs': logs.map((e) => e.toJson()).toList(),
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }
}

/// 로그 한 건
class SuggestionLog {
  final int id;
  final int suggestion; // suggestionId (FK)
  final String time;    // ISO8601 string (UTC)
  final String text;    // 예: "送信されました", "返信が送信されました（admins）"
  final String type;    // "primary" | "success" ...

  SuggestionLog({
    required this.id,
    required this.suggestion,
    required this.time,
    required this.text,
    required this.type,
  });

  factory SuggestionLog.fromJson(Map<String, dynamic> json) {
    return SuggestionLog(
      id: json['id'] as int,
      suggestion: json['suggestion'] as int,
      time: json['time'] ?? '',
      text: json['text'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'suggestion': suggestion,
      'time': time,
      'text': text,
      'type': type,
    };
  }
}

/// 답변 한 건
class SuggestionReply {
  final int id;
  final int suggestion; // suggestionId (FK)
  final String replier; // 답변자 id/name
  final String content; // 답변 내용
  final String repliedAt; // ISO8601 string (UTC)

  SuggestionReply({
    required this.id,
    required this.suggestion,
    required this.replier,
    required this.content,
    required this.repliedAt,
  });

  factory SuggestionReply.fromJson(Map<String, dynamic> json) {
    return SuggestionReply(
      id: json['id'] as int,
      suggestion: json['suggestion'] as int,
      replier: json['replier'] ?? '',
      content: json['content'] ?? '',
      repliedAt: json['replied_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'suggestion': suggestion,
      'replier': replier,
      'content': content,
      'replied_at': repliedAt,
    };
  }
}