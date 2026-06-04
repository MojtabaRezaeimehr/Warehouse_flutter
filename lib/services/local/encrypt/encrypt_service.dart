import 'package:encrypt/encrypt.dart';
import 'package:warehouse_amf/services/local/encrypt/encrypt_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/storage/storage_repo.dart';

class EncryptService extends EncryptRepo {
  //!note: in android and ios key is stored in keyChain and KeyStore
  //!which addes an os level protection but in web the key storage is vulnerable
  //!better approach would be to get KEY and IV from server
  Key? key;
  IV? iv;
  Encrypter? encrypter;
  static EncryptService? instance;

  final StorageRepo _storageRepo;

  factory EncryptService({StorageRepo? storageRepo}) {
    instance ??= EncryptService._pvConstructor(
        storageRepo ?? LocalServices.storageRepo());
    return instance!;
  }

  EncryptService._pvConstructor(this._storageRepo);

  @override
  Future<Encrypted> enc(String val) async {
    key ??= await getKey();
    iv ??= await getIv();
    encrypter ??= Encrypter(AES(key!));
    return encrypter!.encrypt(val, iv: iv!);
  }

  @override
  Future<String?> dyc(String? val) async {
    if (val == null) {
      return null;
    }
    key ??= await getKey();
    iv ??= await getIv();
    encrypter ??= Encrypter(AES(key!));
    return encrypter!.decrypt64(val, iv: iv!);
  }

  @override
  Future<Key> getKey() async {
    if (key != null) {
      return key!;
    }

    String? sKey = await _storageRepo.read("key");

    //in case sKey is null ,the app is running for the -
    //first time hence we need to generate a key and securely save it
    if (sKey == null) {
      key = Key.fromSecureRandom(32);
      await _storageRepo.write("key", key!.base64);
    } else {
      key = Key.fromBase64(sKey);
    }

    return key!;
  }

  @override
  Future<IV> getIv() async {
    if (iv != null) {
      return iv!;
    }

    String? sIv = await _storageRepo.read("IV");

    if (sIv == null) {
      iv = IV.fromSecureRandom(16);
      await _storageRepo.write(
        "IV",
        iv!.base64,
      );
    } else {
      iv = IV.fromBase64(sIv);
    }

    return iv!;
  }
}
