import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/styles.dart';
import '../../../../../../utils/widgets/common_submit_buttons.dart';

class ExpenseActionBarSection extends StatelessWidget {
  const ExpenseActionBarSection({
    super.key,
    required this.onSavePressed,
    required this.onDeletePressed,
    required this.canShowSave,
    required this.canShowDelete,
    this.saveConfirmMessage = '保存しますか？',
    this.deleteConfirmMessage = '削除しますか？',
    this.deleteText = '削　　除',
    this.themeColor = const Color(0xFF0253B3),
    this.padding = 0.0,
  });

  /// Commuter(정기券) 전용 프리셋
  factory ExpenseActionBarSection.commuter({
    Key? key,
    required VoidCallback onSavePressed,
    required VoidCallback onDeletePressed,
    required bool canShowSave,
    required bool canShowDelete,
    String saveConfirmMessage = '定期券を保存しますか？',
    String deleteConfirmMessage = '定期券を削除しますか？',
    String deleteText = '削　　除',
    Color themeColor = const Color(0xFF0253B3),
    double padding = 0.0,
  }) {
    return ExpenseActionBarSection(
      key: key,
      onSavePressed: onSavePressed,
      onDeletePressed: onDeletePressed,
      canShowSave: canShowSave,
      canShowDelete: canShowDelete,
      saveConfirmMessage: saveConfirmMessage,
      deleteConfirmMessage: deleteConfirmMessage,
      deleteText: deleteText,
      themeColor: themeColor,
      padding: padding,
    );
  }

  /// Single(교통비) 전용 프리셋
  factory ExpenseActionBarSection.single({
    Key? key,
    required VoidCallback onSavePressed,
    required VoidCallback onDeletePressed,
    required bool canShowSave,
    required bool canShowDelete,
    String saveConfirmMessage = '交通費を保存しますか？',
    String deleteConfirmMessage = '交通費を削除しますか？',
    String deleteText = '削　　除',
    Color themeColor = const Color(0xFF0253B3),
    double padding = 0.0,
  }) {
    return ExpenseActionBarSection(
      key: key,
      onSavePressed: onSavePressed,
      onDeletePressed: onDeletePressed,
      canShowSave: canShowSave,
      canShowDelete: canShowDelete,
      saveConfirmMessage: saveConfirmMessage,
      deleteConfirmMessage: deleteConfirmMessage,
      deleteText: deleteText,
      themeColor: themeColor,
      padding: padding,
    );
  }

  /// Single(교통비) 전용 프리셋
  factory ExpenseActionBarSection.otherExpense({
    Key? key,
    required VoidCallback onSavePressed,
    required VoidCallback onDeletePressed,
    required bool canShowSave,
    required bool canShowDelete,
    String saveConfirmMessage = '立替金を保存しますか？',
    String deleteConfirmMessage = '立替金を削除しますか？',
    String deleteText = '削　　除',
    Color themeColor = const Color(0xFF0253B3),
    double padding = 0.0,
  }) {
    return ExpenseActionBarSection(
      key: key,
      onSavePressed: onSavePressed,
      onDeletePressed: onDeletePressed,
      canShowSave: canShowSave,
      canShowDelete: canShowDelete,
      saveConfirmMessage: saveConfirmMessage,
      deleteConfirmMessage: deleteConfirmMessage,
      deleteText: deleteText,
      themeColor: themeColor,
      padding: padding,
    );
  }

  /// Remote(在宅勤務手当) 전용 프리셋
  factory ExpenseActionBarSection.remote({
    Key? key,
    required VoidCallback onSavePressed,
    required VoidCallback onDeletePressed,
    required bool canShowSave,
    required bool canShowDelete,
    String saveConfirmMessage = '在宅勤務手当を保存しますか？',
    String deleteConfirmMessage = '在宅勤務手当を削除しますか？',
    String deleteText = '削　　除',
    Color themeColor = const Color(0xFF0253B3),
    double padding = 0.0,
  }) {
    return ExpenseActionBarSection(
      key: key,
      onSavePressed: onSavePressed,
      onDeletePressed: onDeletePressed,
      canShowSave: canShowSave,
      canShowDelete: canShowDelete,
      saveConfirmMessage: saveConfirmMessage,
      deleteConfirmMessage: deleteConfirmMessage,
      deleteText: deleteText,
      themeColor: themeColor,
      padding: padding,
    );
  }

  // 삭제 전용 팩토리 (캘린더 일정)
  factory ExpenseActionBarSection.calendarDeleteOnly({
    Key? key,
    required VoidCallback onDeletePressed,
    String deleteConfirmMessage = '予定を削除しますか？',
    String deleteText = '削　除',
    Color themeColor = iosBlue,
    double padding = 0.0,
  }) {
    return ExpenseActionBarSection(
      key: key,
      onSavePressed: _noop,        // 더미
      onDeletePressed: onDeletePressed,
      canShowSave: false,          // Save 숨김
      canShowDelete: true,         // Delete만 표시
      saveConfirmMessage: '',
      deleteConfirmMessage: deleteConfirmMessage,
      deleteText: deleteText,
      themeColor: themeColor,
      padding: padding,
    );
  }

  static void _noop() {}

  final VoidCallback onSavePressed;
  final VoidCallback onDeletePressed;
  final bool canShowSave;
  final bool canShowDelete;

  final String saveConfirmMessage;
  final String deleteConfirmMessage;
  final String deleteText;
  final Color themeColor;
  final double padding;


  @override
  Widget build(BuildContext context) {
    return CommonSubmitButtons(
      onSavePressed: onSavePressed,
      onSubmitPressed: canShowDelete ? onDeletePressed : null,
      submitText: deleteText,
      saveConfirmMessage: saveConfirmMessage,
      submitConfirmMessage: deleteConfirmMessage,
      showSubmitButton: canShowDelete,
      showSaveButton: canShowSave,
      themeColor: themeColor,
      padding: padding,
    );
  }
}


