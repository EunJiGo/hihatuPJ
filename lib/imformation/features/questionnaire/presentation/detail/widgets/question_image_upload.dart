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
    final borderRadius = BorderRadius.circular(16);

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
        child: Stack(
          children: [
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.95,
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: imagePath != null
                    ?
                Colors.white
                    :
                    answerStatus == 1
                        ?
                    Colors.grey.shade200
                        :
                const Color(0xFFF0F7FF),
                borderRadius: borderRadius,
                border: Border.all(color: const Color(0xFFB0BEC5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220253B3),
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: imagePath != null && imagePath!.isNotEmpty
                    ? ColorFiltered(
                  colorFilter: answerStatus == 1
                      ? const ColorFilter.mode(
                      Colors.grey, BlendMode.saturation)
                      : const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded,
                        size: 40,
                        color: answerStatus == 1
                            ? Colors.grey.shade500
                            : const Color(0xFF6096D0)),
                    const SizedBox(height: 10),
                    Text(
                      answerStatus == 1 ? '画像をアップロードしてない' : '画像をアップロードする',
                      style: TextStyle(
                        fontSize: 16,
                        color: answerStatus == 1
                            ? Colors.grey.shade500
                            : const Color(0xFF6096D0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (answerStatus == 1)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: borderRadius,
                  ),
                ),
              ),
          ],
        ),
      )
      ,

    );
  }
}
