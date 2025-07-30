import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../apply/transportations/transportation/data/fetch_image_blob.dart';

class ServerImageDisplayWidget extends StatefulWidget {
  final String? imageFileName;
  final bool isDisabled;
  final String baseUrl;
  final Color enabledBorderColor;
  final Color enabledShadowColor;
  final Color enabledIconColor;
  final Color enabledTextColor;

  const ServerImageDisplayWidget({
    super.key,
    required this.imageFileName,
    required this.isDisabled,
    this.baseUrl = 'http://192.168.1.8:19021/api/image/',
    this.enabledBorderColor = const Color(0xFF90CAF9),
    this.enabledShadowColor = const Color(0x220253B3),
    this.enabledIconColor = const Color(0xFF6096D0),
    this.enabledTextColor = const Color(0xFF6096D0),
  });

  @override
  State<ServerImageDisplayWidget> createState() =>
      _ServerImageDisplayWidgetState();
}

class _ServerImageDisplayWidgetState extends State<ServerImageDisplayWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('initState');
    print(widget.imageFileName);
    _loadImage();
  }

  Future<void> _loadImage() async {
    print('name');
    print(widget.imageFileName);

    if (widget.imageFileName == null || widget.imageFileName!.isEmpty) return;
    print('_loadImage_loadImage_loadImage');
    setState(() => _isLoading = true);
    final result = await fetchImageBlob(widget.imageFileName!);

    if (mounted) {
      setState(() {
        _imageBytes = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imageBytes != null;
    final isDisabled = widget.isDisabled;
    final noImageFile = widget.imageFileName == null || widget.imageFileName!.isEmpty;

    final shouldShowUploadHint = !isDisabled && noImageFile;
    final shouldShowNoImageMessage = isDisabled && noImageFile;
    final shouldAllowTap = !isDisabled;

    print('111111111111');
    print(isDisabled);
    print(noImageFile);
    print(widget.imageFileName);
    print(noImageFile);


    final borderColor = isDisabled
        ? Colors.grey.shade400
        : widget.enabledBorderColor;
    final shadowColor = isDisabled
        ? Colors.grey.shade400
        : widget.enabledShadowColor;
    final iconColor = isDisabled
        ? Colors.grey.shade500
        : widget.enabledIconColor;
    final textColor = isDisabled
        ? Colors.grey.shade500
        : widget.enabledTextColor;

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : hasImage
        ? Image.memory(
      _imageBytes!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    )
        : Center(
          child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          Icon(
            Icons.add_a_photo_rounded,
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 10),
          Text(
            shouldShowNoImageMessage
                ? '画像がありません'
                : '画像をアップロードする',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
                ],
              ),
        );

    final imageContainer = Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: 200,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Stack(
          children: [
            content,
            if (isDisabled && hasImage)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Center(
      child: imageContainer,
    );
  }
}
