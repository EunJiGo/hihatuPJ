import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../utils/widgets/image_upload_widget.dart';
import '../../../../../../utils/widgets/modals/image_picker_bottom_sheet.dart';

import 'package:image_picker/image_picker.dart';

class QuestionImageUpload extends StatelessWidget {
  final FocusNode focusNode;
  final int answerStatus;
  final String? imagePath;
  final void Function(String) onImageSelected;

  const QuestionImageUpload({
    super.key,
    required this.focusNode,
    required this.answerStatus,
    required this.imagePath,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {

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
        child: ImageUploadDisplayWidget(
          imagePath: imagePath,
          isDisabled: answerStatus == 1,
          enabledBorderColor: Color(0xFF90CAF9),
          enabledShadowColor: Color(0x220253B3),
          enabledIconColor: Color(0xFF6096D0),
          enabledTextColor: Color(0xFF6096D0),
        )
      ,
      );
  }
}
