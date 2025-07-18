import 'package:flutter/material.dart';

class ImagePickerBottomSheet {
  static Future<String?> showImagePicker(BuildContext context, Color iconColor,) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: iconColor),
                title: const Text('カメラで撮影'),
                onTap: () => Navigator.of(ctx).pop('camera'),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: iconColor),
                title: const Text('アルバムから選択'),
                onTap: () => Navigator.of(ctx).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.redAccent),
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
