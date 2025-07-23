import 'package:hihatu_project/apply/transportations/transportation/domian/transportation_item.dart';

class TransportationResponse {
  final int code;
  final String message;
  final List<TransportationItem> data;

  TransportationResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TransportationResponse.fromJson(Map<String, dynamic> json) {
    return TransportationResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((item) => TransportationItem.fromJson(item))
          .toList(),
      // data: TransportationItem.fromJson(json['data']),
    );
  }
}
