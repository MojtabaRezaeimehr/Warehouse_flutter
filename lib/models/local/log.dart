import 'dart:convert';

import 'package:warehouse_amf/utils/enums/log_level.dart';

class Log {
  final DateTime date;
  final String tag;
  final String desc;
  final LogLevel logLevel;

  Log({
    this.tag = "quick-log",
    this.logLevel = LogLevel.info,
    required this.date,
    required this.desc,
  });

  Map<String, dynamic> toMap() {
    return {
      "date": date.toString(),
      "tag": tag,
      "desc": desc,
      "logLevel": logLevel.name,
    };
  }

  factory Log.fromMap(Map<String, dynamic> json) {
    return Log(
      date: DateTime.parse(json['date']),
      tag: json['tag'],
      desc: json['desc'],
      logLevel: LogLevel.values.firstWhere(
        (element) => element.name == json['logLevel'],
      ),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory Log.fromJson(String json) {
    return Log.fromMap(jsonDecode(json));
  }

  @override
  String toString() {
    return 'Log(date: $date, tag: $tag, desc: $desc, logLevel: $logLevel)';
  }

  @override
  int get hashCode {
    return date.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return date.hashCode == other.hashCode;
  }
}
