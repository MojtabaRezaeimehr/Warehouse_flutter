import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/models/remote/order/api_order_item.dart';

class ApiOrder {
  final String documentCode;
  final DateTime createdAt;
  final Company distributer;
  final String province;
  final String city;
  final List<ApiOrderItem> items;
  ApiOrder({
    required this.documentCode,
    required this.createdAt,
    required this.distributer,
    required this.province,
    required this.city,
    required this.items,
  });

  ApiOrder copyWith({
    String? documentCode,
    DateTime? createdAt,
    Company? distributer,
    int? quantity,
    String? province,
    String? city,
    List<ApiOrderItem>? items,
  }) {
    return ApiOrder(
      documentCode: documentCode ?? this.documentCode,
      createdAt: createdAt ?? this.createdAt,
      distributer: distributer ?? this.distributer,
      province: province ?? this.province,
      city: city ?? this.city,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'documentCode': documentCode,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'distributer': distributer.toMap(),
      'province': province,
      'city': city,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory ApiOrder.fromMap(Map<String, dynamic> map) {
    return ApiOrder(
      documentCode: map['documentCode'] as String,
      createdAt: DateTime.parse(map['RefreshDate']),
      distributer: Company(
        id: "-1",
        name:
            (map['api_CounterpartEntityText'] as String?) ?? (map['CompanyFaName'] as String),
        nid:   (map['api_c_number'] as String?) ?? (map['NationalId'] as String),
      ),
      province: map['province'] as String,
      city: map['city'] as String,
      items: List<ApiOrderItem>.from(
        (map['items'] as List).map<ApiOrderItem>(
          (x) => ApiOrderItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiOrder.fromJson(String source) =>
      ApiOrder.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ApiOrder(documentCode: $documentCode, createdAt: $createdAt, distributer: $distributer, province: $province, city: $city, items: $items)';
  }

  @override
  bool operator ==(covariant ApiOrder other) {
    if (identical(this, other)) return true;

    return other.documentCode == documentCode &&
        other.createdAt == createdAt &&
        other.distributer == distributer &&
        other.province == province &&
        other.city == city &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode {
    return documentCode.hashCode ^
        createdAt.hashCode ^
        distributer.hashCode ^
        province.hashCode ^
        city.hashCode ^
        items.hashCode;
  }
}
