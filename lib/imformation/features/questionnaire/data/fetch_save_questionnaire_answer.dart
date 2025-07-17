// 📁 lib/questionnaire/data/save_questionnaire_answer.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> fetchSaveQuestionnaireAnswer({
  required int questionnaireId,
  required int status, // 0 = 保存, 1 = 提出
  required List<dynamic> answers,
}) async {
  final url = Uri.parse('http://192.168.1.8:19021/questionnaire/$status');


  print('questionnaireId: $questionnaireId');
  print('status: $status');
  print('answers: ${jsonEncode(answers)}');


  final response = await http.put(
    url,
    headers: {
      'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTUxNDgxMTF9.X-J3NdWt1Y0W0M3iv05VVQqrszoUp9p4jV7PmRkt1oM',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'id': questionnaireId,
      'answers': answers,
    }),
  );

  print('${response.statusCode}');
  print('${response.body}');
  if (response.statusCode == 200) {
    print("sucess teisilyutu");
    final body = jsonDecode(response.body);
    if (body['code'] == 0) {
      return true;
    }
  } else {
    throw Exception(
        'アンケート詳細の取得に失敗しました（HTTP ${response.body}）');
  }

  return false;
}

