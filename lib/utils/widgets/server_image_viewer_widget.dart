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
  State<ServerImageDisplayWidget> createState() => _ServerImageDisplayWidgetState();
}

class _ServerImageDisplayWidgetState extends State<ServerImageDisplayWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.imageFileName == null || widget.imageFileName!.isEmpty) return;

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

    return Center(
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 200,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                color: widget.isDisabled ? const Color(0xFF90CAF9) : widget.enabledBorderColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isDisabled ? const Color(0x220253B3) : widget.enabledShadowColor,
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasImage
                  ? ColorFiltered(
                colorFilter: widget.isDisabled
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                child: Image.memory(
                  _imageBytes!,
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
                    color: widget.isDisabled ? Colors.grey.shade500 : widget.enabledIconColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isDisabled ? '画像がありません' : '画像をアップロードする',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isDisabled
                          ? Colors.grey.shade500
                          : widget.enabledTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isDisabled)
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
