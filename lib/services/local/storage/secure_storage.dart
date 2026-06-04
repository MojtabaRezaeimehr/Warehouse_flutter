import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warehouse_amf/services/local/storage/storage_repo.dart';

class SecureStorage extends StorageRepo {
  static SecureStorage? instance;

  static FlutterSecureStorage? storage;
  //This allows us to be able to fetch secure values while the app is backgrounded on ios,
  //pass this ios opt while wrting into storage
  static const iosOptions =
      IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  //enable encrypt in android
  static const androidOptions =
      AndroidOptions(encryptedSharedPreferences: true);
  static const WebOptions webOptions = WebOptions();

  factory SecureStorage() {
    storage ??= const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
      webOptions: webOptions,
    );
    instance ??= SecureStorage._pvConstructor();

    return instance!;
  }

  SecureStorage._pvConstructor();

  @override
  Future<String?> read(String key) async {
    return await storage!.read(
      key: key,
      aOptions: androidOptions,
      iOptions: iosOptions,
      webOptions: webOptions,
    );
  }

  @override
  Future<Map<String, String>> readAll() async {
    return await storage!.readAll(
      aOptions: androidOptions,
      iOptions: iosOptions,
      webOptions: webOptions,
    );
  }

  @override
  write(String key, String value) async {
    await storage!.write(key: key, value: value);
  }

  @override
  delete(String key) async {
    await storage!.delete(key: key);
  }
}
