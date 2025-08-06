import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧍 상단 : 사진 + 기본정보
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 이미지 (프로필 사진 자리)
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'assets/images/add/profile.webp', // 본인 이미지로 변경
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // 이름 + 상세
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '山本 修輔',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '男　日本　27歳',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Text(
                    '番号：080-3332-3334',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 구분선
          const Divider(height: 1, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 12),

          // 🔧 상세 정보
          const InfoRow(icon: Icons.build, label: 'スキル', value: 'Java（A）、C#（A）'),
          InfoRow(icon: Icons.school, label: '資格', value: 'JLPT N1、TOEIC'),
          InfoRow(icon: Icons.work, label: '経歴', value: '8年'),
          InfoRow(icon: Icons.apartment, label: '所属部署', value: '技術部'),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Color(0xFF333333)),
          const SizedBox(width: 8),
          Text(
            '$label：',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
