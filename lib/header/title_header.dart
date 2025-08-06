import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleFontSize;
  final double subtitleFontSize;
  final String imagePath;

  const WelcomeHeader({ //WelcomeHeaderWidget??
    super.key,
    required this.title,
    required this.subtitle,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: const Color(0xFF0253B3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w400,

                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          Image.asset(
            imagePath,
            height: 100,
            width: 110,
          ),
        ],
      ),
    );
  }
}
