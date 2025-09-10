import 'package:flutter/material.dart';
import '../../../../utils/dialog/confirmation_dialog.dart';

class CommonSubmitButtons extends StatelessWidget {
  final VoidCallback? onSavePressed; // null
  final VoidCallback? onSubmitPressed;

  final String saveText;
  final String submitText;

  /// [일관화 포인트1] 동적 확인 메시지: 우선 적용
  final String? Function(BuildContext context)? saveConfirmBuilder;
  final String? Function(BuildContext context)? submitConfirmBuilder;

  /// 레거시: 문자열 고정 메시지 (빌더 없을 때 fallback)
  final String? saveConfirmMessage;
  final String? submitConfirmMessage;

  final double padding;
  final Color themeColor;

  final bool showSaveButton;
  final bool showSubmitButton; // ture

  final bool activeSubmitButton;

  const CommonSubmitButtons({
    super.key,
    this.onSavePressed,
    this.onSubmitPressed,
    this.saveText = '保　　存',
    this.submitText = '提　　出',
    this.saveConfirmBuilder,
    this.submitConfirmBuilder,
    this.saveConfirmMessage,
    this.submitConfirmMessage,
    this.padding = 0.0,
    this.themeColor = const Color(0xFF0253B3),
    this.showSaveButton = true,
    this.showSubmitButton = true,
    this.activeSubmitButton = true,
  });

  Future<void> _handleAction(BuildContext context, String type) async {
    final VoidCallback? callback = (type == 'save') ? onSavePressed : onSubmitPressed;
    if (callback == null) return;

    // [일관화 포인트2] 확인 메시지 결정(빌더 > 메시지 > 없음)
    final String? message = (type == 'save')
        ? (saveConfirmBuilder?.call(context) ?? saveConfirmMessage)
        : (submitConfirmBuilder?.call(context) ?? submitConfirmMessage);

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
    final wantsSave = showSaveButton && onSavePressed != null;
    final wantsSubmit = showSubmitButton && onSubmitPressed != null;
    final count = (wantsSave ? 1 : 0) + (wantsSubmit ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();

    final isSingle = count == 1;
    final buttons = <Widget>[];

    if (wantsSave) {
      buttons.add(_buildButton(
        label: saveText,
        isFilled: isSingle ? true : false, // 단독이면 채우기
        onPressed: () => _handleAction(context, 'save'),
        fullWidth: isSingle,
        enabled: true, // 필요하면 activeSaveButton 도입
      ));
    }

    // if (wantsSave && wantsSubmit) {
    //   buttons.add(const SizedBox(width: 12)); // 고정 간격 권장
    // }

    if (wantsSubmit) {
      buttons.add(_buildButton(
        label: submitText,
        isFilled: true,
        onPressed: activeSubmitButton ? () => _handleAction(context, 'submit') : null,
        fullWidth: isSingle,
        enabled: activeSubmitButton,
      ));
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: buttons.length == 1 ? [buttons.first] : buttons,
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isFilled,
    required VoidCallback? onPressed,
    required bool fullWidth,
    required bool enabled,
  }) {
    final button = Container(
      width: fullWidth ? double.infinity : 150,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: enabled ? themeColor : Color(0xffbababa)),
        borderRadius: BorderRadius.circular(15),
        color: isFilled ? (enabled ? themeColor : Color(0xffcccccc)) : Colors.white,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: isFilled ? Colors.white : (enabled ? themeColor : Colors.grey),
          ),
        ),
      ),
    );

    final buttonWidget = GestureDetector(
      onTap: enabled ? onPressed : null, // 비활성화 시 클릭 안됨
      child: button,
    );

    return fullWidth ? Expanded(child: buttonWidget) : buttonWidget;
  }
}
