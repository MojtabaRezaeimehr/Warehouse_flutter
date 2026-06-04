import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/models/local/barcode.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/scan/scan_request.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_type_cubit.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/local/scanned_history/scanned_history_repo.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';
import 'package:warehouse_amf/services/remote/scan/scan_repo.dart';
import 'package:warehouse_amf/utils/enums/scan_responses.dart';
import 'package:warehouse_amf/utils/enums/scan_type.dart';
import 'package:warehouse_amf/utils/enums/scanner_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';

part 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ScannedHistoryRepo _scannedHistoryRepo;
  final LogRepo _logRepo;
  final ScanRepo _scanRepo;

  final NewOrderCubit newOrderCubit;
  final ScanTypeCubit scanTypeCubit;
  final UserAuthCubit userAuthCubit;
  ScanCubit({
    required this.newOrderCubit,
    required this.scanTypeCubit,
    required this.userAuthCubit,
    ScannedHistoryRepo? scannedHistoryRepo,
    LogRepo? logRepo,
    ScanRepo? scanRepo,
  })  : _scannedHistoryRepo =
            scannedHistoryRepo ?? LocalServices.scannedHistoryRepo,
        _logRepo = logRepo ?? LocalServices.logRepo,
        _scanRepo = scanRepo ?? RemoteServices.scanRepo,
        super(ScanInitial());

  Future<void> postBarcode(
    ScanRequest scanRequest,
    ScannerType scannerType,
  ) async {
    var startTime = DateTime.now();

    if (state is PostingBarcode) {
      _logRepo.quickLog(
        "postBarcode is called when state is PostingBarcode.early return",
      );
      return;
    }

    // As server load increased, the sp_scanuid procedure could not handle
    // requests that arrived within a short interval.
    // The issue occurred when an order was limited and two post-UID requests
    // were sent to the server. The second request should have been ignored
    // with a 'not OK' response (e.g., Duplicate or LimitError).
    // However, since the first request hadn't fully processed, the second one
    // was mistakenly accepted.
    // !As a workaround, we were asked to prevent multiple requests within 500ms.
    if (state case PostedBarcode ps) {
      bool invalid = ps.scanDate.isAfter(startTime.subtract(
        const Duration(milliseconds: 500),
      ));
      if (invalid) {
        _logRepo.quickLog(
          "avoid sending multiple requests in less than 1 second.early return",
        );
        return;
      }
    }

    emit(
      PostingBarcode(
        barcode: scanRequest.barcode,
        scannerType: scannerType,
      ),
    );

    String? gtin = getGtinFromBarcode(scanRequest.barcode);
    if (gtin == null) {
      _logRepo.quickLog("failed to updateScannedProduct gtin is null");
      PostingBarcodeError(
        scanDuration: "0",
        barcode: scanRequest.barcode,
        error: "failed to updateScannedProduct gtin is null",
        scannerType: scannerType,
        scanDate: startTime,
      );
      return;
    }

    //check if order is limited and scanned product is valid
    if (!isValidProduct(gtin, newOrderCubit)) {
      _logRepo.quickLog("product is not valid gtin:$gtin");
      emit(
        PostingBarcodeError(
          error: Translations.notValidProduct.name.tr(),
          barcode: scanRequest.barcode,
          scannerType: scannerType,
          scanDate: startTime,
          scanDuration: "0",
        ),
      );
      return;
    }

    var response = await _scanRepo.postBarcode(scanRequest);
    DateTime now = DateTime.now();

    if (response is ApiResponseSucceeded) {
      emit(
        PostedBarcode(
          scanDuration: now.difference(startTime).inMilliseconds.toString(),
          barcode: scanRequest.barcode,
          scanResponse: response.values!,
          scannerType: scannerType,
          scanDate: now,
        ),
      );
      //update scannedProduct of this order
      if (response.values == ScanResponses.ok) {
        newOrderCubit.putScannedProduct(gtin, scanTypeCubit);
      }

      //insert scan histroy
      _scannedHistoryRepo.addToHistory(
        Barcode(
          value: scanRequest.uid,
          scanType: scanRequest.state == "ADD" ? ScanType.add : ScanType.delete,
          scanResponse: response.values!,
          scanDate: now,
        ),
      );
    } else {
      emit(
        PostingBarcodeError(
          scanDuration: now.difference(startTime).inMilliseconds.toString(),
          barcode: scanRequest.barcode,
          error: (response as ApiResponseFailed).message,
          scannerType: scannerType,
          scanDate: now,
        ),
      );
    }
  }

  void reset() => emit(ScanInitial());

  bool isValidProduct(String? gtin, NewOrderCubit newOrderCubit) {
    var newOrderState = newOrderCubit.state as OrderStartedState;
    if (!newOrderState.isOrderLimited() ||
        newOrderState.scannedProducts.isEmpty) {
      return true;
    }

    if (gtin != null) {
      for (var element in newOrderState.scannedProducts) {
        if (element.product.gtin == gtin) {
          return true;
        }
      }
    }

    return false;
  }

  ScanRequest generateScanRequest(String barcode, {bool forceUpdate = false}) {
    if (newOrderCubit.state is! OrderStartedState) {
      throw Exception(
          "generateScanRequest was exceuted while new order state is not order started");
    }

    return ScanRequest(
        barcode: barcode,
        uid: getUidFromBarcode(barcode)!,
        orderId: "${(newOrderCubit.state as OrderStartedState).orderId}",
        state: scanTypeCubit.state is AddingState ? "ADD" : "DELETE",
        userId: "${(userAuthCubit.state as UserAuthorized).user.id}",
        orderType: (newOrderCubit.state as OrderStartedState).orderTypes,
        forceUpdate: forceUpdate);
  }

  void createBarcodeAndPost(String value) async {
    //this value is passed by manual code dialog and may be RND ,UID or the whole barcode
    //ceck if its barcode
    String barcode = "";
    if (isBarcodeValid(value)) {
      barcode = value;
    } else if (value.length == 20 || value.length == 16) {
      //its UID or RND
      //todo add logs here!!!!!!!
      var response = value.length == 20
          ? await _scanRepo.getBarcodeOfUID(value)
          : await _scanRepo.getBarcodeOfRND(value);
      if (response is ApiResponseFailed) {
        emit(
          PostingBarcodeError(
            error: (response as ApiResponseFailed).message,
            barcode: barcode,
            scannerType: ScannerType.manual,
            scanDate: DateTime.now(),
            scanDuration: "0",
          ),
        );
        return;
      }

      if (response is ApiResponseSucceeded) {
        if (response.values == null) {
          emit(
            PostingBarcodeError(
              error: Translations.foundNoBarcode.name.tr(),
              barcode: barcode,
              scannerType: ScannerType.manual,
              scanDate: DateTime.now(),
              scanDuration: "0",
            ),
          );
          return;
        }
        barcode = response.values!;
      }
    } else {
      emit(
        PostingBarcodeError(
          error: Translations.invalidId.name.tr(),
          barcode: barcode,
          scannerType: ScannerType.manual,
          scanDate: DateTime.now(),
          scanDuration: "0",
        ),
      );
    }

    //now that barcode is generated post it to server
    postBarcode(generateScanRequest(barcode), ScannerType.manual);
  }
}
