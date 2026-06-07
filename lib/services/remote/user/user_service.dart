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
        // Ensure response.data is a List and has at least two elements
        if (response.data is List && response.data.length >= 2) {
          // Check the user data part first
          if (response.data[0] is Map && response.data[0]["result"] == "ok") {
          //create a new user instance
          User user = User.fromJson(response.data[0]);

            // Now, check the token part (response.data[1])
            var tokenData = response.data[1];
            if (tokenData is Map && tokenData.containsKey("token")) {
              var token = tokenData["token"];
              // Check if the token itself is a String
              if (token is String) {
          return ApiResponseSucceeded(
                  values: ValidateUserResponse(user: user, token: token),
                );
              } else {
                // The token field is not a String, it's likely an error object
                var errorMessage = token is Map && token.containsKey('message')
                    ? token['message']?.toString() ?? 'Unknown token error'
                    : 'Invalid token format received';
      _logRepo.logThis(
        Log(
            date: DateTime.now(),
                      desc: "API returned invalid token format: $token",
            tag: "API",
                      logLevel: LogLevel.warning),
      );
                return ApiResponseFailed(message: errorMessage);
    }
            } else {
              // 'token' key not found in the second element (response.data[1])
              _logRepo.logThis(
                Log(
                    date: DateTime.now(),
                    desc: "API response missing 'token' key in second element",
                    tag: "API",
                    logLevel: LogLevel.warning),
              );
              return ApiResponseFailed(
                  message: "Login successful, but token is missing.");
  }
          } else if (response.data[0] is Map && response.data[0]["result"] == "notfound") {
            return ApiResponseFailed(
                message: Translations.wrongUserNameOrPassword.name.tr());
          } else {
            // Handle cases where response.data[0] is not a Map or result is unexpected
            _logRepo.logThis(
              Log(
                  date: DateTime.now(),
                  desc: "API returned unexpected format for user data",
                  tag: "API",
                  logLevel: LogLevel.warning),
            );
            return ApiResponseFailed(message: "Unexpected user data format.");
}
        } else {
          // Handle cases where response.data is not a List or has incorrect length
          _logRepo.logThis(
            Log(
                date: DateTime.now(),
                desc: "API response data is not a List or has incorrect length",
                tag: "API",
                logLevel: LogLevel.warning),
          );
          return ApiResponseFailed(message: "Unexpected API response structure.");
        }
      }

      // Handle non-2xx status codes
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
      // Also log the structure of e if it's a DioError for more details
      if (e is DioError) {
        _logRepo.logThis(
          Log(
              date: DateTime.now(),
              desc: "DioError details: ${e.response?.data ?? e.message}",
              tag: "API",
              logLevel: LogLevel.error),
        );
      }
      return ApiResponseFailed(message: e.toString());
    }
  }
}

