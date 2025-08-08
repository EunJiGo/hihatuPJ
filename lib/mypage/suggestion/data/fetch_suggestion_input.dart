import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> fetchSuggestionInput(String message) async {
  final url = Uri.parse('http://192.168.1.8:19021/advice');

  final response = await http.put(
    url,
    headers: const {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTUxNDgxMTF9.X-J3NdWt1Y0W0M3iv05VVQqrszoUp9p4jV7PmRkt1oM',
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: jsonEncode({'message': message}),
  );

  print('[PUT /advice] status=${response.statusCode} body=${response.body}');

  if (response.statusCode != 200) {
    throw Exception('送信に失敗しました（HTTP ${response.statusCode}）');
  }

  try {
    final Map<String, dynamic> body = jsonDecode(response.body);
    // 서버 규칙: code == 0 이면 성공
    return body['code'] == 0;
  } catch (e) {
    // JSON 형식이 아니거나 필드가 없을 때 실패 처리
    print('parse error: $e');
    return false;
  }
}
