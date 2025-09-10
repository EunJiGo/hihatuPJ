import 'package:flutter/material.dart';

import '../dropdown_option.dart';

class DropdownModalWidget extends StatelessWidget {
  final List<DropdownOption> options;
  final String? selectedValue;
  final void Function(String) onSelected;
  final bool isSelectCircleIcon;

  final Color selectedTextColor;
  final Color selectedIconColor;
  final Color selectedBorderColor;
  final Color selectedBackgroundColor;

  const DropdownModalWidget({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    required this.isSelectCircleIcon,
    required this.selectedTextColor,
    required this.selectedIconColor,
    required this.selectedBorderColor,
    required this.selectedBackgroundColor,
  });

  static Future<void> show({
    required BuildContext context,
    required List<DropdownOption> options,
    required String? selectedValue,
    required void Function(String) onSelected,
    required bool isSelectCircleIcon,
    Color selectedTextColor = const Color(0xFF1565C0),
    Color selectedIconColor = Colors.blueAccent,
    Color selectedBorderColor = const Color(0xFF64B5F6),
    Color selectedBackgroundColor = const Color(0xFFE3F2FD),
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: DropdownModalWidget(
                    options: options,
                    selectedValue: selectedValue,
                    onSelected: onSelected,
                    isSelectCircleIcon: isSelectCircleIcon,
                    selectedTextColor: selectedTextColor,
                    selectedIconColor: selectedIconColor,
                    selectedBorderColor: selectedBorderColor,
                    selectedBackgroundColor: selectedBackgroundColor,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33FF5252),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text(
                      'キャンセル',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, index) {
        final opt = options[index];
        final bool isSelected = opt.id == selectedValue; // ✅ 여기를 이렇게!

        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onSelected(opt.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedBackgroundColor
                  : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? selectedBorderColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selectedBorderColor.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                if (isSelectCircleIcon == true) ...[
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? selectedIconColor : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(child: opt.display),
              ],
            ),
          ),
        );
      },
    );
  }
}
