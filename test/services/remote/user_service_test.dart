import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/user.dart';
import 'package:warehouse_amf/models/remote/validate_user_response.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/remote/user/user_service.dart';
import 'package:warehouse_amf/utils/consts/address.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

import '../../mock/mocked_services.dart';

void main() {
  group('UserService', () {
    late Dio mockDio;
    late UserService userService;
    late LogRepo mockLogService;

    setUpAll(() {
      mockDio = MockDio();
      mockLogService = FakeLogRepo();
      userService = UserService(dio: mockDio, logRepo: mockLogService);

      registerFallbackValue(Log(date: DateTime.now(), desc: ''));
    });

    tearDown(() {});

    test('validateUser with failed http request', () async {
      // Arrange
      when(() => mockDio.post(kApiUserValidation, data: any(named: 'data')))
          .thenThrow(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
          ),
        ),
      );
      // Act
      final result = await userService.validateUser('username', 'password');

      // Assert
      expect(result, isA<ApiResponseFailed>());
    });

    test('validateUser with incorrect credentials', () async {
      // Arrange
      when(() => mockDio.post(kApiUserValidation, data: any(named: 'data')))
          .thenAnswer(
        (invocation) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(),
          data: [
            {"result": "notfound"},
          ],
        ),
      );
      // Act
      final result = await userService.validateUser('username', 'password');

      // Assert
      expect(result, isA<ApiResponseFailed>());
      expect((result as ApiResponseFailed).message,
          Translations.wrongUserNameOrPassword.name);
    });

    test('validateUser with correct credentials', () async {
      // Arrange
      when(() => mockDio.post(kApiUserValidation, data: any(named: 'data')))
          .thenAnswer(
        (invocation) async =>
            Response(statusCode: 200, requestOptions: RequestOptions(), data: [
          {
            "id": 54,
            "fname": "سروش",
            "lname": "پناهي",
            "username": "p",
            "password": "541",
            "phone": "09851527652",
            "createdAt": "2024-08-31T10:27:09.150Z",
            "updatedAt": "2024-08-31T10:27:09.150Z",
            "is_active": null,
            "company_nid": "10100651897",
            "companyName": "فیروز",
            "accepter_user_id": null,
            "result": "ok"
          },
          {
            "token": "5.45.85",
          }
        ]),
      );
      // Act
      final result = await userService.validateUser('username', 'password');

      // Assert
      expect(result, isA<ApiResponseSucceeded>());
      expect(
        ((result as ApiResponseSucceeded).values as ValidateUserResponse)
            .user
            .hashCode,
        User(
          id: 54,
          fname: "سروش",
          lname: "پناهي",
          username: "p",
          phone: "09851527652",
          companyNid: "10100651897",
          companyName: "فیروز",
        ).hashCode,
      );
    });
  });
}
