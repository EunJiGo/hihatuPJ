// 📁 lib/questionnaire/data/save_questionnaire_answer.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> fetchSaveQuestionnaireAnswer({
  required int questionnaireId,
  required int status, // 0 = 保存, 1 = 提出
  required List<dynamic> answers,
}) async {
  final url = Uri.parse('http://192.168.1.8:19021/questionnaire/$status');

  final response = await http.put(
    url,
    headers: {
      'Authorization':
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTQyMDI5MTh9.t4khy1jKlrwrtk_k4p38gIVHnx_vH_97hPOQD7rziHg',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'id': questionnaireId,
      'answers': answers,
    }),
  );

  if (response.statusCode == 200) {
    print("sucess teisilyutu");
    final body = jsonDecode(response.body);
    if (body['code'] == 0) {
      return true;
    }
  }

  return false;
}

