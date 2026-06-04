import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/validate_user_response.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/remote/user/user_repo.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';

import '../../mock/mocked_objects.dart';
import '../../mock/mocked_services.dart';

void main() {
  late UserAuthCubit userAuthCubit;
  late UserRepo userRepo;
  late AppConfigRepo appConfigRepo;

  group('UserAuthCubit -', () {
    setUpAll(() {
      userRepo = MockUserRepo();
      appConfigRepo = MockAppConfigRepo();

      registerFallbackValue(AppConfigKey.brightness);
      when(() => appConfigRepo.updateConfig(any(), any()))
          .thenAnswer((_) async {});
    });

    setUp(() {
      userAuthCubit =
          UserAuthCubit(userRepo: userRepo, configRepo: appConfigRepo);
    });

    tearDown(() {
      userAuthCubit.close();
    });

    test('initial state', () {
      expect(userAuthCubit.state, UserStateInitial());
    });

    test('validateUser with empty username and password', () async {
      await userAuthCubit.validateUser('', '');
      expect(userAuthCubit.state, isA<UserUnAuthorized>());
    });

    test('validateUser with invalid credentials', () async {
      when(() => userRepo.validateUser(any(), any())).thenAnswer((_) async {
        return ApiResponseFailed<ValidateUserResponse>(
            statusCode: 401, message: 'invalid_credentials');
      });
      await userAuthCubit.validateUser('username', 'password');
      expect(
        userAuthCubit.state,
        isA<UserUnAuthorized>(),
      );
    });

    test('validateUser with valid credentials', () async {
      when(() => userRepo.validateUser(any(), any())).thenAnswer(
        (_) async => ApiResponseSucceeded<ValidateUserResponse>(
          values: ValidateUserResponse(
            user: mockUser,
            token: "token",
          ),
        ),
      );
      await userAuthCubit.validateUser('username', 'password');
      expect(userAuthCubit.state, isA<UserAuthorized>());
    });
  });
}

