import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../questionnaire/domain/questionnaire_status.dart';
import '../../questionnaire/state/questionnaire_status_legend_filter_provider.dart.dart';

class QuestionnaireStatusLegend extends ConsumerWidget {
  const QuestionnaireStatusLegend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSet = ref.watch(questionnaireFilterSetProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12,),
      child: Wrap(
        spacing: 12,
        alignment: WrapAlignment.start, // 기본 center
        children: List.generate(statusList.length, (index) {
          final status = statusList[index];
          // final isFilterEmpty = selectedSet.isEmpty;
          // final isSelected = isFilterEmpty || selectedSet.contains(index);
          final isSelected = selectedSet.contains(index);

          return GestureDetector(
            onTap: () {
              final notifier = ref.read(questionnaireFilterSetProvider.notifier);
              final updated = {...notifier.state};
              isSelected ? updated.remove(index) : updated.add(index);
              notifier.state = updated;
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status.icon,
                  size: 18,
                  color: isSelected ? status.color : Colors.black26,
                ),
                const SizedBox(width: 3),
                Text(
                  status.label,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
