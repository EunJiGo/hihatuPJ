import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dtos/transportation_item.dart';
import '../state/transportation_provider.dart';

class TransportationVM {
  TransportationVM(this.items);

  final List<TransportationItem> items;

  List<TransportationItem> get commute =>
      items.where((e) => e.expenseType == 'commute').toList();

  List<TransportationItem> get single =>
      items.where((e) => e.expenseType == 'single').toList();

  List<TransportationItem> get remoteList =>
      items.where((e) => e.expenseType == 'home_office_expenses').toList();

  List<TransportationItem> get others =>
      items.where((e) => e.expenseType == 'travel').toList();

  int get commuteTotal => commute.fold(0, (s, e) => s + e.amount);
  int get singleTotal  => single.fold(0, (s, e) => s + e.amount);
  int get remoteTotal  => (remoteList.isNotEmpty ? remoteList.first.amount : 0);
  int get othersTotal  => others.fold(0, (s, e) => s + e.amount);

  int get grandTotal => commuteTotal + singleTotal + remoteTotal + othersTotal;

  bool get hasAny =>
      commute.isNotEmpty || single.isNotEmpty || remoteList.isNotEmpty || others.isNotEmpty;
}

// Family: month별로 VM 생성
final transportationVMProvider = Provider.family<TransportationVM, DateTime>((ref, month) {
  final async = ref.watch(transportationProvider(month));
  final data = async.asData?.value ?? const <TransportationItem>[];
  return TransportationVM(data);
});
