import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Base64ImageHelper {
  /// Base64 문자열을 로컬 임시 파일로 저장한 후 반환
  static Future<File?> fromBase64ToTempFile(String base64String, {String fileName = 'temp_image.png'}) async {
    try {
      final bytes = base64Decode(base64String);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    } catch (e) {
      print('Base64 → 파일 변환 실패: $e');
      return null;
    }
  }
}
