import 'dart:convert';
import 'package:hihatu_project/apply/features/transportation/domian/transportation_response.dart';
import 'package:hihatu_project/apply/features/transportation/domian/transportation_item.dart';
import 'package:http/http.dart' as http;

// HTTP 요청 처리 (http://192.168.1.8:19021/questionnaire 호출)
Future<List<TransportationItem>> fetchTransportation(int year, int month) async {
  // final url = Uri.parse('http://192.168.1.8:19021/transportation/$month/$year');
  final url = Uri.parse('http://192.168.1.8:19021/transportation/')
      .replace(queryParameters: {
    'year': year.toString(),
    'month': month.toString(),
  });

  print('url');
  print(url);
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTQ4MTEyNzV9.u1H-FFyWYtXI67z_RuU_L9j8teHm8KwwVwXqucT5w2E',
      'Content-Type': 'application/json',
    },
  );

  print('fetchTransportation');
  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    print('response.statusCode == 200');
    print('body: ${response.body}');
    // return TransportationItem.fromJson(json.decode(response.body));
    final Map<String, dynamic> jsonBody = json.decode(response.body);
    final responseObj = TransportationResponse.fromJson(jsonBody);
    print(responseObj.data);
    return responseObj.data;
  } else {
    print('statusCode: ${response.statusCode}');
    throw Exception('アンケートの取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
