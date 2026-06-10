import 'package:dio/dio.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_service.dart';
import 'package:warehouse_amf/utils/functions.dart';

class DioInitializer {
  static Dio? _dio;
  static Dio getInstance() {
    var config = AppConfigService().fetchConfig();

    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: config.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      _dio!.interceptors.add(_loggingInterceptor());
    }

    return _dio!;
  }

  // update _dio instance base url(since all remote services depend on this instance)
  static void updateBaserUrl() {
    var config = AppConfigService().fetchConfig();
    var baseOption = _dio!.options.copyWith(baseUrl: config.baseUrl);
    _dio!.options = baseOption;
  }

  // logs every outgoing request, response and error to the debug console so
  // the exact URL/method/body hitting the server can be inspected.
  static Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        dprint("[DIO] --> ${options.method} ${options.uri}");
        dprint("[DIO]     baseUrl: ${options.baseUrl} | path: ${options.path}");
        dprint("[DIO]     headers: ${options.headers}");
        dprint("[DIO]     body: ${options.data}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        dprint(
            "[DIO] <-- ${response.statusCode} ${response.requestOptions.uri}");
        dprint("[DIO]     data: ${response.data}");
        handler.next(response);
      },
      onError: (err, handler) {
        dprint("[DIO] xx- ${err.type} ${err.requestOptions.uri}");
        dprint("[DIO]     message: ${err.message}");
        dprint("[DIO]     error: ${err.error}");
        handler.next(err);
      },
    );
  }
}
