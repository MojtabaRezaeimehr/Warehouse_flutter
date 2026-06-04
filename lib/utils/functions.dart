import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

void dprint(Object? value) {
  if (kDebugMode) {
    print(value);
  }
}

Future<String> getDeviceId(TargetPlatform platform) async {
  var devInfo = DeviceInfoPlugin();
  if (kIsWeb) {
    var webInfo = await devInfo.webBrowserInfo;
    return webInfo.appCodeName ?? "";
  } else {
    if (platform == TargetPlatform.android) {
      var anInfo = await devInfo.androidInfo;
      return anInfo.id;
    } else if (platform == TargetPlatform.iOS) {
      var iosInfo = await devInfo.iosInfo;
      return iosInfo.identifierForVendor ?? iosInfo.model;
    }
  }
  return "unIdentified";
}

String? getGtinFromBarcode(String barcode) {
  if (isBarcodeValid(barcode)) {
    return "0${barcode.substring(3, 16)}";
  }
  return null;
}

String? getUidFromBarcode(String barcode) {
  if (isBarcodeValid(barcode)) {
    return barcode.substring(18, 38);
  }
  return null;
}

bool isBarcodeValid(String barcode) {
  String pattern =
      '01[0-9]{1}[0-9]{13}21[0-9]{20}17[0-9]{6}10[0-9,A-Z,a-z]{1,20}';
  String manalStatsPattern =
      "01[0-9]{1}[0-9]{13}21[A-Za-z0-9]*17[0-9]{6}10[A-Za-z0-9,]{1,20}";

  RegExp exp = RegExp(pattern);
  RegExp mexp = RegExp(manalStatsPattern);
  if (exp.hasMatch(barcode) || mexp.hasMatch(barcode)) {
    return true;
  }
  return false;
}
