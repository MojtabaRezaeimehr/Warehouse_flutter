abstract class StorageRepo {
  Future<String?> read(String key);
  Future<Map<String, String>> readAll();
  write(String key, String value);
  delete(String key);
}
