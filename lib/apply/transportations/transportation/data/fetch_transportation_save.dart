import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domian/transportation_save.dart';

// 교통비 등록 요청 (PUT)
Future<bool> fetchTransportationSave(TransportationSave data) async {
  final url = Uri.parse('http://192.168.1.8:19021/transportation/');

  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTUxNDgxMTF9.X-J3NdWt1Y0W0M3iv05VVQqrszoUp9p4jV7PmRkt1oM',
      'Content-Type': 'application/json',
    },
    // body: json.encode(data.toJson()), // 여기에 JSON 바디 넣기
    body: json.encode({
      "data": data.toJson(), //  중요: 이렇게 감싸야 함!
    }),
  );

  print('fetchTransportationSAVE');
  print('statusCode: ${response.statusCode}');
  print('body: ${response.body}');

  if (response.statusCode == 200) {
    // final Map<String, dynamic> jsonBody = json.decode(response.body);
    // final responseObj = TransportationResponse.fromJson(jsonBody);
    final body = jsonDecode(response.body);
    if (body['code'] == 0) {
      return true;
    }
    // return responseObj.data;
  } else {
    throw Exception('交通費の登録に失敗しました（HTTP ${response.statusCode}');
  }
  return false;

}
