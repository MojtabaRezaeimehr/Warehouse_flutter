import 'package:encrypt/encrypt.dart';

abstract class EncryptRepo {
  Future<Encrypted>  enc(String val);
  Future<String?> dyc(String? val);
  Future<Key> getKey();
  Future<IV> getIv();
}
