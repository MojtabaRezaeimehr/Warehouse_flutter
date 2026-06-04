import 'package:flutter/material.dart' show Brightness;
import 'package:warehouse_amf/utils/consts/default_values.dart';
import '../../utils/enums/app_config_key.dart';

//!if any property was modified or added
//! remember to update appConfigkey enum accordingly
class AppConfig {
  Brightness brightness;
  String?
      token; //it is better to save token in keystore and keychain than in global var
  String password;
  String baseUrl;
  String fontSize;
  String labelSize; //width of label in mm
  String inentAction;
  String intentDataKey;
  AppConfig({
    this.token,
    required this.brightness,
    required this.password,
    required this.baseUrl,
    required this.fontSize,
    required this.labelSize,
    required this.inentAction,
    required this.intentDataKey,
  });

  //!update this method with every changes made to Appconfig fields
  static AppConfig updateWithKeyValue(
    AppConfigKey key,
    dynamic value,
    AppConfig oldConfig,
  ) {
    switch (key) {
      case AppConfigKey.brightness:
        oldConfig.brightness = value == "light" ? Brightness.light : Brightness.dark;
      case AppConfigKey.token:
        oldConfig.token = value;
      case AppConfigKey.password:
        oldConfig.password = value;
      case AppConfigKey.baseUrl:
       oldConfig.baseUrl = value;
      case AppConfigKey.fontSize:
        oldConfig.fontSize = value;
      case AppConfigKey.labelSize:
        oldConfig.labelSize = value;
      case AppConfigKey.inentAction:
        oldConfig.inentAction = value;
      case AppConfigKey.intentDataKey:
        oldConfig.intentDataKey = value;
    }
    return oldConfig;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'brightness': brightness.name,
      'token': token,
      'password': password,
      'baseUrl': baseUrl,
      'fontSize': fontSize,
      'labelSize': labelSize,
      'inentAction': inentAction,
      'intentDataKey': intentDataKey,
    };
  }

  factory AppConfig.fromMap(var map) {
    return AppConfig(
      brightness: Brightness.values.firstWhere(
        (element) =>
            element.name == (map['brightness'] ?? Brightness.dark.name),
      ),
      token: map['token'],
      password: map['password'],
      baseUrl: map['baseUrl'] ?? kDefaultBaseAddress,
      fontSize: map['fontSize'] ?? kDefaultFontSize,
      labelSize: map['labelSize'] ?? kDefaultLabelSize,
      inentAction: map['inentAction'] ?? kDefaultIntentAction,
      intentDataKey: map['intentDataKey'] ?? kDefaultIntentDataKey,
    );
  }

  @override
  String toString() {
    return "AppConfig(brightness: ${brightness.name}, token: $token,"
    " password: $password, baseUrl: $baseUrl, fontSize: $fontSize,"
    " labelSize: $labelSize,inentAction : $inentAction, intentDataKey : $intentDataKey)";
  }

  @override
  bool operator ==(covariant AppConfig other) {
    if (identical(this, other)) return true;

    return other.brightness == brightness &&
        other.token == token &&
        other.password == password &&
        other.baseUrl == baseUrl &&
        other.fontSize == fontSize &&
        other.inentAction == inentAction &&
        other.intentDataKey == intentDataKey &&
        other.labelSize == labelSize;
  }

  @override
  int get hashCode {
    return brightness.hashCode ^
        token.hashCode ^
        password.hashCode ^
        baseUrl.hashCode ^
        fontSize.hashCode ^
        inentAction.hashCode ^
        intentDataKey.hashCode ^
        labelSize.hashCode;
  }
}
