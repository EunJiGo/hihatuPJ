/// 단일 이벤트(스케줄) 정보를 담는 모델
class CalendarSingle {
  /// 내부 DB PK (고유 ID)
  final int id;

  /// 이벤트 그룹 ID (반복 이벤트 묶음)
  final int eventId;

  /// 이벤트 제목
  final String title;

  /// 상세 내용 (비고)
  final String details;

  /// 시작 시각 (ISO8601 UTC 문자열)
  final String start;

  /// 종료 시각 (ISO8601 UTC 문자열)
  final String end;

  /// UI 표시용 배경 색상 (Hex 코드)
  final String? backgroundColor;

  /// 장소 (nullable)
  final String? place;

  /// 외부 URL (nullable)
  final String? url;

  /// 반복 규칙 (예: custom, weekly, biweekly, monthly, yearly)
  final String repeat;

  /// 비밀 여부 (0 = 공개, 1 = 비밀)
  final int isSecret;

  /// 상태 (1 = 활성, 그 외 = 비활성)
  final int status;

  /// 생성자 ID
  final String createdBy;

  /// 생성자 이름
  final String createdByName;

  // ✅ 장비/사람 엔드포인트 공용으로 쓰기 위해 추가
  final int? employeeId;   // employee_id (nullable)
  final int? equipmentId;  // equipment_id (nullable)
  final bool? temporary;   // temporary   (nullable)

  /// 관련 장비 목록 (예: 회의실, 프로젝터)
  /// [{equipment_id: 4, name: "회의실"}, ...]
  final List<Map<String, dynamic>> equipments;

  /// 관련 인물 목록 (예: 참석자)
  /// [{person_id: "admins", name: "관리자"}, ...]
  final List<Map<String, dynamic>> people;

  /// 반복 요일 (예: [1,3,5] → 월/수/금)
  final List<int> repeatWeekdays;

  /// 반복 일자 (예: [23,24,25])
  final List<int> repeatMonthDays;

  /// 매년 반복하는 월 (예: 8 → 8월)
  final int? repeatYearMonth;

  /// 매년 반복하는 일 (예: 23 → 23일)
  final int? repeatYearDay;

  /// 커스텀 반복 날짜 목록 (예: ["2025-09-01", "2025-09-02"])
  final List<String> customDates;

  CalendarSingle({
    required this.id,
    required this.eventId,
    required this.title,
    required this.details,
    required this.start,
    required this.end,
    this.backgroundColor,
    this.place,
    this.url,
    required this.repeat,
    required this.isSecret,
    required this.status,
    required this.createdBy,
    required this.createdByName,
    this.employeeId,
    this.equipmentId,
    this.temporary,
    required this.equipments,
    required this.people,
    required this.repeatWeekdays,
    required this.repeatMonthDays,
    this.repeatYearMonth,
    this.repeatYearDay,
    required this.customDates,
  });

  // 작은 헬퍼: 어떤 타입이 와도 int?로 안전 변환
  static int? toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool? toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
      final n = int.tryParse(v);
      if (n != null) return n != 0;
    }
    return null;
  }

  /// JSON → CalendarSingle 변환
  factory CalendarSingle.fromJson(Map<String, dynamic> json) {
    return CalendarSingle(
      id: json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      backgroundColor: json['backgroundColor'] ?? '',
      place: json['place'],
      url: json['url'],
      repeat: json['repeat'] ?? 'custom',
      isSecret: json['is_secrect'] ?? 0,
      status: json['status'] ?? 0,
      createdBy: json['created_by'] ?? '',
      createdByName: json['created_by_name'] ?? '',
      //  추가 필드 매핑
      employeeId: toInt(json['employee_id']),
      equipmentId: toInt(json['equipment_id']),
      temporary: toBool(json['temporary']),

      equipments: (json['equipments'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      people: (json['people'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      repeatWeekdays: (json['repeat_weekdays'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      repeatMonthDays: (json['repeat_month_days'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      repeatYearMonth: json['repeat_year_month'],
      repeatYearDay: json['repeat_year_day'],
      customDates: (json['customDates'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
}
