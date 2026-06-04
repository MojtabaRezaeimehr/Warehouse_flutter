import 'package:flutter/foundation.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_service.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_repo.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_service.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/local/log/log_service.dart';
import 'package:warehouse_amf/services/local/scanned_history/scanned_history_repo.dart';
import 'package:warehouse_amf/services/local/scanned_history/scanned_history_service.dart';
import 'package:warehouse_amf/services/local/storage/hive_storage.dart';
import 'package:warehouse_amf/services/local/storage/secure_storage.dart';
import 'package:warehouse_amf/services/local/storage/storage_repo.dart';

class LocalServices {
  static final EncryptRepo encryptRepo = EncryptService();
  static final AppConfigRepo appConfigRepo = AppConfigService();
  static final LogRepo logRepo = LogService();
  static final ScannedHistoryRepo scannedHistoryRepo = ScannedHistoryService();
  static StorageRepo storageRepo() {
    if (!kIsWeb) {
      return SecureStorage();
    }
    return HiveStorage();
  }
}
