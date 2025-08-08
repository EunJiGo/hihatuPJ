import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollableTextField extends StatelessWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final String hintText;
  final void Function(String)? onChanged;
  final bool isReadOnly;

  const ScrollableTextField({
    Key? key,
    required this.controller,
    required this.scrollController,
    required this.hintText,
    this.onChanged,
    this.isReadOnly = false,
  }) : super(key: key);

  static const Color mainColor = Color(0xFF0253B3);

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
          controller.text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        // ✅ border 제거!
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: TextField(
          controller: controller,
          scrollController: scrollController,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 16),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: controller.text.isEmpty ? Colors.grey.shade400 : mainColor,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: mainColor, width: 1.8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
