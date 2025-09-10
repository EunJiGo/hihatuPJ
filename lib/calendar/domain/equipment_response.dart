import 'equipment.dart';

class EquipmentResponse {
  final int code;
  final String message;
  final List<Equipment> data;

  EquipmentResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory EquipmentResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((e) => Equipment.fromJson(e))
          .toList(),
    );
  }
}
