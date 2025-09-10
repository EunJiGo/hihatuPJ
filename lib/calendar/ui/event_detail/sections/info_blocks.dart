import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hihatu_project/calendar/domain/calendar_single.dart';
import 'package:hihatu_project/calendar/styles.dart';
import 'chips.dart';

// 상세, 작성자, 설비, 참가자, URL, 장소
class InfoBlocks extends StatelessWidget {
  const InfoBlocks({super.key, required this.event});
  final CalendarSingle event;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final equipments = event.equipments
        .map((e) => (e['name'] as String?)?.trim())
        .where((e) => (e != null && e.isNotEmpty))
        .cast<String>()
        .toList();

    final attendees = event.people
        .map((e) => (e['name'] as String?)?.trim())
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, thickness: 1, color: Colors.black12),
        const SizedBox(height: 10),

        if (event.details.trim().isNotEmpty) ...[
          LabeledBlock(
            title: '詳細内容',
            icon: Icons.notes,
            child: SelectableText(
              event.details.trim(),
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        ],

        if (event.createdByName.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          LabeledBlock(
            title: '作成者',
            icon: Icons.person,
            child: personChip(
              event.createdByName,
              avatarBg: iosBlue.withValues(alpha: .18),
              avatarFg: iosBlue,
              chipBg: Colors.white,
              textColor: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        ],

        if (event.equipments.isNotEmpty) ...[
          const SizedBox(height: 10),
          LabeledBlock(
            title: '会議室 / 設備',
            icon: Icons.meeting_room,
            child: equipments.isEmpty
                ? Text('—', style: text.bodyLarge)
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: equipments
                  .map((name) => Chip(
                label: Text(name, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Colors.black38),
                backgroundColor: Colors.white,
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        ],

        if (attendees.isNotEmpty) ...[
          const SizedBox(height: 10),
          LabeledBlock(
            title: '参加者',
            icon: Icons.group,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: attendees
                  .map((n) => personChip(
                n,
                avatarBg: Colors.greenAccent.withValues(alpha: .18),
                avatarFg: Colors.green,
                chipBg: Colors.white,
                textColor: Colors.black87,
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        ],

        if (event.url != null) ...[
          const SizedBox(height: 10),
          LabeledBlock(
            title: 'URL',
            icon: Icons.link,
            child: _UrlButton(raw: event.url),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        ],

        if (event.place != null) ...[
          const SizedBox(height: 10),
          LabeledBlock(
            title: '場所',
            icon: Icons.place,
            child: Text(
              (event.place?.trim().isEmpty ?? true) ? '—' : event.place!.trim(),
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        ],
      ],
    );
  }
}

class _UrlButton extends StatelessWidget {
  const _UrlButton({required this.raw});
  final String? raw;

  static String? _normalizeUrl(String? u) {
    if (u == null) return null;
    final t = u.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    return 'https://$t';
  }

  @override
  Widget build(BuildContext context) {
    final url = _normalizeUrl(raw);
    if (url == null) return Text('—', style: Theme.of(context).textTheme.bodyLarge);

    return TextButton.icon(
      onPressed: () async {
        final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('リンクを開けません。')));
        }
      },
      icon: const Icon(Icons.open_in_new, size: 15, color: iosBlue),
      label: Text(url, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: iosBlue)),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        alignment: Alignment.centerLeft,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// 기존 _LabeledBlock 그대로 복사
class LabeledBlock extends StatelessWidget {
  const LabeledBlock({required this.title, required this.child, this.icon, this.indent = 5, this.spacing = 3});
  final String title;
  final Widget child;
  final IconData? icon;
  final double indent;
  final double spacing;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ]),
        SizedBox(height: spacing),
        Padding(padding: EdgeInsets.only(left: indent), child: child),
      ],
    );
  }
}
