import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/utils/enums/scanner_types.dart';
import 'package:warehouse_amf/utils/functions.dart';

part 'android_scanner_state.dart';

class AndroidScannerCubit extends Cubit<AndroidScannerState> {
  static const _eventChannel = EventChannel(
    'android-barcode-scan-event',
  );
  final AppConfigRepo _configRepo;
  final LogRepo _logRepo;

  AndroidScannerCubit({AppConfigRepo? configRepo, LogRepo? logRepo})
      : _configRepo = configRepo ?? LocalServices.appConfigRepo,
        _logRepo = logRepo ?? LocalServices.logRepo,
        super(AndroidScannerInitial());

  startListening(ScanCubit scanCubit) async {
    if (state is StartedListening) {
      return;
    }

    try {
      //initialize default values with invoking method channel
      var config = _configRepo.fetchConfig();
      const MethodChannel("android-barcode-scan-channel")
        ..invokeMethod("action", {"action": config.inentAction})
        ..invokeMethod("data_key", {"data_key": config.intentDataKey});

      var streamSubscription = _eventChannel.receiveBroadcastStream().listen(
        (value) {
          if (scanCubit.state is PostingBarcode || value == null) {
            //do not post any barcode while there is -
            //an ongoing request
            return;
          }
          _logRepo.quickLog("recieved barcode from native side $value");
          if (!isBarcodeValid(value)) {
            return;
          }
          var scanReq = scanCubit.generateScanRequest(value);
          scanCubit.postBarcode(scanReq, ScannerType.laser);
        },
      );
      dprint("started listening");
      emit(StartedListening(streamSubscription: streamSubscription));
    } catch (_) {}
  }

  stopListening() async {
    if (state is StartedListening) {
      (state as StartedListening).streamSubscription.cancel();
      emit(StopedListening());
    }
  }
}
