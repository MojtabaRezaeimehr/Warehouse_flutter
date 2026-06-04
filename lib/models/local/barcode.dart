
import 'dart:convert';

import 'package:warehouse_amf/utils/enums/scan_responses.dart';
import 'package:warehouse_amf/utils/enums/scan_type.dart';

class Barcode {
  String value;
  ScanType scanType;
  ScanResponses scanResponse;
  DateTime scanDate;
  Barcode({
    required this.value,
    required this.scanType,
    required this.scanResponse,
    required this.scanDate,
  });

  Barcode copyWith({
    String? value,
    ScanType? scanType,
    ScanResponses? scanResponse,
    DateTime? scanDate,
  }) {
    return Barcode(
      value: value ?? this.value,
      scanType: scanType ?? this.scanType,
      scanResponse: scanResponse ?? this.scanResponse,
      scanDate: scanDate ?? this.scanDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'value': value,
      'scanType': scanType.name,
      'scanResponse':scanResponse.name,
      'scanDate': scanDate.toString(),
    };
  }

  factory Barcode.fromMap(Map<String, dynamic> map) {
    return Barcode(
      value: map['value'] as String,
      scanType: ScanType.values.firstWhere(
        (element) => element.name == map['scanType'],
      ),
      scanResponse: ScanResponses.values.firstWhere(
        (element) => element.name == map['scanResponse'],
      ),
      scanDate: DateTime.parse(map['scanDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Barcode.fromJson(String source) =>
      Barcode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Barcode(value: $value, scanType: $scanType,scanResponse: $scanResponse, scanDate: $scanDate)';

  @override
  bool operator ==(covariant Barcode other) {
    if (identical(this, other)) return true;

    return other.value == value &&
        other.scanType == scanType &&
        other.scanResponse == scanResponse &&
        other.scanDate == scanDate;
  }

  @override
  int get hashCode => value.hashCode ^ scanType.hashCode ^ scanDate.hashCode ^ scanResponse.hashCode;
}
