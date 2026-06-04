import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/storage/storage_repo.dart';
import 'package:warehouse_amf/utils/consts/default_values.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';

class AppConfigService extends AppConfigRepo {
  final StorageRepo _storageRepo;
  final EncryptRepo _encryptRepo;

  static AppConfigService? instance;
  //this config is initalized duering ensureInitialization and updated-
  //when updateConfig is called
  //It would have been more secure if token was fecthed just in time in 
  //remote services but since reading from secure storage is async and -
  //time consuming with every fetch we just saved a reference here and
  //updated it along the real data in secure storage
  late AppConfig _appConfig;

  factory AppConfigService(
      {StorageRepo? storageRepo, EncryptRepo? encryptRepo}) {
    instance ??= AppConfigService._pvConstructor(
      storageRepo ?? LocalServices.storageRepo(),
      encryptRepo ?? LocalServices.encryptRepo,
    );
    return instance!;
  }

  AppConfigService._pvConstructor(this._storageRepo, this._encryptRepo);

  @override
  AppConfig fetchConfig() {
    return _appConfig;
  }

  @override
  Future<void> ensureInitialization() async {
    var data = await _storageRepo.readAll();
    if (data["password"] == null) {
      var encrpted = await _encryptRepo.enc(kDefualtPassword);
      data.addAll({"password": encrpted.base64});
    }
    _appConfig = AppConfig.fromMap(data);
  }

  @override
  Future<void> updateConfig(AppConfigKey key, String value) async {
    //encrypt password and token
    var encodedVal = value;
    if (key == AppConfigKey.password || key == AppConfigKey.token) {
      var encrpted = await _encryptRepo.enc(value.toString());

      encodedVal = encrpted.base64;
    }
    _appConfig = AppConfig.updateWithKeyValue(key, encodedVal, _appConfig);
    await _storageRepo.write(key.name, encodedVal);
  }
}
