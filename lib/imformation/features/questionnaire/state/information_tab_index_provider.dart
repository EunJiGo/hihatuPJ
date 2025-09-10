// information_tab_index_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 0: お知らせ, 1: 安否確認
final informationTabIndexProvider = StateProvider<int>((ref) => 0);
