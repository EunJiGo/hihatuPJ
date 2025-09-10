import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/fetch_transportation.dart';
import '../data/dtos/transportation_item.dart';

class TransportationNotifier extends StateNotifier<AsyncValue<List<TransportationItem>>> {
  TransportationNotifier(this.ref, this.date) : super(const AsyncLoading()) {
    _fetchData();
  }

  final Ref ref;
  final DateTime date;

  Future<void> _fetchData() async {
    try {
      final data = await fetchTransportation(date.year, date.month);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await _fetchData();
  }
}

final transportationNotifierProvider = StateNotifierProvider.family<
    TransportationNotifier,
    AsyncValue<List<TransportationItem>>,
    DateTime>((ref, date) {
  return TransportationNotifier(ref, date);
});
