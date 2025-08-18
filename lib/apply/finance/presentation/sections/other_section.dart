import 'package:flutter/material.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/remote_and_other_history.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_title_section.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/status_icon.dart';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_item.dart';

class OtherSection extends StatelessWidget {
  const OtherSection({
    super.key,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.onTapItem,
    required this.animation,
  });

  final List<TransportationItem> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Future<void> Function(String id) onTapItem;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransportationTitleSection(
          icon: Icons.receipt_long,
          iconColor: const Color(0xFF89e6f4),
          iconSize: 25,
          title: '立替金の申請履歴',
          isExpanded: isExpanded,
          isData: items.isEmpty,
          gap: 8,
          onToggle: onToggle,
        ),
        if (isExpanded)
          RemoteAndOtherItemHistoryList(
            items: items
                .map(
                  (e) => RemoteAndOtherItem(
                id: e.id!,
                isRemote: false,
                amount: e.amount,
                updatedAt: e.updatedAt,
                goals: e.goals,
                submissionStatus: e.submissionStatus,
                reviewStatus: e.reviewStatus,
              ),
            )
                .toList(),
            onTap: (id) => onTapItem('$id'),
            getStatusIcon: (submission, review) => buildStatusIcon(
              submissionStatus: submission,
              reviewStatus: review,
              animation: animation,
            ),
            leadingIcon: Icons.receipt_long,
            leadingIconColor: const Color(0xFF89e6f4),
            amountColor: const Color(0xFF89e6f4),
            separatorIconColor: const Color(0xFFf30101),
          ),
      ],
    );
  }
}
