import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hihatu_project/apply/finance/detail/single/sections/destination_section.dart';
import 'package:hihatu_project/apply/finance/detail/summary/sections/purpose_section.dart';
import 'package:hihatu_project/apply/finance/detail/single/sections/round_trip_section.dart';
import 'package:hihatu_project/apply/finance/detail/single/single_detail.dart';
import 'dart:io';
import '../../../../../../utils/dialog/attention_dialog.dart';
import '../../../../../../utils/dialog/success_dialog.dart';
import '../../../../../utils/dialog/warning_dialog.dart';
import '../../../../base/base_main_screen.dart';
import '../../../../header/title_header.dart';
import '../../api/fetch_image_upload.dart';
import '../../api/fetch_transportation_delete.dart';
import '../../api/fetch_transportation_save.dart';
import '../../data/dtos/transportation_save.dart';
import '../../data/dtos/transportation_update.dart';
import '../../presentation/constants/single_purpose_options.dart';
import '../../presentation/constants/single_transport_options.dart';
import '../../state/transportation_provider.dart';
import '../summary/sections/action_bar_section.dart';
import '../summary/sections/amount_section.dart';
import '../summary/sections/receipt_section.dart';
import '../summary/sections/start_date_section.dart';
import '../summary/sections/stations_section.dart';
import '../summary/sections/transport_section.dart';
import '../../../../utils/widgets/app_bar/basic_app_bar.dart';
import 'data/single_detail_item.dart';

class SingleScreen extends ConsumerStatefulWidget {
  final int? singleId;
  final DateTime currentLocalDate;

  const SingleScreen({
    this.singleId,
    required this.currentLocalDate,
    super.key,
  });

  @override
  ConsumerState<SingleScreen> createState() =>
      _TransportationInputScreenState();
}

class _TransportationInputScreenState extends ConsumerState<SingleScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _customTransportController =
      TextEditingController();
  final TextEditingController _customPurposeController =
      TextEditingController();
  final _costController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _transport = '電車';
  String? _customTransport;
  int? _cost;
  String? _imageName;
  File? _imageFile;
  bool isRoundTrip = false;
  String _purpose = '通勤';
  String? _customPurpose;
  String? _submissionStatus;

  bool _isSaving = false;

  Future<void> _handleSavePressed() async {
    FocusScope.of(context).unfocus();
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
      final saveData = widget.singleId == null
          ? TransportationSave(
              date: _selectedDate,
              expenseType: 'single',
              fromStation: _departureController.text,
              toStation: _arrivalController.text,
              destination: _destinationController.text,
              twice: isRoundTrip,
              railwayName: _transport == 'その他'
                  ? (_customTransport ?? '')
                  : _transport,
              goals: _purpose == 'その他' ? (_customPurpose ?? '') : _purpose,
              amount: int.tryParse(_costController.text.trim()),
              image: _imageName ?? '',
              durationStart: _selectedDate.toIso8601String().split('T').first,
              submissionStatus: 'draft',
              reviewStatus: '',
              id: widget.singleId,
            )
          : TransportationUpdate(
              date: _selectedDate,
              id: widget.singleId!,
              employeeId: "admins",
              // 임시
              expenseType: "single",
              amount: int.tryParse(_costController.text.trim()),
              durationStart: _selectedDate.toIso8601String().split('T').first,
              fromStation: _departureController.text,
              toStation: _arrivalController.text,
              destination: _destinationController.text,
              twice: isRoundTrip,
              railwayName: _transport == 'その他'
                  ? (_customTransport ?? '')
                  : _transport,
              goals: _purpose == 'その他' ? (_customPurpose ?? '') : _purpose,
              image: _imageName ?? '',
              submissionStatus: 'draft',
              reviewStatus: '',
            );

      final success = await fetchTransportationSaveUpload(
        widget.singleId == null ? (saveData as TransportationSave?) : null,
        widget.singleId != null ? (saveData as TransportationUpdate?) : null,
        widget.singleId == null,
      );

      if (success) {
        await successDialog(context, '保存完了', '交通費保存が完了しました。');
        if (mounted) Navigator.pop(context, _selectedDate);
      } else {
        attentionDialog(context, '保存エラー', '交通費保存に失敗しました.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDeletePressed() async {
    final id = widget.singleId;
    if (id == null) return;

    final success = await fetchTransportationDelete(id);
    if (success) {
      await successDialog(context, '削除完了', '交通費削除が完了しました。');
      if (mounted) Navigator.pop(context, _selectedDate);
    } else {
      warningDialog(context, 'エラー', '送信に失敗しました。');
    }
  }

  @override
  void initState() {
    super.initState();
    final transportationId = widget.singleId;
    if (transportationId != null) {
      ref.read(transportationDetailProvider(transportationId).future).then((
        detail,
      ) {
        if (mounted) {
          setState(() {
            _departureController.text = detail.fromStation;
            _arrivalController.text = detail.toStation;
            _destinationController.text = detail.destination;
            _costController.text = detail.amount.toString();
            _selectedDate =
                DateTime.tryParse(detail.durationStart) ??
                DateTime.now(); //durationStart: 정기권시작일

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

            final isPresetPurpose = singlePurposeOptions.contains(detail.goals);
            if (isPresetPurpose) {
              _purpose = detail.goals;
              _customPurpose = null;
            } else {
              _purpose = 'その他'; // 드롭다운에 표시
              _customPurpose = detail.goals; // 입력 필드에 표시할 사용자 정의 값
              _customPurposeController.text = detail.goals;
            }

            _imageName = detail.image;
            _submissionStatus = detail.submissionStatus;

            // 추가된 상태 업데이트 (CommuterScreen 스타일)
            _cost = detail.amount;
            isRoundTrip = detail.twice;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // commuteId가 있을 때만 provider 호출
    final transportationId = widget.singleId;
    final detailAsync = transportationId != null
        ? ref.watch(transportationDetailProvider(transportationId))
        : null;

    final item = SingleDetailItem(
      createdAt: _selectedDate,
      departureStation: _departureController.text.trim(),
      arrivalStation: _arrivalController.text.trim(),
      destination: _destinationController.text.trim(),
      isRoundTrip: isRoundTrip,
      transportMode: _transport == 'その他'
          ? (_customTransport ?? '-')
          : _transport,
      totalFare: _cost ?? int.tryParse(_costController.text.trim()) ?? 0,
      purpose: _purpose == 'その他' ? (_customPurpose ?? '-') : _purpose,
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
              BasicAppBar(
                onBack: () {
                  Navigator.pop(context, widget.currentLocalDate);
                },
              ), // 커스텀 AppBar // 커스텀 AppBar
              WelcomeHeader(
                title: transportationId == null
                    ? '交通費申請'
                    : _submissionStatus == 'submitted'
                    ? '交通費申請完了'
                    : '交通費修正',
                subtitle: _submissionStatus == 'submitted'
                    ? '申請した交通費を確認してください。'
                    : '出発駅・到着駅・金額を確認して申請しましょう。',
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
                        ? singleBuildDetailBody(item)
                        : Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StartDateSection(
                                    title: '日付',
                                    date: _selectedDate,
                                    isReadOnly: false,
                                    onPick: (d) =>
                                        setState(() => _selectedDate = d),
                                  ),
                                  const SizedBox(height: 28),

                                  StationsSection(
                                    submissionLocked: false,
                                    departureCtrl: _departureController,
                                    arrivalCtrl: _arrivalController,
                                    isCommuter: false,
                                    hasVia: false,
                                    viaCtrls: [],
                                    onToggleVia: (v) => () {},
                                    onAddVia: () {},
                                    onRemoveVia: () {},
                                  ),
                                  RoundTripSection(
                                    isRoundTrip: isRoundTrip,
                                    isDisabled:
                                        _submissionStatus == 'submitted',
                                    onChanged: (val) {
                                      setState(() => isRoundTrip = val);
                                    },
                                  ),
                                  const SizedBox(height: 22),

                                  DestinationSection(
                                    controller: _destinationController,
                                    isDisabled:
                                        _submissionStatus == 'submitted',
                                    onChanged: (val) {
                                      setState(() {
                                        _destinationController.text = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 22),

                                  TransportSection(
                                    options: singleTransportOptions,
                                    selectedTransport: _transport,
                                    customTransportController:
                                        _customTransportController,
                                    isDisabled:
                                        _submissionStatus == 'submitted',
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
                                    isDisabled:
                                        _submissionStatus == 'submitted',
                                    onChanged: (val) {
                                      setState(() {
                                        _cost = val;
                                      });
                                    },
                                    isRoundTrip: isRoundTrip,
                                  ),
                                  const SizedBox(height: 22),

                                  PurposeSection(
                                    options: singlePurposeOptions,
                                    selectedPurpose: _purpose,
                                    customPurposeController:
                                        _customPurposeController,
                                    isDisabled:
                                        _submissionStatus == 'submitted',
                                    onPurposeChanged: (val) {
                                      setState(() {
                                        _purpose = val;
                                        if (_purpose != 'その他') {
                                          _customPurpose = null;
                                          _customPurposeController.clear();
                                        }
                                      });
                                    },
                                    onCustomPurposeChanged: (val) {
                                      setState(() {
                                        _customPurpose = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 22),

                                  ReceiptSection(
                                    elementId: widget.singleId,
                                    // null이면 신규, 값 있으면 수정 모드로 간주
                                    isDisabled:
                                        _submissionStatus == 'submitted',
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

                                  ExpenseActionBarSection.single(
                                    onSavePressed: _handleSavePressed,
                                    onDeletePressed: _handleDeletePressed,
                                    canShowSave:
                                        widget.singleId == null ||
                                        _submissionStatus == 'draft',
                                    canShowDelete:
                                        widget.singleId != null &&
                                        _submissionStatus == 'draft',
                                  ),
                                ],
                              ),
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
