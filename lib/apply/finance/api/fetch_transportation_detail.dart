import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/dtos/TransportationDetailResponse.dart';

Future<TransportationDetailResponse> fetchTransportationDetail(int id) async {
  //id: 교통비 / 정기권 id
  final url = Uri.parse('http://192.168.1.8:19021/transportation/$id');

  print('Fetching Transportation detail from: $url');

  final response = await http.get(
    url,
    headers: {
      'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTc4MDk5NzB9.dRYKxIofyLiZyjKmAWafh8AH8fPGtj4eKduJHhF7c2I',
      'Content-Type': 'application/json',
    },
  );

  print('statusCode: ${response.statusCode}');
  print('fetchTransportationDetail body: ${response.body}');

  if (response.statusCode == 200) {
    return TransportationDetailResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception(
        'アンケート詳細の取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
