import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> showImagePicker(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('アルバムから選択'),
                onTap: () => Navigator.of(ctx).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('カメラで撮影'),
                onTap: () => Navigator.of(ctx).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('キャンセル'),
                onTap: () => Navigator.of(ctx).pop('cancel'),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }
}
