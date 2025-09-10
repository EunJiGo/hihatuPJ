import 'package:flutter/material.dart';

import 'package:hihatu_project/utils/widgets/checkbox_list_widget.dart';

class QuestionCheckboxList extends StatelessWidget {
  final List<String> options;
  final int answerStatus;
  final List<String?> checkedValues;
  final void Function(List<String?>) onChanged;

  const QuestionCheckboxList({
    super.key,
    required this.options,
    required this.answerStatus,
    required this.checkedValues,
    required this.onChanged,
  });

  Widget build(BuildContext context) {
    final isDisabled = answerStatus == 1;

    return SelectableCheckboxList(
      options: options,
      checkedValues: checkedValues,
      onChanged: onChanged,
      isDisabled: isDisabled,
      selectedBackgroundColor: const Color(0xFFF0F7FF),
      selectedBorderColor: const Color(0xFF6096D0),
      // selectedBorderColor: const Color(0xFF90CAF9),
      selectedIconColor: const Color(0xFF6096D0),
      selectedTextColor: const Color(0xFF6096D0),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final isDisabled = answerStatus == 1;
  //
  //   return Column(
  //     children: options.asMap().entries.map((entry) {
  //       final optIndex = entry.key;
  //       final opt = entry.value;
  //       final checkedList = List<String?>.from(checkedValues);
  //       final isChecked = checkedList[optIndex] != null;
  //
  //       return GestureDetector(
  //         onTap: isDisabled
  //             ? null
  //             : () {
  //           checkedList[optIndex] = isChecked ? null : opt;
  //           onChanged(List.from(checkedList));
  //         },
  //         child: AnimatedContainer(
  //           duration: const Duration(milliseconds: 200),
  //           margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
  //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //           decoration: BoxDecoration(
  //             color: isDisabled
  //                 ? Colors.grey.shade200
  //                 : isChecked
  //                 ? const Color(0xFFF0F7FF)
  //                 // ? const Color(0xFFE3F2FD)
  //                 : const Color(0xFFF9FBFC),
  //             borderRadius: BorderRadius.circular(14),
  //             border: Border.all(
  //               color: isDisabled
  //                   ? Colors.grey.shade400
  //                   : isChecked
  //                   ? const Color(0xFF90CAF9)
  //                   : Colors.grey.shade300,
  //               width: isChecked ? 1.5: 1,
  //             ),
  //             boxShadow: isChecked && !isDisabled
  //                 ? [
  //               BoxShadow(
  //                 color: Colors.blue.withOpacity(0.2),
  //                 blurRadius: 5,
  //                 offset: const Offset(0, 3),
  //               )
  //             ]
  //                 : [],
  //           ),
  //           child: Row(
  //             children: [
  //               Icon(
  //                 isChecked
  //                     ? Icons.check_box_rounded
  //                     : Icons.check_box_outline_blank_rounded,
  //                 color: isDisabled
  //                     ? Colors.grey.shade400
  //                     : isChecked
  //                     ? const Color(0xFF6096D0)
  //                     : Colors.grey,
  //               ),
  //               const SizedBox(width: 10),
  //               Expanded(
  //                 child: Text(
  //                   opt,
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     color: isDisabled
  //                         ? Colors.grey
  //                         : isChecked
  //                         ? const Color(0xFF6096D0)
  //                         : Colors.black87,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }
}
