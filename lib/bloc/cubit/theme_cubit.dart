import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final AppConfigRepo _configRepo;

  ThemeCubit({AppConfigRepo? configRepo})
      : _configRepo = configRepo ?? LocalServices.appConfigRepo,
        super(DarkTheme()) {
    var config = _configRepo.fetchConfig();

    if (config.brightness == Brightness.dark) {
      if (state is! DarkTheme) emit(DarkTheme());
    } else {
      if (state is! LightTheme) emit(LightTheme());
    }
  }

  void changeState() {
    if (state is DarkTheme) {
      emit(LightTheme());
      _configRepo.updateConfig(
        AppConfigKey.brightness,
        "light",
      );
    } else {
      emit(DarkTheme());
      _configRepo.updateConfig(
        AppConfigKey.brightness,
        "dark",
      );
    }
  }
}
