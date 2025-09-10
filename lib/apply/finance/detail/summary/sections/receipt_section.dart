import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hihatu_project/apply/finance/detail/summary/widgets/server_image_upload.dart';
import '../../../presentation/widgets/form_label.dart';
import '../widgets/basic_image_upload.dart';

class ReceiptSection extends StatefulWidget {
  const ReceiptSection({
    super.key,
    required this.elementId,                 // null이면 신규, 있으면 수정
    required this.isDisabled,                // 제출 완료 시 비활성화
    required this.onImageSelected,           // 선택된 파일 경로 전달
    this.imageFile,                          // 현재 선택된 파일(신규에서 주로 사용)
    this.imageName,                          // 저장된 파일명(수정에서 주로 사용)
    this.themeColor = const Color(0xFF6096D0),
    this.shadowColor = const Color(0x2281C784),
    this.label = '領収書/チケット添付',
  });

  final int? elementId;
  final bool isDisabled;
  final void Function(String path) onImageSelected;

  final File? imageFile;     // TransportationImageUpload용
  final String? imageName;   // CommuterImageUpload용 (저장된 파일명 표시)
  final Color themeColor;
  final Color shadowColor;
  final String label;

  @override
  State<ReceiptSection> createState() => _ReceiptSectionState();
}

class _ReceiptSectionState extends State<ReceiptSection> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExisting = widget.elementId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(
          text: widget.label,
          icon: Icons.receipt_long,
          iconColor: const Color(0xFF0253B3),
        ),

        if (hasExisting) ...[
          // 기존 데이터가 있는 경우: CommuterImageUpload
          ServerImageUpload(
            focusNode: _focusNode,
            imagePath: widget.imageName,                  // 저장된 파일명(또는 경로) 표시
            themeColor: widget.themeColor,
            shadowColor: widget.shadowColor,
            isDisabled: widget.isDisabled,
            onImageSelected: (path) {
              widget.onImageSelected(path);
            },
          ),
        ] else ...[
          // 신규 작성: TransportationImageUpload
          BasicImageUpload(
            focusNode: _focusNode,
            imagePath: widget.imageFile?.path,
            themeColor: widget.themeColor,
            onImageSelected: (path) {
              widget.onImageSelected(path);
            },
          ),
        ],
      ],
    );
  }
}
