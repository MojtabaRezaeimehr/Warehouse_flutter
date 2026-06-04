import 'package:dio/dio.dart';
import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/scan/scan_request.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/remote/dio_initializer.dart';
import 'package:warehouse_amf/services/remote/scan/scan_repo.dart';
import 'package:warehouse_amf/utils/consts/address.dart';
import 'package:warehouse_amf/utils/enums/log_level.dart';
import 'package:warehouse_amf/utils/enums/scan_responses.dart';

class ScanService extends ScanRepo {
  final AppConfigRepo _configRepo;
  final LogRepo _logRepo;
  final EncryptRepo _encryptRepo;
  final Dio _dio;

  
  late AppConfig _appConfig;

  static ScanService? instance;

  factory ScanService({
    AppConfigRepo? configRepo,
    LogRepo? logRepo,
    EncryptRepo? encryptRepo,
    Dio? dio,
  }) {
    instance ??= ScanService._pvConstructor(
      configRepo ?? LocalServices.appConfigRepo,
      logRepo ?? LocalServices.logRepo,
      encryptRepo ?? LocalServices.encryptRepo,
      dio ?? DioInitializer.getInstance(),
    );
    return instance!;
  }

  ScanService._pvConstructor(
      this._configRepo, this._logRepo, this._encryptRepo, this._dio){
        _appConfig = _configRepo.fetchConfig();
      }

  @override
  Future<ApiResponse<ScanResponses>> postBarcode(
      ScanRequest scanRequest) async {
    try {

      _logRepo.quickLog(
          "posting uid ${scanRequest.state} orderid:${scanRequest.orderId} ${scanRequest.uid}");

      var response = await _dio.post(
        kApiPostBarcode,
        data: scanRequest.toMap(),
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
      );

      _logRepo.quickLog(
          "postBarcode got response result ${response.data[0]["result"]}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        ScanResponses scanResponse = ScanResponses.values.firstWhere(
          (element) =>
              element.name ==
              response.data[0]["result"].toString().toLowerCase(),
          orElse: () => ScanResponses.unIndentified,
        );
        return ApiResponseSucceeded(values: scanResponse);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "postBarcode failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> getBarcodeOfRND(String rnd) async {
    try {

      _logRepo.quickLog("getBarcodeOfRND... $rnd");

      var response = await _dio.post(
        kApiGetRndBarcode,
        data: {"rndesalat": rnd},
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
      );

      _logRepo.quickLog("getBarcodeOfRND got response result ${response.data}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: response.data[0]["barcode"]);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "getBarcodeOfRND failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> getBarcodeOfUID(String uid) async {
    try {

      _logRepo.quickLog("getBarcodeOfUID... $uid");

      var response = await _dio.post(
        kApiGetUidBarcode,
        data: {"uuid": uid},
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
      );

      _logRepo.quickLog("getBarcodeOfUID got response result ${response.data}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: response.data[0]["barcode"]);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "getBarcodeOfUID failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }
}
