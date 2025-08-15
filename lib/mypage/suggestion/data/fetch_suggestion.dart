import 'dart:convert';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_response.dart';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_item.dart';
import 'package:http/http.dart' as http;

import '../domain/suggestion_item.dart';
import '../domain/suggestion_response.dart';

// HTTP 요청 처리
Future<List<SuggestionItem>> fetchSuggestion() async {
  // final url = Uri.parse('http://192.168.1.8:19021/transportation/$month/$year');
  final url = Uri.parse('http://192.168.1.8:19021/advice/user');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTc4MDk5NzB9.dRYKxIofyLiZyjKmAWafh8AH8fPGtj4eKduJHhF7c2I',
      'Content-Type': 'application/json',
    },
  );

  print('fetchSuggest');
  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    print('response.statusCode == 200');
    print('body: ${response.body}');
    // return TransportationItem.fromJson(json.decode(response.body));
    final Map<String, dynamic> jsonBody = json.decode(response.body);
    final responseObj = SuggestionResponse.fromJson(jsonBody);
    print(responseObj.data);
    return responseObj.data;
  } else {
    print('statusCode: ${response.statusCode}');
    throw Exception('アンケートの取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
