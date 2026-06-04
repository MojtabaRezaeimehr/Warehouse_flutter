import 'package:dio/dio.dart';
import 'package:warehouse_amf/models/remote/order/api_order.dart';
import 'package:warehouse_amf/models/remote/order/order_detail.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/order/load_order_request.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/models/remote/scanned_child.dart';

abstract class OrdersRepo {
  Future<ApiResponse<(List<Order> orders, bool hasMore)>> fetchOrdersForUser(
      int userId, int from, int to);
  Future<ApiResponse<List<OrderDetail>>> fetchOrderDetail(int orderId);
  Future<ApiResponse> deleteOrder(int orderId);
  Future<ApiResponse<int>> startOrder(StartOrderRequest req);
  Future<ApiResponse> postOrderLimitInfo(
      List<ScannedProduct> limitedProducts, String orderId);
  Future<ApiResponse<int>> fetchProductCountInOrder(
    String gtin,
    String orderId,
  );
  Future<ApiResponse<List<ScannedChild>>> fetchScannedChildren(
      String uid, int whOrderId);
  Future<ApiResponse<List<ApiOrder>>> fetchApiOrders(
      String documentCode, CancelToken? cancelToken);
  Future<ApiResponse<(int? orderId, String progress)>> getApiOrderProgress(
      String documentCode);
  Future<ApiResponse<Map<String, int>>> fetchApiOrderProducts(int orderId);
  Future<ApiResponse<List<ScannedProduct>>> fetchOrderProducts(int orderId);
  Future<ApiResponse<bool>> isOrderCompleted(int orderId);
}
