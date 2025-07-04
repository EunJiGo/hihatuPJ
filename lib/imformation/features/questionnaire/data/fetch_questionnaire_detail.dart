import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/questionnaire_detail_response.dart';

Future<QuestionnaireDetailResponse> fetchQuestionnaireDetail(int id) async {
  final url = Uri.parse('http://192.168.1.8:19021/questionnaire/question/$id');

  print('Fetching questionnaire detail from: $url');

  final response = await http.get(
    url,
    headers: {
      'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTQyMDI5MTh9.t4khy1jKlrwrtk_k4p38gIVHnx_vH_97hPOQD7rziHg',
      'Content-Type': 'application/json',
    },
  );

  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    return QuestionnaireDetailResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception(
        'アンケート詳細の取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
