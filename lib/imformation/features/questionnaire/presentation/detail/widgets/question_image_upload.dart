// 이미지 업로드 타입 질문 UI
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../utils/image_picker_helper.dart';

class QuestionImageUpload extends StatelessWidget {
  final int answerStatus;
  final String? imagePath;
  final void Function(String) onImageSelected;

  const QuestionImageUpload({
    super.key,
    required this.answerStatus,
    required this.imagePath,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: answerStatus == 1
          ? null
          : () {
        ImagePickerHelper.showImagePicker(
          context: context,
          onImageSelected: (File imageFile) {
            onImageSelected(imageFile.path);
          },
        );
      },
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(8),
          ),
          child: imagePath != null && imagePath!.isNotEmpty
              ? Image.file(
            File(imagePath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, size: 30, color: Colors.grey),
              SizedBox(width: 10),
              Text('画像をアップロードする', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
