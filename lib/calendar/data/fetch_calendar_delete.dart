import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> fetchCalendarDelete(int id) async {
  final url = Uri.parse('http://192.168.1.8:19021/events/device/$id');

  print('Fetching Calendar delete from: $url');

  final response = await http.delete(
    url,
    headers: {
      'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTg4NDc4MTB9.N5ix0xA-vzq2VNQmI6lRTvCihegi8L128VyrrheJe3s',
      'Content-Type': 'application/json',
    },
  );

  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    if (body['code'] == 0) {
      return true;
    }
  } else {
    throw Exception('カレンダー日程の削除に失敗しました（HTTP ${response.statusCode}');
  }
  return false;
}