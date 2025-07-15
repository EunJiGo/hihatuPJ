import 'package:flutter/material.dart';

class QuestionDropdown extends StatelessWidget {
  final List<String> options;
  final int answerStatus;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const QuestionDropdown({
    super.key,
    required this.options,
    required this.answerStatus,
    required this.selectedValue,
    required this.onChanged,
  });

  void _showBottomSheet(BuildContext context) {
    if (answerStatus == 1) return; // 제출완료면 열리지 않게

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return GestureDetector (
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final opt = options[index];
                        final bool isSelected = opt == selectedValue;

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            onChanged(opt);
                            FocusScope.of(context).unfocus();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFFE3F2FD)
                                      : const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFF64B5F6)
                                        : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: Colors.blue.shade100.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color:
                                      isSelected
                                          ? Colors.blueAccent
                                          : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? const Color(0xFF1565C0)
                                              : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    },
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: selectedValue ?? '');

    // 회색/비활성 느낌 색상
    final isDisabled = answerStatus == 1;

    return GestureDetector(
      onTap:
          isDisabled
              ? () {
                FocusScope.of(context).unfocus();
              }
              : () {
                FocusScope.of(context).unfocus();
                Future.delayed(Duration(milliseconds: 50), () {
                  _showBottomSheet(context); // 약간 늦게 띄우기
                });
              },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            color: isDisabled ? Colors.grey.shade500 : Colors.black87,
          ),
          decoration: InputDecoration(
            labelText: '選択してください',
            labelStyle: TextStyle(
              color: isDisabled ? Colors.grey : const Color(0xFF1565C0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    isDisabled ? Colors.grey.shade400 : const Color(0xFF90CAF9),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    isDisabled ? Colors.grey.shade400 : const Color(0xFF42A5F5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: isDisabled ? Colors.grey : const Color(0xFF1565C0),
            ),
            filled: true,
            fillColor:
                isDisabled ? Colors.grey.shade200 : const Color(0xFFF0F7FF),
          ),
        ),
      ),
    );
  }
}
