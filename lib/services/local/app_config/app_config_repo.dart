import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';

abstract class AppConfigRepo {
  AppConfig fetchConfig();
  Future<void> ensureInitialization();
  Future<void> updateConfig(AppConfigKey key, String value);
}
