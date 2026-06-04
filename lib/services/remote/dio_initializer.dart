import 'package:dio/dio.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_service.dart';

class DioInitializer {
  static Dio? _dio;
  static Dio getInstance() {
    var config = AppConfigService().fetchConfig();

    _dio ??= Dio(
      BaseOptions(baseUrl: config.baseUrl),
    );

    return _dio!;
  }

  // update _dio instance base url(since all remote services depend on this instance)
  static void updateBaserUrl() {
    var config = AppConfigService().fetchConfig();
    var baseOption = _dio!.options.copyWith(baseUrl: config.baseUrl);
    _dio!.options = baseOption;
  }
}
