import 'package:flutter/material.dart';

class MonthNav extends StatelessWidget {
  const MonthNav({
    super.key,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _gradButton(text: '前月', onTap: onPrev, colors: const [Color(0xFF64B5F6), Color(0xFF1976D2)]),
        Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1976D2))),
        _gradButton(text: '次月', onTap: onNext, colors: const [Color(0xFF1976D2), Color(0xFF64B5F6)]),
      ],
    );
  }

  Widget _gradButton({required String text, required VoidCallback onTap, required List<Color> colors}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
      child: Ink(
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(14)),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 54, minHeight: 26),
          child: Text(text,
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14,
                shadows: [Shadow(offset: Offset(0, 1), blurRadius: 1, color: Colors.black26)],
              )),
        ),
      ),
    );
  }
}
