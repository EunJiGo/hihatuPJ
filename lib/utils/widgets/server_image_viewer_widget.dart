import 'dart:async'; // ← Completer
import 'dart:typed_data';
import 'dart:ui' as ui; // ← 이미지 사이즈 해석용
import 'package:flutter/material.dart';
import '../../apply/finance/api/fetch_image_blob.dart';

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
  double? _aspectRatio; // 이미지 가로/세로 비율
  bool _isLoading = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ServerImageDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFileName != widget.imageFileName) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final fileName = widget.imageFileName;
    if (fileName == null || fileName.isEmpty) {
      setState(() {
        _imageBytes = null;
        _aspectRatio = null;
        _isLoading = false;
        _loadFailed = false; // 파일명 없음은 실패 아님
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final bytes = await fetchImageBlob(fileName);
      if (!mounted) return;

      if (bytes == null) {
        setState(() {
          _imageBytes = null;
          _aspectRatio = null;
          _isLoading = false;
          _loadFailed = true;
        });
        return;
      }

      // ✅ decodeImageFromList는 콜백 기반이므로 Completer로 감싸서 Future처럼 사용
      final info = await _decodeImage(bytes);
      final ratio = (info.width == 0 || info.height == 0)
          ? null
          : info.width / info.height;
      info.dispose();

      setState(() {
        _imageBytes = bytes;
        _aspectRatio = ratio;
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _imageBytes = null;
        _aspectRatio = null;
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  // 콜백 기반 API를 Future로 래핑
  Future<ui.Image> _decodeImage(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      if (!completer.isCompleted) completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imageBytes != null;
    final isDisabled = widget.isDisabled;
    final noImageFile =
        widget.imageFileName == null || widget.imageFileName!.isEmpty;

    final borderColor =
    isDisabled ? Colors.grey.shade400 : widget.enabledBorderColor;
    final shadowColor =
    isDisabled ? Colors.grey.shade400 : widget.enabledShadowColor;
    final iconColor = isDisabled ? Colors.grey.shade500 : widget.enabledIconColor;
    final textColor = isDisabled ? Colors.grey.shade500 : widget.enabledTextColor;

    // ── 메인 컨텐츠
    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (hasImage) {
      content = Image.memory(
        _imageBytes!,
        fit: BoxFit.contain,        // 잘림 없이 전체 보기
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              !noImageFile
                  ? Icons.error_outline_rounded
                  : Icons.add_a_photo_rounded,
              size: 40,
              color: iconColor,
            ),
            const SizedBox(height: 10),
            Text(
              !noImageFile
                  ? '画像の読み込みに失敗しました'
                  : (isDisabled ? '画像がありません' : '画像をアップロードする'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (_loadFailed && !isDisabled)
              TextButton(
                onPressed: _loadImage,
                child: const Text('再試行する'),
              ),
          ],
        ),
      );
    }

    // ── 프레임(보더/섀도우)
    final frame = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(0),
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
            // 이미지가 있으면 비율에 맞춰 높이 자동 결정
            if (hasImage && _aspectRatio != null)
              AspectRatio(
                aspectRatio: _aspectRatio!,
                child: content,
              )
            else
              SizedBox(
                height: 200, // 플레이스홀더/로딩 시 임시 높이
                child: content,
              ),

            if (isDisabled && hasImage)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), // ← withOpacity 대체
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
