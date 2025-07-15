import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final Color readOnlyBackgroundColor;
  final Color readOnlyBorderColor;
  final Color editableBackgroundColor;
  final Color editableBorderColor;
  final String hintText;
  final Color hintColor;
  final bool isReadOnly;
  final String inputValue;
  final TextEditingController? controller;
  final void Function(String) onChanged;

  const TextFieldWidget({
    super.key,
    required this.readOnlyBackgroundColor,
    required this.readOnlyBorderColor,
    required this.editableBackgroundColor,
    required this.editableBorderColor,
    required this.hintText,
    required this.hintColor,
    required this.isReadOnly,
    required this.inputValue,
    this.controller,
    required this.onChanged,
  });

  @override
  State<TextFieldWidget> createState() =>
      _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {


  @override
  Widget build(BuildContext context) {
    if(widget.isReadOnly) {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: widget.readOnlyBackgroundColor,
            border: Border.all(color: widget.readOnlyBorderColor),
            borderRadius: BorderRadius.circular(12),
          ),
        child: Text(
          widget.inputValue,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        )
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.editableBackgroundColor, // 통일감을 위한 밝은 파랑 회색 배경
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.editableBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220253B3),
            blurRadius: 6,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: TextField(
        maxLines: null,
        controller: widget.controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF81D4FA), width: 2),
          ),
          filled: true,
          fillColor: widget.hintColor, // ⬅️ 내부도 동일한 색상
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF81D4FA), width: 2),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
