import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List?> fetchImageBlob(String fileName) async {
  final url = Uri.parse('http://192.168.1.8:19021/api/picture/$fileName');

  print('📥 이미지 요청 URL: $url');

  final response = await http.get(url, headers: {
    'Authorization':
    'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTUxNDgxMTF9.X-J3NdWt1Y0W0M3iv05VVQqrszoUp9p4jV7PmRkt1oM',
  });

  if (response.statusCode == 200) {
    print('✅ 이미지 다운로드 성공');
    return response.bodyBytes; // Uint8List 반환
  } else {
    print('❌ 이미지 다운로드 실패: ${response.statusCode}');
    return null;
  }
}
