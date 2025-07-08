import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/questionnaire_detail_answer_response.dart';

Future<QuestionnaireDetailAnswerResponse> fetchQuestionnaireDetailAnswer(int id) async {
  final url = Uri.parse('http://192.168.1.8:19021/questionnaire/answer/$id');

  print('Fetching questionnaire detail answer from: $url');

  final response = await http.get(
    url,
    headers: {
      'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTQ0NzE0Nzl9.nvlIRcBaken29ePMWnUy3vTlY0QC2riyXMiF0AI-4zw',
      'Content-Type': 'application/json',
    },
  );

  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    return QuestionnaireDetailAnswerResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception(
        'アンケート詳細の取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
