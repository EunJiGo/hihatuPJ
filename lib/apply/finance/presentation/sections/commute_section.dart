import 'package:flutter/material.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_history_list.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/transportation_title_section.dart';
import 'package:hihatu_project/apply/transportations/summary/widgets/status_icon.dart';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_item.dart';

class CommuteSection extends StatelessWidget {
  const CommuteSection({
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
          icon: Icons.confirmation_number,
          iconColor: const Color(0xFF81C784),
          title: '定期券の申請履歴',
          isExpanded: isExpanded,
          isData: items.isEmpty,
          onToggle: onToggle,
        ),
        if (isExpanded)
          TransportationHistoryList(
            items: items
                .map(
                  (e) => TransportationUiItem(
                id: e.id!,
                fromStation: e.fromStation,
                toStation: e.toStation,
                amount: e.amount,
                isCommuter: true,
                twice: false,
                updatedAt: e.updatedAt,
                commuteDuration: e.commuteDuration,
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
            leadingIcon: Icons.confirmation_number,
            leadingIconColor: const Color(0xFF81C784),
            amountColor: const Color(0xFF81C784),
            separatorIconColor: Colors.black54,
          ),
      ],
    );
  }
}
