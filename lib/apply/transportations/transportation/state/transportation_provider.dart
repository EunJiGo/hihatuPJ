import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/transportations/transportation/data/fetch_transportation.dart';
import 'package:hihatu_project/apply/transportations/transportation/domain/transportation_item.dart';

import '../data/fetch_transportation_detail.dart';
import '../domain/TransportationDetailResponse.dart';


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

// id를 입력받으면 해당 교통비 or 정기권 정보를 취득할 수 있는 프로바이더
final transportationDetailProvider = FutureProvider.family
    .autoDispose<TransportationItem, int>((ref, id) async {
  final response = await fetchTransportationDetail(id);
  return response.data; // 이제 타입 일치!
});


