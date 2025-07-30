import 'package:flutter/material.dart';
import '../../../../utils/dialog/confirmation_dialog.dart';

class CommonSubmitButtons extends StatelessWidget {
  final VoidCallback? onSavePressed;
  final VoidCallback? onSubmitPressed;

  final String saveText;
  final String submitText;

  final String? saveConfirmMessage;
  final String? submitConfirmMessage;

  final double padding;
  final Color themeColor;

  final bool showSaveButton;
  final bool showSubmitButton;

  const CommonSubmitButtons({
    super.key,
    this.onSavePressed,
    this.onSubmitPressed,
    this.saveText = '保　　存',
    this.submitText = '提　　出',
    this.saveConfirmMessage,
    this.submitConfirmMessage,
    this.padding = 0.0,
    this.themeColor = const Color(0xFF0253B3),
    this.showSaveButton = true,
    this.showSubmitButton = true,
  });

  Future<void> _handleAction(BuildContext context, String type) async {
    final message = type == 'save' ? saveConfirmMessage : submitConfirmMessage;
    final callback = type == 'save' ? onSavePressed : onSubmitPressed;

    if (callback == null) return;

    if (message == null) {
      callback();
      return;
    }

    final confirmed = await ConfirmationDialog.show(context, message: message);
    if (confirmed == true) {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (showSaveButton && onSavePressed != null) {
      final saveBtn = _buildButton(
        label: saveText,
        isFilled: !showSubmitButton, // 단독이면 채우기
        onPressed: () => _handleAction(context, 'save'),
        fullWidth: !showSubmitButton,
      );
      buttons.add(saveBtn);
    }

    if (showSubmitButton && onSubmitPressed != null) {
      final submitBtn = _buildButton(
        label: submitText,
        isFilled: true,
        onPressed: () => _handleAction(context, 'submit'),
        fullWidth: !showSaveButton,
      );
      buttons.add(submitBtn);
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: buttons.length == 1 ? [buttons.first] : buttons,
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isFilled,
    required VoidCallback onPressed,
    required bool fullWidth,
  }) {
    final button = Container(
      width: fullWidth ? double.infinity : 150,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: themeColor),
        borderRadius: BorderRadius.circular(15),
        color: isFilled ? themeColor : Colors.white,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isFilled ? Colors.white : themeColor,
          ),
        ),
      ),
    );

    return fullWidth
        ? Expanded(child: GestureDetector(onTap: onPressed, child: button))
        : GestureDetector(onTap: onPressed, child: button);
  }
}
