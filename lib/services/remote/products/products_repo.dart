import 'package:dio/dio.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/product.dart';

abstract class ProductsRepo {
  Future<ApiResponse<List<Product>>> fetchProducts(
      String query, CancelToken? cancelToken);
  Future<ApiResponse<String>> fetchproductName(String gtin);
  
}
