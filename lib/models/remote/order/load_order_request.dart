import 'dart:convert';

import 'package:warehouse_amf/utils/enums/order_types.dart';

class StartOrderRequest {
  final bool isOrderApi;
  final String? documentNo;
  final String orderid;
  final bool isNewOrder;
  final String distributerNid;
  final int quantity;
  final OrderTypes orderType;
  final String details;
  final String deviceId;
  final String userId;
  StartOrderRequest({
    required this.isOrderApi,
    this.documentNo,
    required this.orderid,
    required this.isNewOrder,
    required this.distributerNid,
    required this.quantity,
    required this.orderType,
    required this.details,
    required this.deviceId,
    required this.userId,
  });

  StartOrderRequest copyWith({
    bool? isOrderApi,
    String? documentNo,
    String? orderid,
    bool? isNewOrder,
    String? distributerNid,
    int? quantity,
    OrderTypes? orderType,
    String? details,
    String? userId,
    String? deviceId
  }) {
    return StartOrderRequest(
      isOrderApi: isOrderApi ?? this.isOrderApi,
      documentNo: documentNo ?? this.documentNo,
      orderid: orderid ?? this.orderid,
      isNewOrder: isNewOrder ?? this.isNewOrder,
      distributerNid: distributerNid ?? this.distributerNid,
      quantity: quantity ?? this.quantity,
      orderType: orderType ?? this.orderType,
      details: details ?? this.details,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isOrderApi': isOrderApi,
      'documentNo': documentNo,
      'orderid': orderid,
      'isNewOrder': isNewOrder,
      'distributernid': distributerNid,
      'qty': quantity,
      'orderType': orderType.name,
      'details': details,
      'deviceId':deviceId,
      'userid': userId,
    };
  }
  

  factory StartOrderRequest.fromMap(Map<String, dynamic> map) {
    return StartOrderRequest(
      isOrderApi: map['isOrderApi'] as bool,
      documentNo:
          map['documentNo'] != null ? map['documentNo'] as String : null,
      orderid: map['orderid'] as String,
      isNewOrder: map['isNewOrder'] as bool,
      distributerNid: map['distributerNid'] as String,
      quantity: map['quantity'] as int,
      orderType: OrderTypes.values.firstWhere(
        (element) => element.name == map['orderType'],
      ),
      details: map['details'] as String,
      userId: map['userId'] as String,
      deviceId: map['deviceId']
    );
  }

  String toJson() => json.encode(toMap());

  factory StartOrderRequest.fromJson(String source) =>
      StartOrderRequest.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LoadUserRequest(isOrderApi: $isOrderApi, documentNo: $documentNo,deviceId: $deviceId, orderid: $orderid, isNewOrder: $isNewOrder, distributerNid: $distributerNid, quantity: $quantity, orderType: $orderType, details: $details, userId: $userId)';
  }

  @override
  bool operator ==(covariant StartOrderRequest other) {
    if (identical(this, other)) return true;

    return other.isOrderApi == isOrderApi &&
        other.documentNo == documentNo &&
        other.orderid == orderid &&
        other.isNewOrder == isNewOrder &&
        other.distributerNid == distributerNid &&
        other.quantity == quantity &&
        other.orderType == orderType &&
        other.details == details &&
        other.deviceId == deviceId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return isOrderApi.hashCode ^
        documentNo.hashCode ^
        orderid.hashCode ^
        isNewOrder.hashCode ^
        distributerNid.hashCode ^
        quantity.hashCode ^
        orderType.hashCode ^
        details.hashCode ^
        deviceId.hashCode ^
        userId.hashCode;
  }
}
