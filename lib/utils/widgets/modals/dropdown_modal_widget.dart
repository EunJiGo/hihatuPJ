import 'package:flutter/material.dart';

class DropdownModalWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final void Function(String) onSelected;

  final Color selectedTextColor;
  final Color selectedIconColor;
  final Color selectedBorderColor;
  final Color selectedBackgroundColor;

  const DropdownModalWidget({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    required this.selectedTextColor,
    required this.selectedIconColor,
    required this.selectedBorderColor,
    required this.selectedBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, index) {
        final opt = options[index];
        final bool isSelected = opt == selectedValue;

        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onSelected(opt);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? selectedBackgroundColor : const Color(0xFFF7FAFC),
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
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? selectedIconColor : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? selectedTextColor : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
