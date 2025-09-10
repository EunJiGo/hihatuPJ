import 'package:hihatu_project/apply/finance/data/dtos/transportation_item.dart';

class TransportationDetailResponse {
  final int code;
  final String message;
  final TransportationItem data;

  TransportationDetailResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TransportationDetailResponse.fromJson(Map<String, dynamic> json) {
    return TransportationDetailResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: TransportationItem.fromJson(json['data']),
    );
  }
}
