// 제출/저장 버튼 UI
import 'package:flutter/material.dart';

class QuestionSubmitButtons extends StatelessWidget {
  final VoidCallback onSavePressed;
  final VoidCallback onSubmitPressed;

  const QuestionSubmitButtons({
    super.key,
    required this.onSavePressed,
    required this.onSubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: onSavePressed,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF0253B3),),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                width: 150,
                height: 50,
                child: const Center(
                  child: Text('保　　存', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0253B3),)),
                ),
              ),
            ),
            GestureDetector(
              onTap: onSubmitPressed,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF0253B3),),
                  borderRadius: BorderRadius.circular(15),
                    color: Color(0xFF0253B3),
                ),
                width: 150,
                height: 50,
                child: const Center(
                  child: Text('提　　出', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
