import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../utils/widgets/image_upload_widget.dart';
import '../../../../../utils/widgets/modals/image_picker_bottom_sheet.dart';
import '../../../../../utils/widgets/server_image_viewer_widget.dart';

class CommuterImageUpload extends StatefulWidget {
  final FocusNode focusNode;
  final String? imagePath; // 서버 이미지 파일명
  final Color themeColor;
  final Color shadowColor;
  final bool isDisabled;
  final void Function(String) onImageSelected;

  const CommuterImageUpload({
    super.key,
    required this.focusNode,
    required this.imagePath,
    required this.themeColor,
    required this.shadowColor,
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
      widget.themeColor,
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
    print('isDisabled : ${widget.isDisabled}');
    print('(widget.imagePath');
    print(widget.imagePath);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!widget.isDisabled) {
          _pickImage();
        }
      },
      child: _localImagePath != null
          ? ImageUploadDisplayWidget(
        imagePath: _localImagePath!,
        isDisabled: widget.isDisabled,
        enabledBorderColor: widget.themeColor,
        enabledShadowColor: widget.shadowColor,
        enabledIconColor: widget.themeColor,
        enabledTextColor: widget.themeColor,
      )
          : ServerImageDisplayWidget(
        imageFileName: widget.imagePath,
        isDisabled: widget.isDisabled,
        enabledBorderColor: widget.themeColor,
        // enabledBorderColor: const Color(0xFF81C784),
        enabledShadowColor: widget.shadowColor,
        enabledIconColor: widget.themeColor,
        enabledTextColor: widget.themeColor,
      ),
    );
  }
}
