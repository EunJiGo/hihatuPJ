import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/imformation/features/questionnaire/domain/questionnaire_status.dart';
import 'package:hihatu_project/imformation/features/questionnaire/state/questionnaire_status_legend_filter_provider.dart';

class QuestionnaireStatusLegend extends ConsumerWidget {
  const QuestionnaireStatusLegend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSet = ref.watch(questionnaireFilterSetProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10,),
      child: Wrap(
        spacing: 12,
        alignment: WrapAlignment.end, // 기본 center
        children: List.generate(statusList.length, (index) {
          final status = statusList[index];
          final isSelected = selectedSet.contains(index);

          return GestureDetector(
            onTap: () {
              final notifier = ref.read(questionnaireFilterSetProvider.notifier);
              final updated = {...notifier.state};
              isSelected ? updated.remove(index) : updated.add(index);
              notifier.state = updated;
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              // padding: const EdgeInsets.symmetric(verticalvertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // border: Border.all(
                //   color: isSelected ? status.color : Colors.black26,
                //   width: 1,
                // ),
                color: isSelected ? status.backgroundColor : null,
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status.icon,
                    size: 14,
                    color: isSelected ? status.color : Colors.black26,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    status.label,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
