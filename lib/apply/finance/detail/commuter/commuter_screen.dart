import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/finance/detail/commuter/sections/project_section.dart';
import 'package:hihatu_project/apply/finance/detail/summary/sections/amount_section.dart';
import 'package:hihatu_project/utils/widgets/app_bar/basic_app_bar.dart';
import 'package:hihatu_project/apply/finance/detail/commuter/sections/duration_section.dart';
import 'package:hihatu_project/apply/finance/detail/summary/sections/receipt_section.dart';
import 'package:hihatu_project/apply/finance/detail/summary/sections/start_date_section.dart';
import 'package:hihatu_project/apply/finance/detail/summary/sections/stations_section.dart';
import 'package:hihatu_project/apply/finance/detail/summary/sections/transport_section.dart';
import 'package:hihatu_project/apply/finance/detail/commuter/widgets/commuter_duration.dart';
import 'dart:io';

import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../base/base_main_screen.dart';
import '../../../../header/title_header.dart';
import '../../../../utils/dialog/warning_dialog.dart';
import '../../api/fetch_image_upload.dart';
import '../../api/fetch_transportation_delete.dart';
import '../../api/fetch_transportation_save.dart';
import '../../data/dtos/transportation_save.dart';
import '../../data/dtos/transportation_update.dart';
import '../../presentation/constants/commuter_transport_options.dart';
import '../../presentation/constants/single_transport_options.dart';
import '../../state/transportation_provider.dart';
import '../summary/sections/action_bar_section.dart';
import 'commuter_detail.dart';
import 'data/cummuter_detail_item.dart';

class CommuterScreen extends ConsumerStatefulWidget {
  final int? commuteId;
  final DateTime currentLocalDate;

  const CommuterScreen({this.commuteId, required this.currentLocalDate, super.key});

  @override
  ConsumerState<CommuterScreen> createState() => _CommuterScreenState();
}

class _CommuterScreenState extends ConsumerState<CommuterScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _customTransportController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _transport = '電車';
  String? _customTransport;
  int? _cost;
  String? _imageName;
  File? _imageFile;
  PassDuration _duration = PassDuration.m1;
  String? _submissionStatus;

  bool _isSaving = false;

  bool _hasViaStation = false;
  final List<TextEditingController> _viaCtrls = [];

  String _viaJoined() => _hasViaStation
      ? _viaCtrls
      .map((c) => c.text.trim())
      .where((t) => t.isNotEmpty)
      .join('、')
      : '';

  void _toggleVia(bool v) {
    setState(() {
      _hasViaStation = v;
      if (v) {
        if (_viaCtrls.isEmpty) _addVia(); // 0개였다가 켜지면 1개 추가 (#4)
      } else {
        // 전부 정리
        for (final c in _viaCtrls) { c.dispose(); }
        _viaCtrls.clear();
      }
    });
  }

  void _addVia() {
    setState(() {
      final c = TextEditingController();
      _viaCtrls.add(c);
    });
  }

  void _removeLastVia() {
    setState(() {
      if (_viaCtrls.isEmpty) return;
      _viaCtrls.removeLast().dispose();

      // #3: 1개 남은 상태에서 지우면 전체 비활성
      if (_viaCtrls.isEmpty) {
        _hasViaStation = false;
      }
    });
  }

  // 정기권 종료일 계산 함수
  DateTime _calculatePassEndDate(DateTime start, PassDuration duration) {
    final monthCount = switch (duration) {
      PassDuration.m1 => 1,
      PassDuration.m3 => 3,
      PassDuration.m6 => 6,
    };

    final nextMonthSameDay = DateTime(
      start.year,
      start.month + monthCount,
      start.day,
    );
    return nextMonthSameDay.subtract(const Duration(days: 1)); // 하루 전날까지
  }

  String _mapDurationToString(PassDuration d) {
    switch (d) {
      case PassDuration.m1:
        return '1m';
      case PassDuration.m3:
        return '3m';
      case PassDuration.m6:
        return '6m';
    }
  }

  PassDuration _mapStringToDuration(String d) {
    switch (d) {
      case '1m':
        return PassDuration.m1;
      case '3m':
        return PassDuration.m3;
      case '6m':
        return PassDuration.m6;
      default:
        return PassDuration.m1; // 기본값 설정 (에러 방지)
    }
  }

  List<String> _collectStations() {
    final list = <String>[];
    final dep = _departureController.text.trim();
    final arr = _arrivalController.text.trim();

    if (dep.isNotEmpty) list.add(dep);
    if (_hasViaStation) {
      for (final ctrl in _viaCtrls) {
        final t = ctrl.text.trim();
        if (t.isNotEmpty) list.add(t);
      }
    }
    if (arr.isNotEmpty) list.add(arr);
    return list;
  }

  String _railwayName() =>
      _transport == 'その他' ? (_customTransport ?? '') : _transport;
  int? _amount() => int.tryParse(_costController.text.trim());

  Future<void> _handleSavePressed() async {
    FocusScope.of(context).unfocus();
    final durationEnd = _calculatePassEndDate(_selectedDate, _duration);
    final commuteDurationStr = _mapDurationToString(_duration);

    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // 이미지 업로드
      if (_imageFile != null) {
        final uploadedFileName = await fetchImageUpload('admins', _imageFile!);
        if (uploadedFileName == null) {
          attentionDialog(context, 'アップロード失敗', '画像アップロードに失敗しました。');
          return;
        }
        _imageName = uploadedFileName;
      }

      // payload 빌드 (기존 로직 그대로)
      final saveData = widget.commuteId == null
          ? TransportationSave(
        date: _selectedDate,
        expenseType: 'commute',
        fromStation: _departureController.text,
        toStation: _arrivalController.text,
        destination: _projectController.text,
        via: _viaJoined(),
        twice: false,
        railwayName: _railwayName(),
        amount: _amount(),
        image: _imageName ?? '',
        durationStart: _selectedDate.toIso8601String().split('T').first,
        durationEnd: durationEnd.toIso8601String().split('T').first,
        commuteDuration: commuteDurationStr,
        submissionStatus: 'draft',
        reviewStatus: '',
        id: widget.commuteId,
      )
          : TransportationUpdate(
        date: _selectedDate,
        id: widget.commuteId!,
        employeeId: "admins",
        expenseType: "commute",
        amount: _amount(),
        commuteDuration: commuteDurationStr,
        durationStart: _selectedDate.toIso8601String().split('T').first,
        durationEnd: durationEnd.toIso8601String().split('T').first,
        fromStation: _departureController.text,
        toStation: _arrivalController.text,
        destination: _projectController.text,
        twice: false,
        via: _viaJoined(),
        railwayName: _railwayName(),
        image: _imageName ?? '',
        submissionStatus: 'draft',
        reviewStatus: '',
      );

      final success = await fetchTransportationSaveUpload(
        widget.commuteId == null ? (saveData as TransportationSave?) : null,
        widget.commuteId != null ? (saveData as TransportationUpdate?) : null,
        widget.commuteId == null,
      );

      if (success) {
        await successDialog(context, '保存完了', '定期券保存が完了しました。');
        if (mounted) Navigator.pop(context, _selectedDate);
      } else {
        attentionDialog(context, '保存エラー', '定期券保存に失敗しました.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

  }

  Future<void> _handleDeletePressed() async {
    final id = widget.commuteId;
    if (id == null) return;

    final success = await fetchTransportationDelete(id);
    if (success) {
      await successDialog(context, '削除完了', '定期券削除が完了しました。');
      if (mounted) Navigator.pop(context, _selectedDate);
    } else {
      warningDialog(context, 'エラー', '送信に失敗しました。');
    }
  }

  @override
  void initState() {
    super.initState();
    final commuteIdInt = widget.commuteId;
    if (commuteIdInt != null) {
      ref.read(transportationDetailProvider(commuteIdInt).future).then((
        detail,
      ) {
        if (mounted) {
          setState(() {
            _departureController.text = detail.fromStation;
            _arrivalController.text = detail.toStation;
            _projectController.text = detail.destination;
            _costController.text = detail.amount.toString();
            _selectedDate =
                DateTime.tryParse(detail.durationStart) ?? DateTime.now();
            _duration = _mapStringToDuration(detail.commuteDuration);
            final isPresetTransport = singleTransportOptions.contains(
              detail.railwayName,
            );

            if (isPresetTransport) {
              _transport = detail.railwayName;
              _customTransport = null;
            } else {
              _transport = 'その他'; // 드롭다운에 표시
              _customTransport = detail.railwayName; // 입력 필드에 표시할 사용자 정의 값
              _customTransportController.text = detail.railwayName;
            }
            _imageName = detail.image;
            _submissionStatus = detail.submissionStatus;

            final viaString = detail.via;
            if (viaString.isNotEmpty) {
              final splitVia = viaString.split('、');
              for (final via in splitVia) {
                final controller = TextEditingController(text: via);
                _viaCtrls.add(controller);
              }
              _hasViaStation = _viaCtrls.isNotEmpty;
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _projectController.dispose();
    _customTransportController.dispose();
    _costController.dispose();
    for (final c in _viaCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // commuteId가 있을 때만 provider 호출
    final commuteIdInt = widget.commuteId;
    final detailAsync = commuteIdInt != null
        ? ref.watch(transportationDetailProvider(commuteIdInt))
        : null;

    final item = CommuterDetailItem(
      createdAt: _selectedDate,
      durationLabel: _duration.label,  // 例) 2025/08/01 – 2025/08/31
      project: _projectController.text.trim(),
      stations: _collectStations(), // 出発 + 経由 + 到着
      transportMode: _transport == 'その他'
          ? (_customTransport ?? '-')
          : _transport,
      totalFare: _cost ?? int.tryParse(_costController.text.trim()) ?? 0,
      imageUrl: _imageName,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: BaseMainScreen(
        backgroundColor: Colors.white,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFEFF2F4),
          child: Column(
            children: [
              BasicAppBar(onBack: () {Navigator.pop(context, widget.currentLocalDate);},), // 커스텀 AppBar// 커스텀 AppBar
              WelcomeHeader(
                title: commuteIdInt == null
                    ? '定期券申請'
                    : _submissionStatus == 'submitted'
                    ? '定期券申請完了'
                    : '定期券修正',
                subtitle: _submissionStatus == 'submitted'
                    ? '申請した定期券を確認してください。'
                    : '区間・期間・金額を確認して申請しましょう。',
                titleFontSize: 18,
                subtitleFontSize: 12,
                imagePath: 'assets/images/tabbar/apply/apply.png',
                imageWidth: 60,
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (detailAsync?.isLoading == true) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (detailAsync?.hasError == true) {
                      return Center(
                        child: Text('データ取得エラー: ${detailAsync?.error}'),
                      );
                    }
                    return _submissionStatus == 'submitted'
                        ? commuterBuildDetailBody(item)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StartDateSection(
                                  title: '開始日',
                                  date: _selectedDate,
                                  isReadOnly: false,
                                  onPick: (d) =>
                                      setState(() => _selectedDate = d),
                                ),
                                const SizedBox(height: 28),

                                DurationSection(
                                  value: _duration,
                                  isDisabled: false,
                                  onChanged: (d) =>
                                      setState(() => _duration = d),
                                ),
                                const SizedBox(height: 28),

                                ProjectSection(
                                  controller: _projectController,
                                  isDisabled: _submissionStatus == 'submitted',
                                  onChanged: (val) {
                                    setState(() {
                                      _projectController.text = val;
                                    });
                                  },),
                                const SizedBox(height: 28),

                                StationsSection(
                                  submissionLocked: false,
                                  departureCtrl: _departureController,
                                  arrivalCtrl: _arrivalController,
                                  isCommuter: true,
                                  hasVia: _hasViaStation,
                                  viaCtrls: _viaCtrls,
                                  onToggleVia: (v) => _toggleVia(v),
                                  onAddVia: _addVia,
                                  onRemoveVia: _removeLastVia,
                                ),
                                const SizedBox(height: 22),

                                TransportSection(
                                  options: commuterTransportOptions,
                                  selectedTransport: _transport,
                                  customTransportController:
                                      _customTransportController,
                                  isDisabled: _submissionStatus == 'submitted',
                                  onTransportChanged: (val) {
                                    setState(() {
                                      _transport = val;
                                      if (_transport != 'その他') {
                                        _customTransport = null;
                                        _customTransportController.clear();
                                      }
                                    });
                                  },
                                  onCustomTransportChanged: (val) {
                                    setState(() {
                                      _customTransport = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 22),

                                AmountSection(
                                  controller: _costController,
                                  isDisabled: _submissionStatus == 'submitted',
                                  onChanged: (val) {
                                    setState(() {
                                      _cost = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 22),

                                ReceiptSection(
                                  elementId: commuteIdInt,
                                  // null이면 신규, 값 있으면 수정 모드로 간주
                                  isDisabled: _submissionStatus == 'submitted',
                                  imageFile: _imageFile,
                                  // 신규일 때 선택된 파일 (없으면 null)
                                  imageName: _imageName,
                                  // 수정일 때 표시할 저장된 이름 (없으면 null)
                                  onImageSelected: (path) {
                                    setState(() {
                                      _imageFile = File(path);
                                      _imageName = path.split('/').last;
                                    });
                                  },
                                ),
                                const SizedBox(height: 36),

                                // 하단 버튼 영역
                                ExpenseActionBarSection.commuter(
                                  onSavePressed: _handleSavePressed,
                                  onDeletePressed: _handleDeletePressed,
                                  canShowSave: widget.commuteId == null || _submissionStatus == 'draft',
                                  canShowDelete: widget.commuteId != null && _submissionStatus == 'draft',
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



