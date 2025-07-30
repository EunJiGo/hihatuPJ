import 'dart:io';
import 'package:flutter/material.dart';

class ImageUploadDisplayWidget extends StatelessWidget {
  final String? imagePath;
  final bool isDisabled;
  final Color enabledBorderColor;
  final Color enabledShadowColor;
  final Color enabledIconColor;
  final Color enabledTextColor;

  const ImageUploadDisplayWidget({
    super.key,
    required this.imagePath,
    required this.isDisabled,
    this.enabledBorderColor = const Color(0xFF90CAF9),
    this.enabledShadowColor = const Color(0x220253B3),
    this.enabledIconColor = const Color(0xFF6096D0),
    this.enabledTextColor = const Color(0xFF6096D0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 200,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: imagePath != null
                  ? Colors.white
                  : isDisabled
                  ? Colors.grey.shade200
                  : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                color: isDisabled ? Colors.grey.shade400 : enabledBorderColor,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: isDisabled ? Colors.grey.shade400 : enabledShadowColor,
              //     blurRadius: 8,
              //     offset: const Offset(2, 4),
              //   ),
              // ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: imagePath != null && imagePath!.isNotEmpty
                  ? ColorFiltered(
                colorFilter: isDisabled
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
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
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 40,
                    color: isDisabled ? Colors.grey.shade500 : enabledIconColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isDisabled ? '画像をアップロードしてない' : '画像をアップロードする',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey.shade500 : enabledTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isDisabled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
