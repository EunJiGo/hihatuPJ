// lib/widgets/common_submit_buttons.dart
import 'dart:ffi';

import 'package:flutter/material.dart';
import '../../../../utils/dialog/confirmation_dialog.dart';

class CommonSubmitButtons extends StatelessWidget {
  final VoidCallback onSavePressed;
  final VoidCallback onSubmitPressed;

  final String saveText;
  final String submitText;

  final String saveConfirmMessage;
  final String submitConfirmMessage;

  final double padding;

  final Color themeColor; // ✅ 하나의 색상만 받음

  const CommonSubmitButtons({
    super.key,
    required this.onSavePressed,
    required this.onSubmitPressed,
    this.saveText = '保　　存',
    this.submitText = '提　　出',
    this.saveConfirmMessage = '保存しますか？',
    this.submitConfirmMessage = '提出しますか？',
  required this.padding,
    this.themeColor = const Color(0xFF0253B3),
  });

  Future<void> _handleAction(BuildContext context, String type) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      message: type == 'save' ? saveConfirmMessage : submitConfirmMessage,
    );

    if (confirmed == true) {
      if (type == 'save') {
        onSavePressed();
      } else {
        onSubmitPressed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 저장 버튼: 흰 배경 + 테마컬러 텍스트
          GestureDetector(
            onTap: () => _handleAction(context, 'save'),
            child: Container(
              width: 150,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: themeColor),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  saveText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                  ),
                ),
              ),
            ),
          ),

          // 제출 버튼: 배경색 = 테마컬러, 흰 텍스트
          GestureDetector(
            onTap: () => _handleAction(context, 'submit'),
            child: Container(
              width: 150,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: themeColor),
                borderRadius: BorderRadius.circular(15),
                color: themeColor,
              ),
              child: Center(
                child: Text(
                  submitText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
