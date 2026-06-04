// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';

class Order {
  final int id;
  final int scannedCount;
  final Company? distributer;
  //api orders(those were started by firooz powerbi t3)
  //have documentation No
  final String? documentNo;
  final DateTime date; // add this field
  final OrderTypes orderType; // add this field
  Order({
    required this.id,
    required this.scannedCount,
    required this.distributer,
    this.documentNo,
    required this.date,
    required this.orderType,
  });

  Order copyWith({
    int? id,
    int? totalCount,
    Company? distributer,
    String? documentNo,
    DateTime? date,
    OrderTypes? orderType,
  }) {
    return Order(
      id: id ?? this.id,
      scannedCount: totalCount ?? scannedCount,
      distributer: distributer ?? this.distributer,
      documentNo: documentNo ?? this.documentNo,
      date: date ?? this.date,
      orderType: orderType ?? this.orderType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'totalCount': scannedCount,
      'distributer': distributer?.toMap(),
      'documentNo': documentNo,
      'date': date.millisecondsSinceEpoch,
      'orderType': orderType.name,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['OrderId'] as int,
      scannedCount: map['scannedCount'] as int,
      distributer: map['DistributerCompanyNid'] != null
          ? Company.fromMap({
              'id': "-1",
              'companyfaname': map['distributerCompanyName'],
              'nationalid': map['DistributerCompanyNid'],
            })
          : null,
      documentNo:
          map['documentCode'] != null ? map['documentCode'] as String : null,
      date: DateTime.parse(map['createdAt']),
      orderType: OrderTypes.values.firstWhere(
        (element) => element.name == map['ordertype'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, totalCount: $scannedCount, distributer: $distributer, documentNo: $documentNo, date: $date, orderType: $orderType)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.scannedCount == scannedCount &&
        other.distributer == distributer &&
        other.documentNo == documentNo &&
        other.date == date &&
        other.orderType == orderType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        scannedCount.hashCode ^
        distributer.hashCode ^
        documentNo.hashCode ^
        date.hashCode ^
        orderType.hashCode;
  }
}
