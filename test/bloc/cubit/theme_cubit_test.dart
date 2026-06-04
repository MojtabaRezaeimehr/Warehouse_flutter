import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_amf/bloc/cubit/theme_cubit.dart';

import 'package:mocktail/mocktail.dart';
import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';

import '../../mock/mocked_services.dart';


void main() {
  group('Theme cubit -', () {
    late ThemeCubit themeCubit;
    late AppConfigRepo configRepo;

    setUp(() {
      configRepo = MockAppConfigRepo();
      when(() => configRepo.fetchConfig()).thenReturn(
        AppConfig(
            brightness: Brightness.dark,
            password: '',
            fontSize: '',
            baseUrl: '',
            labelSize: '',
            inentAction: '',
            intentDataKey: ''),
      );

      themeCubit = ThemeCubit(configRepo: configRepo);
    });
    tearDown(() {
      themeCubit.close();
    });

    test('initial state', () {
      // Arrange
      //done in setup
      // Act
      //done in setup
      // Assert
      expect(themeCubit.state, isA<DarkTheme>());
    });

    test('swicth theme', () {
      // Arrange
      when(()=> configRepo.updateConfig( AppConfigKey.brightness, "light")).thenAnswer((_) async {});
      // Act
      themeCubit.changeState();
      // Assert
      expect(themeCubit.state, isA<LightTheme>());
    });
  });
}
