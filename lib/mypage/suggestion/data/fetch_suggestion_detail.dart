import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/suggestion_detail_response.dart';
import '../domain/suggestion_detail.dart';

// HTTP 요청 처리
Future<SuggestionDetail> fetchSuggestionDetail(int suggestionId) async {
  // final url = Uri.parse('http://192.168.1.8:19021/transportation/$month/$year');
  final url = Uri.parse('http://192.168.1.8:19021/advice/user/details/${suggestionId}');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTUxNDgxMTF9.X-J3NdWt1Y0W0M3iv05VVQqrszoUp9p4jV7PmRkt1oM',
      'Content-Type': 'application/json',
    },
  );

  print('SuggestionDetail');
  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    print('response.statusCode == 200');
    print('body: ${response.body}');
    // return TransportationItem.fromJson(json.decode(response.body));
    final Map<String, dynamic> jsonBody = json.decode(response.body);
    final responseObj = SuggestionDetailResponse.fromJson(jsonBody);
    print(responseObj.data);
    return responseObj.data;
  } else {
    print('statusCode: ${response.statusCode}');
    throw Exception('アンケートの取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
