import 'package:flutter/material.dart';
import '../sections/commute_section.dart';
import '../sections/single_section.dart';
import '../sections/remote_section.dart';
import '../sections/other_section.dart';
import '../transportation/state/transportation_view_model.dart';

class SectionsView extends StatelessWidget {
  const SectionsView({
    super.key,
    required this.vm,
    required this.scrollController,
    required this.flags,
    required this.onToggle,
    required this.onTapHandlers,
    required this.animation,
    required this.ensureSummaryVisibleIfCantScroll,
  });

  final TransportationVM vm;
  final ScrollController scrollController;
  final ({bool commute, bool single, bool remote, bool other}) flags;
  final void Function(String key, bool value) onToggle;
  final ({
  Future<void> Function(String id) commute,
  Future<void> Function(String id) single,
  Future<void> Function(String id) remote,
  Future<void> Function(String id) other,
  }) onTapHandlers;
  final Animation<double> animation;
  final VoidCallback ensureSummaryVisibleIfCantScroll;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.commute.isNotEmpty)
              CommuteSection(
                items: vm.commute,
                isExpanded: flags.commute,
                onToggle: () {
                  onToggle('commute', !flags.commute);
                  ensureSummaryVisibleIfCantScroll();
                },
                onTapItem: onTapHandlers.commute,
                animation: animation,
              ),
            if (vm.single.isNotEmpty)
              SingleSection(
                items: vm.single,
                isExpanded: flags.single,
                onToggle: () {
                  onToggle('single', !flags.single);
                  ensureSummaryVisibleIfCantScroll();
                },
                onTapItem: onTapHandlers.single,
                animation: animation,
              ),
            if (vm.remoteList.isNotEmpty)
              RemoteSection(
                items: vm.remoteList,
                isExpanded: flags.remote,
                onToggle: () {
                  onToggle('remote', !flags.remote);
                  ensureSummaryVisibleIfCantScroll();
                },
                onTapItem: onTapHandlers.remote,
                animation: animation,
              ),
            if (vm.others.isNotEmpty)
              OtherSection(
                items: vm.others,
                isExpanded: flags.other,
                onToggle: () {
                  onToggle('other', !flags.other);
                  ensureSummaryVisibleIfCantScroll();
                },
                onTapItem: onTapHandlers.other,
                animation: animation,
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
