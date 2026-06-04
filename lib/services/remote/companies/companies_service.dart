import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/remote/companies/companies_repo.dart';
import 'package:warehouse_amf/services/remote/dio_initializer.dart';
import 'package:warehouse_amf/utils/consts/address.dart';
import 'package:warehouse_amf/utils/enums/log_level.dart';

class CompaniesService extends CompaniesRepo {
  final Dio _dio;
  final LogRepo _logRepo;

  static CompaniesService? instance;

  factory CompaniesService({Dio? dio,LogRepo? logRepo,}) {
    instance ??= CompaniesService._pvConstructor(
      dio ?? DioInitializer.getInstance(),
      logRepo ?? LocalServices.logRepo,
    );
    return instance!;
  }

  CompaniesService._pvConstructor(this._dio, this._logRepo);

  @override
  Future<ApiResponse<List<Company>>> fetchCompanies(
      String query, CancelToken? cancelToken) async {
    try {
      _logRepo.quickLog("fetching companies from server...");

      var response = await _dio.get(
        kApiFetchingCompanies,
        cancelToken: cancelToken,
        queryParameters: {
          "companyfaname": query,
        },
      );

      _logRepo.quickLog("kApiFetchingCompanies got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        //since size of return ed companies maybe too large
        //islate is used
        var companies = await compute((dynamic data) {
          List<Company> companies = [];
          for (var element in (data as List)) {
            companies.add(Company.fromMap(element));
          }
          return companies;
        }, response.data);

        return ApiResponseSucceeded(values: companies);
      } else {
        _logRepo.logThis(
          Log(
              date: DateTime.now(),
              desc:
                  "fecthing comapnies failed! ${response.statusMessage} $code",
              tag: "API",
              logLevel: LogLevel.error),
        );
        return ApiResponseFailed(
            message: "failed to get companies", statusCode: code);
      }
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "fecthing comapnies failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );

      return ApiResponseFailed(message: e.toString());
    }
  }
}
