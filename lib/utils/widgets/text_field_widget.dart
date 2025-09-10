import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatelessWidget {
  final Color? editableBackgroundColor;
  final Color editableBorderColor;
  final Color selectedBorderColor;
  final String hintText;
  final Color hintColor;
  final bool isReadOnly;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWidget({
    super.key,
    this.editableBackgroundColor,
    required this.editableBorderColor,
    required this.selectedBorderColor,
    required this.hintText,
    required this.hintColor,
    required this.isReadOnly,
    this.focusNode,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          // color: Colors.grey.shade200,
          // color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          controller?.text ?? '',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return TextField(
      maxLines: null,
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        // hintStyle: TextStyle(color: const Color(0xFF1565C0),),
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: controller!.text.isEmpty ? Colors.grey.shade400 : editableBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: selectedBorderColor, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
        fillColor: Colors.white,
        // fillColor: controller?.text.isEmpty == true ? Colors.white : hintColor, // ⬅️ 내부도 동일한 색상
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
