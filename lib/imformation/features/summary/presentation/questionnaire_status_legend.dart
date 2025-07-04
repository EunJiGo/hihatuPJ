import 'package:flutter/material.dart';

class QuestionnaireStatusLegend extends StatelessWidget {
  const QuestionnaireStatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // 未回答 (미작성)
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 14),
              const SizedBox(width: 4),
              const Text('未作成', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(width: 16),

          // 保存済 (작성 중)
          Row(
            children: [
              Icon(Icons.warning, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              const Text('作成中', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(width: 16),

          // 回答済 (작성 완료)
          Row(
            children: [
              Image.asset(
                'assets/images/information/correct/correct.png',
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 4),
              const Text('作成完了', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
