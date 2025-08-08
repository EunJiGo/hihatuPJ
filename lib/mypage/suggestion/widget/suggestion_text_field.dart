import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../../../utils/widgets/text_field_widget.dart';

class SuggestionTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String) onChanged;
  final  String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const SuggestionTextField({
    super.key,
    this.controller,
    this.focusNode,
    required this.onChanged,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    print('🧪 controller: $controller');

    return TextFieldWidget(
      isReadOnly: false,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      hintText: hintText,
      hintColor: const Color(0xFFffffff), // 지금 editableBackgroundColor의 색깔이 hintColor가 덮어씌움
      // editableBackgroundColor: const Color(0xFFFCFFF0), // 이거 넣으면 뒤에 네모 상자가나옴
      // editableBackgroundColor: Colors.white, // 이거 넣으면 뒤에 네모 상자가나옴
      editableBorderColor: const Color(0xFF0253B3),
      selectedBorderColor: const Color(0xFF0253B3),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}