import 'package:dio/dio.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/company.dart';

abstract class CompaniesRepo {
  Future<ApiResponse<List<Company>>> fetchCompanies(String query,CancelToken? cancelToken);
}
