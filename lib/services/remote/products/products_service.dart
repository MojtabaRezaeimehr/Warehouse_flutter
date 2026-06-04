import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/product.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/remote/dio_initializer.dart';
import 'package:warehouse_amf/services/remote/products/products_repo.dart';
import 'package:warehouse_amf/utils/consts/address.dart';
import 'package:warehouse_amf/utils/enums/log_level.dart';

class ProductService extends ProductsRepo {
  final AppConfigRepo _configRepo;
  final LogRepo _logRepo;
  final EncryptRepo _encryptRepo;
  final Dio _dio;

  
  late AppConfig _appConfig;

  static ProductService? instance;

  factory ProductService(
      {AppConfigRepo? configRepo,
      LogRepo? logRepo,
      EncryptRepo? encryptRepo,
      Dio? dio}) {
    instance ??= ProductService._pvConstructor(
      configRepo ?? LocalServices.appConfigRepo,
      logRepo ?? LocalServices.logRepo,
      encryptRepo ?? LocalServices.encryptRepo,
      dio ?? DioInitializer.getInstance(),
    );
    return instance!;
  }

  ProductService._pvConstructor(
      this._configRepo, this._logRepo, this._encryptRepo, this._dio){
        _appConfig = _configRepo.fetchConfig();
      }

  @override
  Future<ApiResponse<List<Product>>> fetchProducts(
      String query, CancelToken? cancelToken) async {
    try {
      _logRepo.quickLog("fetching products from server...");

      var response = await _dio.get(
        kApiFetchingProducts,
        cancelToken: cancelToken,
        queryParameters: {
          "productfaname": query,
        },
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
      );

      _logRepo.quickLog("kApiFetchingProducts got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        //since size of return ed companies maybe too large
        //isolate is used
        var products = await compute((dynamic data) {
          List<Product> products = [];
          for (var element in (data as List)) {
            products.add(Product.fromMap(element));
          }
          return products;
        }, response.data);

        return ApiResponseSucceeded(values: products);
      } else {
        _logRepo.logThis(
          Log(
              date: DateTime.now(),
              desc: "fecthing products failed! ${response.statusMessage} $code",
              tag: "API",
              logLevel: LogLevel.error),
        );
        return ApiResponseFailed(
            message: "failed to get products", statusCode: code);
      }
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "fecthing products failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );

      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> fetchproductName(String gtin) async {
    try {
      _logRepo.quickLog("fetching product name from server... gtin:$gtin");
      var response = await _dio.get(
        "$kApiFetchProductName/$gtin",
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
      );

      _logRepo.quickLog(
          "kApiFetchProductName got response ${response.data["productfrname"]}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: response.data["productfrname"]);
      } else {
        _logRepo.quickLog("failed to get the product name {gtin : $gtin}");

        return ApiResponseFailed(
          message: "failed to get the product name {gtin : $gtin}",
          statusCode: code,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _logRepo.quickLog("product of $gtin was not found");
        return ApiResponseFailed(message: "product of $gtin was not found");
      }
      return ApiResponseFailed(message: e.toString());
    } catch (e) {
      _logRepo.quickLog("failed to get the product name {gtin : $gtin} : $e");
      return ApiResponseFailed(message: e.toString());
    }
  }
}
