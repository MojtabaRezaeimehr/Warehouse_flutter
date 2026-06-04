import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/user.dart';
import 'package:warehouse_amf/models/remote/validate_user_response.dart';
import 'package:warehouse_amf/services/remote/user/user_repo.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

import '../../utils/enums/app_config_key.dart';

part 'user_auth_state.dart';

class UserAuthCubit extends Cubit<UserAuthState> {
  final AppConfigRepo _configRepo;
  final UserRepo _userRepo;

  UserAuthCubit({AppConfigRepo? configRepo, UserRepo? userRepo})
      : _configRepo = configRepo ?? LocalServices.appConfigRepo,
        _userRepo = userRepo ?? RemoteServices.userRepo,
        super(UserStateInitial());

  Future<void> validateUser(String username, String password) async {
    //username and pass can not be empty
    if (username.isEmpty || password.isEmpty) {
      emit(
        UserUnAuthorized(
          message: Translations.fillAllFields.name.tr(),
          code: -1,
          date: DateTime.now(),
        ),
      );
      return;
    }
    var response = await _userRepo.validateUser(username, password);
    if (response is ApiResponseSucceeded) {
      var castedResp = (response as ApiResponseSucceeded<ValidateUserResponse>);
      //encrypt and save token
      _configRepo.updateConfig(AppConfigKey.token, castedResp.values!.token);
      emit(UserAuthorized(user: castedResp.values!.user));
    } else {
      var castedResp = (response as ApiResponseFailed<ValidateUserResponse>);
      emit(
        UserUnAuthorized(
          message: castedResp.message,
          code: castedResp.statusCode,
          date: DateTime.now(),
        ),
      );
    }
  }
}
