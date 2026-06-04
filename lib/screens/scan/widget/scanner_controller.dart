import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/utils/enums/scanner_types.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool captured = false;
  bool torchEnabled = false;
  bool backCamera = false;

  late final MobileScannerController controller;
  late ScanCubit scanCubit;
  late NewOrderCubit newOrderCubit;
  late UserAuthCubit userAuthCubit;

  @override
  void initState() {
    controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode, BarcodeFormat.dataMatrix],
      autoStart: true,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    scanCubit = BlocProvider.of<ScanCubit>(context);
    userAuthCubit = BlocProvider.of<UserAuthCubit>(context);
    newOrderCubit = BlocProvider.of<NewOrderCubit>(context);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (capture.barcodes.length > 1 ||
                  capture.barcodes[0].rawValue == null) {
                return;
              }
              if (newOrderCubit.state is! OrderStartedState ||
                  userAuthCubit.state is! UserAuthorized) {
                return;
              }

              if (!captured) {
                captured = true;
                Navigator.of(context).pop();

                //post scanned barcode
                var scanReq = scanCubit.generateScanRequest(
                  capture.barcodes[0].rawValue!,
                );
                scanCubit.postBarcode(scanReq, ScannerType.camera);
              }
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const BackButton(),
            IconButton(
                color: Colors.white,
                icon: torchEnabled
                    ? const Icon(
                        Icons.flash_on,
                        color: Colors.yellow,
                      )
                    : const Icon(
                        Icons.flash_off,
                        color: Colors.grey,
                      ),
                iconSize: 32.0,
                onPressed: () {
                  setState(() {
                    torchEnabled = !torchEnabled;
                    controller.toggleTorch();
                  });
                }),
            IconButton(
                color: Colors.white,
                icon: backCamera
                    ? const Icon(Icons.camera_rear)
                    : const Icon(Icons.camera_front),
                iconSize: 25.0,
                onPressed: () {
                  setState(() {
                    backCamera = !backCamera;
                    controller.switchCamera();
                  });
                }),
          ],
        )
      ],
    );
  }
}
