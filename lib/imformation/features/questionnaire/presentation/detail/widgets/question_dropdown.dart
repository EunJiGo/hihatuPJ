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
    showModalBottomSheet(
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
                // 스크롤 가능한 항목 리스트
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
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFFFFF0F5) : Color(0xFFFDFDFD),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Color(0xFFFFA0C5) : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Colors.pink.shade100.withOpacity(0.4),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.favorite : Icons.favorite_border,
                                color: isSelected ? Colors.pinkAccent : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.pink.shade700 : Colors.black87,
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

                // 🎀 귀여운 취소 버튼
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(50),
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
    final controller = TextEditingController(text: selectedValue ?? '');

    return GestureDetector(
      onTap: answerStatus == 1 ? null : () => _showBottomSheet(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: '選択してください',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }
}
