import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> fetchTransportationDelete(int id) async {
  final url = Uri.parse('http://192.168.1.8:19021/transportation/$id');

  print('Fetching Transportation delete from: $url');

  final response = await http.delete(
    url,
    headers: {
      'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTUxNDgxMTF9.X-J3NdWt1Y0W0M3iv05VVQqrszoUp9p4jV7PmRkt1oM',
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
    throw Exception('交通費の削除に失敗しました（HTTP ${response.statusCode}');
  }
  return false;
}