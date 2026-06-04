import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';

part 'user_role_state.dart';

class UserRoleCubit extends Cubit<UserRoleState> {
  final AppConfigRepo _configRepo;
  final EncryptRepo _encryptRepo;

  UserRoleCubit({AppConfigRepo? configRepo, EncryptRepo? encryptRepo})
      : _configRepo = configRepo ?? LocalServices.appConfigRepo,
        _encryptRepo = encryptRepo ?? LocalServices.encryptRepo,
        super(UserRoleInitial());

  Future updateUserRole(String password) async {
    if (password.isEmpty) {
      emit(UserHasWrongPassword());
    }
    await isValidPassword(password)
        ? emit(UserIsAdmin())
        : emit(UserHasWrongPassword());
  }

  Future<bool> isValidPassword(String password) async {
    if (password.isEmpty) return false;
    var encrpted = await _encryptRepo.enc(password);
    String encPass = encrpted.base64;
    var config = _configRepo.fetchConfig();

    return encPass == config.password;
  }

  void enterAsUser() => emit(UserIsNotAdmin());

  void stopValidating() {
    if (state is UserHasWrongPassword) {
      emit(UserRoleInitial());
    }
  }
}
