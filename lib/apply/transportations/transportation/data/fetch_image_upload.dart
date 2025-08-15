import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

Future<String?> fetchImageUpload(String employeeId, File imageFile) async {
  final uri = Uri.parse('http://192.168.1.8:19021/api/upload');

  final request = http.MultipartRequest('POST', uri);

  request.headers.addAll({
    'id': employeeId,
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbnMiLCJleHAiOjE3NTc4MDk5NzB9.dRYKxIofyLiZyjKmAWafh8AH8fPGtj4eKduJHhF7c2I',
  });

  final extension = imageFile.path.split('.').last.toLowerCase();
  final mimeType = (extension == 'png') ? 'png' : 'jpeg';

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', mimeType),
    ),
  );

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  print('📤 이미지 업로드 응답 status: ${response.statusCode}');
  print('📤 body: $responseBody');



  if (response.statusCode == 200) {
    final jsonBody = jsonDecode(responseBody);

// 서버가 "url"만 내려주면 여기서 파일명만 추출
    final String fullPath = jsonBody['url'] ?? '';
    final String fileName = fullPath.split('/').last.replaceAll('\\', '');

// ✅ 이걸 반환
    return fileName.isNotEmpty ? fileName : null;

  } else {
    throw Exception('画像アップロードに失敗しました（HTTP ${response.statusCode})');
  }
}
