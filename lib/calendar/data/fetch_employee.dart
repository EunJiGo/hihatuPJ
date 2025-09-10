import 'dart:convert';
import 'package:hihatu_project/calendar/domain/employee_response.dart';
import 'package:http/http.dart' as http;

Future<EmployeeResponse> fetchEmployee() async {
  final url = Uri.parse('http://192.168.1.8:19021/departmentmanagement/people_belong_info');

  print('fetchEmployee url: $url');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTg4NDc4MTB9.N5ix0xA-vzq2VNQmI6lRTvCihegi8L128VyrrheJe3s',
      'Content-Type': 'application/json',
    },
  );

  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    print('response.statusCode == 200');
    print('body: ${response.body}');
    return EmployeeResponse.fromJson(json.decode(response.body));
  } else {
    print('statusCode: ${response.statusCode}');
    throw Exception('アンケートの取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
