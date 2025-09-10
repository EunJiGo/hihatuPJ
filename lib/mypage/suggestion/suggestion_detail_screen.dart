import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hihatu_project/base/base_main_screen.dart';
import '../../header/title_header.dart';

// ▼ 네가 만든 모델/API
import 'data/fetch_suggestion_detail.dart'; // fetchSuggestionDetail(int id)
import 'domain/suggestion_detail.dart'; // SuggestionDetail, SuggestionLog, SuggestionReply

class SuggestionFormScreenEx extends ConsumerStatefulWidget {
  final int suggestionId;

  const SuggestionFormScreenEx({required this.suggestionId, super.key});

  @override
  _SuggestionFormScreenExState createState() => _SuggestionFormScreenExState();
}

class _SuggestionFormScreenExState
    extends ConsumerState<SuggestionFormScreenEx> {
  // 상세 모드용 상태
  SuggestionDetail? _detail;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // ✅ 상세 데이터 로드 시작
    _loadDetail(widget.suggestionId);
  }

  Future<void> _loadDetail(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final d = await fetchSuggestionDetail(id);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[_loadDetail] error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = '詳細の読み込みに失敗しました。';
        _loading = false;
      });
    }
  }

  String _extractTitle(String message) =>
      message.trim().split('\n').first.trim();

  String _fmtJst(String iso) {
    try {
      final dt = DateTime.parse(
        iso,
      ).toUtc().add(const Duration(hours: 9)); // JST(+9)
      String two(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case '新着':
        return Colors.blueGrey;
      case '対応中':
        return Colors.orange;
      case '返信済':
        return Colors.blue;
      case '完了':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: BaseMainScreen(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFEFF2F4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바
              Container(
                height: kToolbarHeight - 20,
                color: const Color(0xFFffffff),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        color: const Color(0xffadadad),
                      ),
                    ),
                  ],
                ),
              ),

              WelcomeHeader(
                title: '目安箱詳細',
                subtitle: 'あなたの声がより良い職場をつくります。',
                titleFontSize: 18,
                subtitleFontSize: 12,
                imagePath:
                    'assets/images/mypage/suggest/suggest_image/suggest_image.png',
                imageWidth: 110,
              ),

              // 본문
              Expanded(child: _buildDetailBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- 상세 보기 ----------
  Widget _buildDetailBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    // 아직 로드 전
    if (_detail == null) {
      return const SizedBox.shrink();
    }

    final d = _detail!;
    final title = _extractTitle(d.message);
    final createdAt = d.createdAt;
    final status = d.status;
    final page = d.page ?? 'その他';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // // 카드 1: 기본 정보
          // _card(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       _metaRow(
          //         '📅 作成日',
          //         createdAt.isEmpty ? '-' : _fmtJst(createdAt),
          //       ),
          //       const SizedBox(height: 8),
          //       Row(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           const Text(
          //             '📌 状態',
          //             style: TextStyle(
          //               fontSize: 14,
          //               fontWeight: FontWeight.w700,
          //             ),
          //           ),
          //           const SizedBox(width: 8),
          //           Text(status),
          //
          //           // Chip(
          //           //   label: Text(status),
          //           //   backgroundColor: _statusColor(status).withOpacity(0.12),
          //           //   labelStyle: TextStyle(
          //           //     color: _statusColor(status),
          //           //     fontWeight: FontWeight.w600,
          //           //   ),
          //           //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //           //   padding: EdgeInsets.zero,
          //           // ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 12),

          // 카드 2: 제목, 카테고리, 내용
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const Text(
                //   '🏷 カテゴリ',
                //   style: TextStyle(fontWeight: FontWeight.w700),
                // ),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/add/calendar.png', // 본인 이미지로 변경
                      width: 15,
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      '作成日',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    _fmtJst(createdAt),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const SizedBox(width: 10),
                //     Container(
                //       width: 6,
                //       height: 6,
                //       margin: const EdgeInsets.only(top: 6),
                //       decoration: BoxDecoration(
                //         color: Colors.grey,
                //         shape: BoxShape.circle,
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     Text(page),
                //   ],
                // ),
                // Wrap(
                //   children: [
                //     Chip(
                //       label: Text(page),
                //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //     ),
                //   ],
                // ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/add/content.png',
                      width: 15,
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      '内容',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    d.message.isEmpty ? '-' : d.message,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 12),
          //
          // // 카드 3: 처리 이력 Logs
          // _card(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       const Text(
          //         '📝 処理履歴',
          //         style: TextStyle(fontWeight: FontWeight.w700),
          //       ),
          //       const SizedBox(height: 8),
          //       if (d.logs.isEmpty)
          //         const Text('ログはありません。', style: TextStyle(color: Colors.grey))
          //       else
          //         ...d.logs.map((e) {
          //           final color = (e.type == 'success')
          //               ? Colors.green
          //               : Colors.blueGrey;
          //           return Padding(
          //             padding: const EdgeInsets.only(bottom: 6),
          //             child: Row(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 const SizedBox(width: 10),
          //                 Container(
          //                   width: 6,
          //                   height: 6,
          //                   margin: const EdgeInsets.only(top: 6),
          //                   decoration: BoxDecoration(
          //                     color: color,
          //                     shape: BoxShape.circle,
          //                   ),
          //                 ),
          //                 const SizedBox(width: 8),
          //                 Expanded(
          //                   child: RichText(
          //                     text: TextSpan(
          //                       style: const TextStyle(
          //                         color: Colors.black87,
          //                         fontSize: 13,
          //                       ),
          //                       children: [
          //                         TextSpan(
          //                           text: e.time.isEmpty
          //                               ? ''
          //                               : '${_fmtJst(e.time)}  ',
          //                           style: const TextStyle(color: Colors.grey),
          //                         ),
          //                         TextSpan(text: e.text),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           );
          //         }),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 12),
          //
          // // 카드 4: Replies
          // _card(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       const Text(
          //         '💬 返信',
          //         style: TextStyle(fontWeight: FontWeight.w700),
          //       ),
          //       const SizedBox(height: 8),
          //       if (d.replies.isEmpty)
          //         const Text('返信はありません。', style: TextStyle(color: Colors.grey))
          //       else
          //         ...d.replies.map((r) {
          //           return Container(
          //             margin: const EdgeInsets.only(bottom: 8),
          //             padding: const EdgeInsets.all(12),
          //             decoration: BoxDecoration(
          //               color: Colors.grey.shade100,
          //               borderRadius: BorderRadius.circular(10),
          //             ),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Row(
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: [
          //                     Text(
          //                       '作成者：${r.replier}',
          //                       style: const TextStyle(
          //                         fontWeight: FontWeight.w600,
          //                       ),
          //                     ),
          //                     Text(
          //                       r.repliedAt.isEmpty ? '' : _fmtJst(r.repliedAt),
          //                       style: const TextStyle(
          //                         color: Colors.grey,
          //                         fontSize: 12,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 const SizedBox(height: 6),
          //                 Text(r.content),
          //               ],
          //             ),
          //           );
          //         }),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 15),
        ],
      ),
    );
  }

  // 공통 카드 UI
  Widget _card({required Widget child}) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
