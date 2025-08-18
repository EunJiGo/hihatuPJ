import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/transportation_save.dart';
import '../domain/transportation_update.dart';

// 교통비 등록 요청 (PUT)
Future<bool> fetchTransportationSubmit(String employeeId, DateTime date) async {
  print(date.year);
  print(date.month);
  final url = Uri.parse('http://192.168.1.8:19021/transportation/checkout/$employeeId/${date.year}/${date.month}');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTc4MDk5NzB9.dRYKxIofyLiZyjKmAWafh8AH8fPGtj4eKduJHhF7c2I',
      'Content-Type': 'application/json',
    },
  );

  print('fetchTransportationSubmit');
  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    if (body['code'] == 0) {
      return true;
    }
  } else {
    throw Exception('交通費の提出に失敗しました（HTTP ${response.statusCode}');
  }
  return false;

}
