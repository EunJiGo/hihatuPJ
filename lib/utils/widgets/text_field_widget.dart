import 'dart:ui';

import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final Color editableBackgroundColor;
  final Color editableBorderColor;
  final Color selectedBorderColor;
  final String hintText;
  final Color hintColor;
  final bool isReadOnly;
  final String inputValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String) onChanged;

  const TextFieldWidget({
    super.key,
    required this.editableBackgroundColor,
    required this.editableBorderColor,
    required this.selectedBorderColor,
    required this.hintText,
    required this.hintColor,
    required this.isReadOnly,
    required this.inputValue,
    this.focusNode,
    this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          inputValue,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    print('editableBackgroundColor = ${editableBackgroundColor}');
    return Container(
      decoration: BoxDecoration(
        color: editableBackgroundColor, // 통일감을 위한 밝은 파랑 회색 배경
        // borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: editableBorderColor),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Color(0x220253B3),
        //     blurRadius: 6,
        //     offset: Offset(2, 4),
        //   )
        // ],
      ),
      child: TextField(
        maxLines: null,
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          // hintStyle: TextStyle(color: const Color(0xFF1565C0),),
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: editableBorderColor),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: selectedBorderColor, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          filled: true,
          fillColor:
              inputValue.isEmpty ? Colors.white : hintColor, // ⬅️ 내부도 동일한 색상
        ),
        onChanged: onChanged,
      ),
    );
  }
}
