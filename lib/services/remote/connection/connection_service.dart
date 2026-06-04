import 'package:dio/dio.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/remote/connection/connection_repo.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/services/remote/dio_initializer.dart';

class ConnectionService extends ConnectionRepo {
  final Dio _dio;
  final LogRepo _logRepo;

  static ConnectionService? instance;

  factory ConnectionService({Dio? dio, LogRepo? logRepo}) {
    instance ??= ConnectionService._pvConstructor(
      dio ?? DioInitializer.getInstance(),
      logRepo ?? LocalServices.logRepo,
    );
    return instance!;
  }

  ConnectionService._pvConstructor(this._dio, this._logRepo);

  @override
  Future<ApiResponse<void>> checkConnection(String url) async {
    try {
      _logRepo.quickLog("testing connection : ${_dio.options.baseUrl}");
      var response = await _dio.get(url);
      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: null);
      }
      return ApiResponseFailed(
          message: response.statusMessage ?? "",
          statusCode: response.statusCode);
    } catch (e) {
      return ApiResponseFailed(message: e.toString());
    }
  }
}
