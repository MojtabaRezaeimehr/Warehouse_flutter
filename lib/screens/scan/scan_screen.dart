import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/order_cubit.dart';
import 'package:warehouse_amf/screens/scan/cubit/android_scanner_cubit.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/screens/scan/widget/result_viewer.dart';
import 'package:warehouse_amf/screens/scan/widget/manual_code_dialog.dart';
import 'package:warehouse_amf/screens/scan/widget/returner_error_dialog.dart';
import 'package:warehouse_amf/screens/scan/widget/scan_detail.dart';
import 'package:warehouse_amf/screens/scan/widget/scan_type_switch.dart';
import 'package:warehouse_amf/screens/scan/widget/scanner_controller.dart';
import 'package:warehouse_amf/screens/widgets/loading_dialog.dart';
import 'package:warehouse_amf/screens/widgets/resume_dialog.dart';
import 'package:warehouse_amf/utils/enums/scan_responses.dart';
import 'package:warehouse_amf/utils/enums/scanner_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late NewOrderCubit newOrderCubit;
  late OrderCubit oderCubit;
  late ScanCubit scanCubit;
  AndroidScannerCubit? androidScannerCubit;
  AudioPlayer audioPlayer = AudioPlayer();
 
  late final AppLifecycleListener lifecycleListener;
  bool manuallySavedOrder = false; 

  @override
  void initState() {
    oderCubit = BlocProvider.of<OrderCubit>(context);
    newOrderCubit = BlocProvider.of<NewOrderCubit>(context);
    scanCubit = BlocProvider.of<ScanCubit>(context);
    try {
      androidScannerCubit = BlocProvider.of<AndroidScannerCubit>(context);
      androidScannerCubit?.startListening(scanCubit);
    } catch (_) {}

    lifecycleListener = AppLifecycleListener(
      onInactive: () {
        if (!manuallySavedOrder) {
          newOrderCubit.finishOrder(oderCubit);
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    newOrderCubit.reset();
    scanCubit.reset();
    lifecycleListener.dispose();
    androidScannerCubit?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<ScanCubit, ScanState>(
          listener: (context, scanState) {
            String? audioAsset;
            switch (scanState) {
              case PostingBarcodeError _:
                Vibration.vibrate();
                ToastHelper.showErrorToast(
                  Text(Translations.error.name.tr()),
                  Text(scanState.error),
                );
                audioAsset = "assets/sounds/error.wav";
                break;
              case PostedBarcode _:
                if (scanState.scanResponse != ScanResponses.ok) {
                  Vibration.vibrate();
                  audioAsset = "assets/sounds/error.wav";

                  //in case of returner error show wish to continue dialog
                  if (scanState.scanResponse == ScanResponses.returnererror) {
                    showDialog(
                      context: context,
                      builder: (context) => ReturnerErrorDialog(
                          scanState.barcode, scanState.scannerType),
                    );
                  }
                } else {
                  audioAsset = "assets/sounds/success.wav";

                  //show manual dialog in case
                  //ScanReq was created by manual dialog
                  if (scanState.scannerType == ScannerType.manual) {
                    showDialog(
                      context: context,
                      builder: (context) => const ManualCodeDialog(),
                    );
                  }
                }
                break;
              default:
            }

            audioPlayer.clearAudioSources().then(
              (value) {
                if (audioAsset != null) {
                  audioPlayer.setAsset(audioAsset);
                  audioPlayer.play();
                }
              },
            );
          },
          builder: (context, scanState) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 5, top: 10),
              child: Column(
                spacing: 10,
                children: [
                  BlocBuilder<NewOrderCubit, NewOrderState>(
                    builder: (context, state) {
                      String id = "...";
                      if (state is OrderStartedState) {
                        id = "${state.orderId}";
                      }

                      int scannedQuantity =
                          newOrderCubit.getOrderScannedCount();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 40,
                            width: 60,
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh),
                            child: Text(
                              id,
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 200,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(Translations.scannedCount.name.tr()),
                                Text("$scannedQuantity"),
                              ],
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh),
                            child: Text(
                              "${scanState is PostingBarcodeDone ? scanState.scanDuration : 0}ms",
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const ResultViewer(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      child: const ScanDetail(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 5,
                    children: [
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          fixedSize: const Size(90, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: scanState is PostingBarcode
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const ManualCodeDialog(),
                                );
                              },
                        icon: const Icon(Icons.add),
                      ),
                      Expanded(
                        child: IconButton.outlined(
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: scanState is PostingBarcode
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ScannerPage(),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.qr_code_scanner),
                        ),
                      ),
                      const ScanTypeSwitch(),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          scanState is PostingBarcode ? null : finishButtonTap,
                      child: Text(Translations.finish.name.tr()),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  finishButtonTap() async {
    //check if order is completed
    var capturedContext = context;
    LoadingDialog.show(context);
    var isCompleted = await newOrderCubit.isOrderCompleted();
    LoadingDialog.dismiss();

    if (!capturedContext.mounted) {
      return;
    }

    bool finishOrder = await showDialog(
      context: capturedContext,
      builder: (context) {
        return ResumeDialog(
          title: Text(
            isCompleted
                ? Translations.exitOrder.name.tr()
                : Translations.orderIsNotDone.name.tr(),
          ),
        );
      },
    );
    if (!finishOrder) {
      return;
    }

    newOrderCubit.finishOrder(
      oderCubit,
      manuallyRequested: true,
    );
    manuallySavedOrder = true;
    // ignore: use_build_context_synchronously
    Navigator.pop(capturedContext);
  }
}
