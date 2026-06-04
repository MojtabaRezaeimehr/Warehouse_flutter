import 'package:dio/dio.dart';
import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/models/remote/order/api_order.dart';
import 'package:warehouse_amf/models/remote/order/order_detail.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/order/load_order_request.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/models/remote/product.dart';
import 'package:warehouse_amf/models/remote/scanned_child.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/remote/dio_initializer.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/utils/consts/address.dart';
import 'package:warehouse_amf/utils/enums/log_level.dart';

class OrdersService extends OrdersRepo {
  final AppConfigRepo _configRepo;
  final LogRepo _logRepo;
  final EncryptRepo _encryptRepo;
  final Dio _dio;

  late AppConfig _appConfig;

  static OrdersService? instance;

  factory OrdersService({
    AppConfigRepo? configRepo,
    LogRepo? logRepo,
    EncryptRepo? encryptRepo,
    Dio? dio,
  }) {
    instance ??= OrdersService._pvConstructor(
      configRepo ?? LocalServices.appConfigRepo,
      logRepo ?? LocalServices.logRepo,
      encryptRepo ?? LocalServices.encryptRepo,
      dio ?? DioInitializer.getInstance(),
    );
    return instance!;
  }

  OrdersService._pvConstructor(
      this._configRepo, this._logRepo, this._encryptRepo, this._dio) {
    //_configRepo is injected as dependency to make ther serivce more testeable
    //instead of providing apponfig its repo behavior can be mocked
    _appConfig = _configRepo.fetchConfig();
  }

  @override
  Future<ApiResponse<(List<Order> orders, bool hasMore)>> fetchOrdersForUser(
    int userId,
    int from,
    int to,
  ) async {
    try {
      _logRepo.quickLog("fetchOrdersForUser..");
      var response = await _dio.get(
        "$kApiFetchingUserOrders/$userId",
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
        queryParameters: {"from": from, "to": to},
      );

      _logRepo.quickLog("fetchOrdersForUser got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(
          values: (
            (response.data["orders"] as List)
                .map(
                  (e) => Order.fromMap(e),
                )
                .toList(),
            response.data["pagination"]["hasMore"],
          ),
        );
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "fetchOrdersForUserfailed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> startOrder(StartOrderRequest req) async {
    try {
      _logRepo.quickLog("starting Order...");

      var response = await _dio.post(
        kApiLoadOrder,
        data: req.toMap(),
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
      );

      _logRepo.quickLog("kApiLoadOrder got response ${response.data}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(
          values: response.data[0][0]["result"],
        );
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "starting order failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse> postOrderLimitInfo(
      List<ScannedProduct> limitedProducts, String orderId) async {
    try {
      _logRepo.quickLog("posting order limit info");

      var response = await _dio.post(
        kApiLimitInfo,
        data: limitedProducts.map((e) => e.toMapWithOrderId(orderId)).toList(),
        options: Options(headers: {
          "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
        }),
      );

      _logRepo.quickLog("kApiLimitInfo got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: null);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "posing order limit failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<int>> fetchProductCountInOrder(
      String gtin, String orderId) async {
    try {
      _logRepo.quickLog("fetching product count in order...");

      var response = await _dio.post(kApiProductCountInOrder,
          options: Options(headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          }),
          data: {
            "gtin": gtin,
            "favoritecode": orderId,
          });

      _logRepo.quickLog(
          "kApiProductCountInOrder got response count ${response.data[0]['productcount']}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: response.data[0]['productcount']);
      } else {
        _logRepo.quickLog("failed to get kApiProductCountInOrder");

        return ApiResponseFailed(
          message: "failed to get product count in order",
          statusCode: code,
        );
      }
    } catch (e) {
      _logRepo.quickLog("failed to get kApiProductCountInOrder : $e");
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<OrderDetail>>> fetchOrderDetail(int orderId) async {
    try {
      _logRepo.quickLog("fetchOrderDetail..");
      var response = await _dio.post(kApiOderDetail,
          options: Options(headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          }),
          data: {"whOrderId": orderId});

      _logRepo.quickLog("fetchOrderDetail got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        List<OrderDetail> orderDetails = (response.data as List)
            .map(
              (e) => OrderDetail.fromMap(e),
            )
            .toList();
        return ApiResponseSucceeded(values: orderDetails);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "fetchOrderDetail Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<ScannedChild>>> fetchScannedChildren(
      String uid, int whOrderId) async {
    try {
      _logRepo.quickLog("getScannedChildren.. $uid");
      var response = await _dio.post(
        kApiFetchScannedChildren,
        data: {"uid": uid, "whOrderId": whOrderId},
        options: Options(
          headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          },
        ),
      );

      _logRepo.quickLog("getScannedChildren got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        List<ScannedChild> children = (response.data as List)
            .map(
              (e) => ScannedChild.fromMap(e),
            )
            .toList();
        return ApiResponseSucceeded(values: children);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "getScannedChildren Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse> deleteOrder(int orderId) async {
    try {
      _logRepo.quickLog("deleteOrder.. $orderId");
      var response = await _dio.delete(
        "$kApiDeleteOrder/$orderId",
        options: Options(
          headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          },
        ),
      );

      _logRepo.quickLog("deleteOrder got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: null);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "deleteOrder Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<ApiOrder>>> fetchApiOrders(
      String documentCode, CancelToken? cancelToken) async {
    try {
      _logRepo.quickLog("fetchApiOrders..");

      var response = await _dio.get(kApiOder,
          options: Options(headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          }),
          queryParameters: {"documentCode": documentCode});

      _logRepo.quickLog("fetchApiOrders got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        List<ApiOrder> orderDetails = (response.data as List)
            .map(
              (e) => ApiOrder.fromMap(e),
            )
            .toList();
        return ApiResponseSucceeded(values: orderDetails);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "fetchApiOrders Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<(int? orderId, String progress)>> getApiOrderProgress(
      String documentCode) async {
    try {
      _logRepo.quickLog("getApiOrderProgress..");

      var response = await _dio.post(kApiGetOrderProgress,
          options: Options(headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          }),
          data: {"documentNo": documentCode});

      _logRepo.quickLog("getApiOrderProgress got response : ${response.data}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: (
          response.data["OrderId"],
          response.data["OrderProgress"],
        ));
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "getApiOrderProgress Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<Map<String, int>>> fetchApiOrderProducts(
    int orderId,
  ) async {
    try {
      _logRepo.quickLog("fetchOrderProducts..");

      var response = await _dio.get(kApiGetApiOrderProducts,
          options: Options(headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          }),
          queryParameters: {"orderid": orderId});

      _logRepo.quickLog("fetchOrderProducts got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        Map<String, int> result = {};

        for (var e in (response.data as List)) {
          result.putIfAbsent(
              e["gtin"] as String, () => (e["lvl0qty"] ?? 0) as int);
        }
        return ApiResponseSucceeded(values: result);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "fetchOrderProducts Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> isOrderCompleted(int orderId) async {
    try {
      _logRepo.quickLog("isOrderCompleted..");

      var response = await _dio.get("$kApiIsOrderCompleted/$orderId",
          options: Options(headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          }),
          queryParameters: {"orderid": orderId});

      _logRepo.quickLog("isOrderCompleted got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        return ApiResponseSucceeded(values: response.data["result"]);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "isOrderCompleted Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<ScannedProduct>>> fetchOrderProducts(
      int orderId) async {
    try {
      _logRepo.quickLog("fetchOrderScannedProducts..");

      var response = await _dio.get(kApiGetOrderProducts,
          options: Options(headers: {
            "amf_token_header_key": await _encryptRepo.dyc(_appConfig.token)
          }),
          queryParameters: {"orderid": orderId});

      _logRepo.quickLog("fetchOrderScannedProducts got response ${response.data}");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        var result = (response.data as List).map(
          (e) {
            int? limit;
            if (e["LimitMax"] != null && e["LimitMax"] != 0) {
              limit = e["LimitMax"];
            }
            return ScannedProduct(
              product: Product(
                id: "-1",
                name: e["ProductFrName"],
                gtin: e["GTIN"],
              ),
              scanQuantity: e["lvl0qty"] ?? 0,
              maxScanQuantity: limit,
            );
          },
        ).toList();

        return ApiResponseSucceeded(values: result);
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "fetchOrderProducts Failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }
}
