import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui; // 이미지 크기/코덱
import 'package:flutter/material.dart';

class ImageUploadDisplayWidget extends StatefulWidget {
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
  State<ImageUploadDisplayWidget> createState() =>
      _ImageUploadDisplayWidgetState();
}

class _ImageUploadDisplayWidgetState extends State<ImageUploadDisplayWidget> {
  Uint8List? _bytes;
  double? _aspectRatio; // 가로/세로 비율
  bool _isLoading = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant ImageUploadDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _prepare();
    }
  }

  Future<void> _prepare() async {
    final path = widget.imagePath;
    if (path == null || path.isEmpty || !await File(path).exists()) {
      setState(() {
        _bytes = null;
        _aspectRatio = null;
        _isLoading = false;
        _loadFailed = false; // 파일 없음은 실패로 보지 않음
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final bytes = await File(path).readAsBytes();

      // 이미지 코덱으로 사이즈 얻기
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final ratio =
      (img.width == 0 || img.height == 0) ? null : img.width / img.height;
      img.dispose();

      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _aspectRatio = ratio;
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _aspectRatio = null;
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _bytes != null;
    final isDisabled = widget.isDisabled;

    final borderColor =
    isDisabled ? Colors.grey.shade400 : widget.enabledBorderColor;
    final shadowColor =
    isDisabled ? Colors.grey.shade400 : widget.enabledShadowColor;
    final iconColor = isDisabled ? Colors.grey.shade500 : widget.enabledIconColor;
    final textColor = isDisabled ? Colors.grey.shade500 : widget.enabledTextColor;

    // 메인 콘텐츠
    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (hasImage) {
      content = Image.memory(
        _bytes!,
        fit: BoxFit.contain, // 전체 보이기 (크롭 없음)
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_rounded,
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 10),
          Text(
            isDisabled ? '画像をアップロードしてない' : '画像をアップロードする',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          if (_loadFailed && !isDisabled)
            Text(
              '画像の読み込みに失敗しました',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.withValues(alpha: 0.8),
              ),
            ),
        ],
      );
    }

    // 프레임(보더/섀도우/배경)
    final frame = Container(
      width: MediaQuery.of(context).size.width,
      // 높이는 내부 AspectRatio가 결정 (이미지 없을 땐 placeholder 높이 사용)
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: hasImage ? Colors.white : (isDisabled ? Colors.grey.shade200 : Colors.white),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: borderColor),
        // 필요 시 섀도우 켜기
        // boxShadow: [
        //   BoxShadow(
        //     color: shadowColor,
        //     blurRadius: 8,
        //     offset: const Offset(2, 4),
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Stack(
          children: [
            // 이미지가 있고 비율이 있으면 AspectRatio 사용
            if (hasImage && _aspectRatio != null)
              AspectRatio(
                aspectRatio: _aspectRatio!,
                child: content,
              )
            // 이미지가 없거나 비율을 아직 모르면 임시 높이
            else
              SizedBox(
                height: 200,
                child: Center(child: content),
              ),

            // read-only 오버레이
            if (isDisabled)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), // withOpacity → withValues
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Center(child: frame);
  }
}
