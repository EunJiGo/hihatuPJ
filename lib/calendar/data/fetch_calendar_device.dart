import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/calendar_single_response.dart';

Future<CalendarSingleResponse> fetchCalendarDevice(String devideId, bool isAllList) async {
  final url = Uri.parse('http://192.168.1.8:19021/events/device/$devideId/$isAllList');

  print('fetchCalendarSingleList url: $url');
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
    return CalendarSingleResponse.fromJson(json.decode(response.body));
  } else {
    print('statusCode: ${response.statusCode}');
    throw Exception('アンケートの取得に失敗しました（HTTP ${response.statusCode}）');
  }
}
