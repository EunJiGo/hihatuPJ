import 'package:flutter/material.dart';
import 'package:hihatu_project/apply/finance/presentation/sections/widgets/transportation_title_section.dart';

import '../../data/dtos/transportation_item.dart';
import '../widgets/history/transportation_history_list.dart';
import '../widgets/status/status_icon.dart';

class SingleSection extends StatelessWidget {
  const SingleSection({
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
          icon: Icons.directions_bus,
          iconColor: const Color(0xFFFFB74D),
          title: '交通費の申請履歴',
          isExpanded: isExpanded,
          isData: items.isEmpty,
          onToggle: onToggle,
        ),
        if (isExpanded)
          TransportationHistoryList(
            items: items
                .map((e) => TransportationUiItem(
              id: e.id!,
              fromStation: e.fromStation,
              toStation: e.toStation,
              amount: e.amount,
              isCommuter: false,
              twice: e.twice,
              durationStartDate: e.durationStart,
              goals: e.goals,
              submissionStatus: e.submissionStatus,
              reviewStatus: e.reviewStatus,
            ))
                .toList(),
            onTap: (id) => onTapItem(id),
            getStatusIcon: (submission, review) =>
                buildStatusIcon(submissionStatus: submission, reviewStatus: review, animation: animation),
            leadingIcon: Icons.directions_bus,
            leadingIconColor: const Color(0xFFFFB74D),
            amountColor: const Color(0xFFFFB74D),
            separatorIconColor: const Color(0xFFf30101),
          ),
      ],
    );
  }
}
