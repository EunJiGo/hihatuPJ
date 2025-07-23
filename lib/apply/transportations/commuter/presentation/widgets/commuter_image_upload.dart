import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../../utils/widgets/image_upload_widget.dart';
import '../../../../../../../utils/widgets/modals/image_picker_bottom_sheet.dart';

class CommuterImageUpload extends StatelessWidget {
  final FocusNode focusNode;
  final String? imagePath;
  final void Function(String) onImageSelected;

  const CommuterImageUpload({
    super.key,
    required this.focusNode,
    required this.imagePath,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        // 1. 포커스 해제
        FocusScope.of(context).requestFocus(FocusNode());
        await Future.delayed(const Duration(milliseconds: 100));

        // 2. 이미지 선택 모달
        final result = await ImagePickerBottomSheet.showImagePicker(
          context,
          const Color(0xFF388E3C), // 초록색 계열 테마
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.unfocus(); // 안전한 포커스 제거
        });

        // 3. 선택된 소스로 이미지 가져오기
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
        isDisabled: false, // 운송비 등록은 항상 활성화 상태
        enabledBorderColor: const Color(0xFF81C784),     // 연초록 테두리
        enabledShadowColor: const Color(0x2281C784),     // 연초록 그림자
        enabledIconColor: const Color(0xFF81C784),       // 연초록 아이콘
        enabledTextColor: const Color(0xFF81C784),       // 연초록 텍스트
      ),
    );
  }
}
