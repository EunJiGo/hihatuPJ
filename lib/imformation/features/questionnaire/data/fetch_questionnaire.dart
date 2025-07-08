import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/questionnaire_response.dart';

// HTTP 요청 처리 (http://192.168.1.8:19021/questionnaire 호출)
Future<QuestionnaireResponse> fetchQuestionnaireList() async {
  final url = Uri.parse('http://192.168.1.8:19021/questionnaire');

  // final response = await http.get(url);

  print('url');
  print(url);
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTQ0NzE0Nzl9.nvlIRcBaken29ePMWnUy3vTlY0QC2riyXMiF0AI-4zw',
      'Content-Type': 'application/json',
    },
  );

  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    print('response.statusCode == 200');
    print('body: ${response.body}');
    return QuestionnaireResponse.fromJson(json.decode(response.body));
  } else {
    print('statusCode: ${response.statusCode}');
    throw Exception('アンケートの取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
