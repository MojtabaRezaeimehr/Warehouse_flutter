import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/remote/dio_initializer.dart';
import 'package:warehouse_amf/services/remote/user/user_repo.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/user.dart';
import 'package:warehouse_amf/models/remote/validate_user_response.dart';
import 'package:warehouse_amf/utils/consts/address.dart';
import 'package:warehouse_amf/utils/enums/log_level.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class UserService extends UserRepo {
  final Dio _dio;
  final LogRepo _logRepo;

  static UserService? instance;

  factory UserService({
    Dio? dio,
    LogRepo? logRepo,
  }) {
    instance ??= UserService._pvConstructor(
      dio ?? DioInitializer.getInstance(),
      logRepo ?? LocalServices.logRepo,
    );
    return instance!;
  }

  UserService._pvConstructor(this._dio, this._logRepo);

  @override
  Future<ApiResponse<ValidateUserResponse>> validateUser(
      String username, String password) async {
    try {
      _logRepo.quickLog("validating user...");

      var response = await _dio.post(
        kApiUserValidation,
        data: {"username": username, "password": password},
      );

      _logRepo.quickLog("kApiUserValidation got response");

      int code = response.statusCode ?? -1;

      if (code >= 200 && code < 300) {
        if (response.data[0]["result"] == "ok") {
          //create a new user instance
          User user = User.fromJson(response.data[0]);
          return ApiResponseSucceeded(
            values: ValidateUserResponse(
              user: user,
              token: response.data[1]["token"],
            ),
          );
        } else if (response.data[0]["result"] == "notfound") {
          return ApiResponseFailed(
              message: Translations.wrongUserNameOrPassword.name.tr());
        }
      }

      return ApiResponseFailed(
        message: response.statusMessage.toString(),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
            desc: "validating user failed! $e",
            tag: "API",
            logLevel: LogLevel.error),
      );
      return ApiResponseFailed(message: e.toString());
    }
  }
}
