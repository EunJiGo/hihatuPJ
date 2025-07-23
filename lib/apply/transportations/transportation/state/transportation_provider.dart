import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/transportations/transportation/data/fetch_transportation.dart';
import 'package:hihatu_project/apply/transportations/transportation/domian/transportation_item.dart';


// API 호출을 위한 FutureProvider

// 객체 타입
// final transportationProvider = FutureProvider<TransportationItem>((ref) async {
//   return await fetchTransportation();
// });

// 리스트 타입
// final transportationProvider = FutureProvider<List<TransportationItem>>((ref) async {
//   return await fetchTransportation(); // 이 함수가 List<TransportationItem>을 반환한다고 가정
// });

// 서버에 같이 전달할 파라미터가 추가됨
final transportationProvider = FutureProvider.family<List<TransportationItem>, DateTime>((ref, date) async {
  return await fetchTransportation(date.year, date.month);
});


