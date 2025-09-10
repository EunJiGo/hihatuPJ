// lib/calendar/ui/scope/calendar_scope_bar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hihatu_project/calendar/styles.dart';
import 'calendar_scope.dart';

class CalendarScopeBar extends StatelessWidget {
  const CalendarScopeBar({
    super.key,
    required this.items,
    required this.onToggleMe,
    required this.onTapPlus,
    required this.onRemoveItem,
  });

  final List<CalendarScopeItem> items;
  final VoidCallback onToggleMe;
  final VoidCallback onTapPlus;
  final void Function(CalendarScopeItem item) onRemoveItem;

  static const double _kChipH = 45;   // ✅ 원하는 고정 높이(40 추천). 36로 원하면 36으로.
  static const double _kRadius = 18;
  static const double _kGap = 8;

  @override
  Widget build(BuildContext context) {
    // final visible = items.where((e) => e.enabled).toList();
    final others = items
        .where((e) => e.enabled && e.type != ScopeType.me) // ← me 제외
        .toList();
    final meOn = items.any((e) => e.type == ScopeType.me && e.enabled);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: _kChipH,
      color: iosBg.withValues(alpha: 0.7),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // ── 自分 칩 (그대로) ──
          SizedBox(
            height: _kChipH,
            child: _chip(
              label: '自分',
              colors: _colorsFor(ScopeType.me, active: meOn),
              onTap: onToggleMe,
              leading: const Icon(CupertinoIcons.person, size: 13, color: iosLabel),
            ),
          ),
          const SizedBox(width: _kGap),

          // ── 사람/설비 칩 목록: me를 뺀 others 사용 ──
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: others.length, // ← others
              separatorBuilder: (_, __) => const SizedBox(width: _kGap),
              itemBuilder: (_, i) {
                final it = others[i];   // ← others
                return SizedBox(
                  height: _kChipH,
                  child: _chip(
                    label: it.label,
                    colors: _colorsFor(it.type, active: true),
                    trailing: GestureDetector(
                      onTap: () => onRemoveItem(it),
                      child: const SizedBox(
                        width: 16, height: 16,
                        child: Icon(Icons.close, size: 13, color: iosSecondary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: _kGap),

          // ＋ (고정 높이)
          GestureDetector(
            onTap: onTapPlus,
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(height: _kChipH),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kRadius),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Center(child: Icon(CupertinoIcons.add, color: iosBlue, size: 18)),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // --- 동일: _chip / _colorsFor / _ChipColors -------------------------------

  Widget _chip({
    required String label,
    required _ChipColors colors,
    VoidCallback? onTap,
    Widget? leading,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_kRadius),
      child: Container(
        // 높이는 SizedBox에서 강제하므로 여기선 좌우 패딩만
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(_kRadius),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              SizedBox(width: 16, height: 16, child: Center(child: leading)),
              const SizedBox(width: 1),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.fg),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 1),
              SizedBox(width: 16, height: 16, child: Center(child: trailing)),
            ],
          ],
        ),
      ),
    );
  }

  _ChipColors _colorsFor(ScopeType t, {required bool active}) {
    switch (t) {
      case ScopeType.me:
        return _ChipColors(
          bg: iosBlue.withValues(alpha: active ? .12 : .06),
          fg: iosLabel.withValues(alpha: active ? 1 : .5),
          border: iosBlue.withValues(alpha: active ? .25 : .06),
        );
      case ScopeType.person:
        return _ChipColors(
          bg: Colors.greenAccent.withValues(alpha: .20),
          fg: Colors.green[800]!,
          border: Colors.green.withValues(alpha: .40),
        );
      case ScopeType.equipment:
        return _ChipColors(
          bg: Colors.grey.withValues(alpha: .30),
          fg: Colors.black87,
          border: Colors.grey[400]!,
        );
    }
  }
}

class _ChipColors {
  final Color bg, fg, border;
  const _ChipColors({required this.bg, required this.fg, required this.border});
}

