import 'package:flutter/material.dart';
import 'package:hihatu_project/apply/finance/detail/summary/widgets/server_image_upload.dart';
import 'package:hihatu_project/utils/widgets/modals/image_picker_bottom_sheet.dart';

import 'package:image_picker/image_picker.dart';

class QuestionImageUpload extends StatelessWidget {
  final FocusNode focusNode;
  final int answerStatus; // 1이면 read-only
  final String? imagePath; // 로컬 경로 또는 서버 파일명
  final void Function(String) onImageSelected;
  final bool beforeDeadline;


  const QuestionImageUpload({
    super.key,
    required this.focusNode,
    required this.answerStatus,
    required this.imagePath,
    required this.onImageSelected,
    required this.beforeDeadline,
  });

  @override
  Widget build(BuildContext context) {

    print('QuestionImageUpload answerStatus : $answerStatus');
    print('QuestionImageUpload imagePath : $imagePath');
    print('QuestionImageUpload : $beforeDeadline');

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: answerStatus == 1
            ? null
            : () async {
          // 1. 먼저 포커스 해제
          FocusScope.of(context).requestFocus(FocusNode()); // 💥 기존 포커스 강제 제거
          await Future.delayed(Duration(milliseconds: 100)); // 살짝 딜레이 줌

          // 2. 이미지 picker 모달 띄움
          final result = await ImagePickerBottomSheet.showImagePicker(context, const Color(0xFF376EB3));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            focusNode.unfocus(); // ✅ 이게 진짜로 안전하게 작동함
          });


          // 4. 선택에 따라 이미지 가져오기
          if (result == 'gallery') {
            final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (image != null) {
              onImageSelected(image.path);
            }
          } else if (result == 'camera') {
            final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
            if (image != null) {
              onImageSelected(image.path);
            }
          }
        },
        child: ServerImageUpload(
          focusNode: FocusNode(),
          imagePath: imagePath,
          themeColor: const Color(0xFF6096D0),
          shadowColor: const Color(0x2281C784),
          isDisabled: answerStatus == 1 || beforeDeadline == false,
          // 업로드 활성화 -- 이상
          onImageSelected: onImageSelected,
        ),
      );
  }
}
