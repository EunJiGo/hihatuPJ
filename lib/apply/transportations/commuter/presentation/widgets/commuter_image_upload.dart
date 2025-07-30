import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../utils/widgets/image_upload_widget.dart';
import '../../../../../utils/widgets/modals/image_picker_bottom_sheet.dart';
import '../../../../../utils/widgets/server_image_viewer_widget.dart';

class CommuterImageUpload extends StatefulWidget {
  final FocusNode focusNode;
  final String? imagePath; // 서버 이미지 파일명
  final bool isDisabled;
  final void Function(String) onImageSelected;

  const CommuterImageUpload({
    super.key,
    required this.focusNode,
    required this.imagePath,
    required this.isDisabled,
    required this.onImageSelected,
  });

  @override
  State<CommuterImageUpload> createState() => _CommuterImageUploadState();
}

class _CommuterImageUploadState extends State<CommuterImageUpload> {
  String? _localImagePath;

  Future<void> _pickImage() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await ImagePickerBottomSheet.showImagePicker(
      context,
      const Color(0xFF388E3C),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.focusNode.unfocus();
    });

    XFile? image;
    if (result == 'gallery') {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    } else if (result == 'camera') {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    }

    if (image != null) {
      setState(() {
        _localImagePath = image!.path; // ✅ 내부 상태로 저장
      });
      widget.onImageSelected(image.path); // 부모에게도 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _pickImage,
      child: _localImagePath != null
          ? ImageUploadDisplayWidget(
        imagePath: _localImagePath!,
        isDisabled: false,
        enabledBorderColor: const Color(0xFF81C784),
        enabledShadowColor: const Color(0x2281C784),
        enabledIconColor: const Color(0xFF81C784),
        enabledTextColor: const Color(0xFF81C784),
      )
          : ServerImageDisplayWidget(
        imageFileName: widget.imagePath,
        isDisabled: widget.isDisabled,
        enabledBorderColor: const Color(0xFF81C784),
        enabledShadowColor: const Color(0x2281C784),
        enabledIconColor: const Color(0xFF81C784),
        enabledTextColor: const Color(0xFF81C784),
      ),
    );
  }
}
