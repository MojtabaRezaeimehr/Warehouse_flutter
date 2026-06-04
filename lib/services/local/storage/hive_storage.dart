import 'package:hive_flutter/hive_flutter.dart';
import 'package:warehouse_amf/services/local/storage/storage_repo.dart';
import 'package:warehouse_amf/utils/consts/default_values.dart';

class HiveStorage extends StorageRepo {
  static HiveStorage? instance;
  static Box? storage;

  factory HiveStorage() {
    storage ??= Hive.box(kDefualtHiveBox);
    instance ??= HiveStorage._pvConstructor();

    return instance!;
  }

  HiveStorage._pvConstructor();

  @override
  Future<String?> read(String key) async {
    return await storage!.get(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map<String, String>.from(storage!.toMap());
  }

  @override
  write(String key, String value) async {
    await storage!.put(key, value);
  }

  @override
  delete(String key) async {
    await storage!.delete(key);
  }
}
