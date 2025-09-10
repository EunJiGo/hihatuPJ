import 'package:flutter/material.dart';
import 'package:hihatu_project/apply/finance/presentation/sections/widgets/transportation_title_section.dart';

import '../../data/dtos/transportation_item.dart';
import '../widgets/history/transportation_history_list.dart';
import '../widgets/status/status_icon.dart';

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
  final Future<void> Function(int id) onTapItem;
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
                    durationStartDate: e.durationStart,
                    durationEndDate: e.durationEnd,
                    commuteDuration: e.commuteDuration,
                    submissionStatus: e.submissionStatus,
                    reviewStatus: e.reviewStatus,
                  ),
                )
                .toList(),
            onTap: (id) => onTapItem(id),
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
