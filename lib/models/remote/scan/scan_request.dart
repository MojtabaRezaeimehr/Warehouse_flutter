import 'package:warehouse_amf/utils/enums/order_types.dart';

class ScanRequest {
  final String barcode;
  final String uid;
  final String orderId;
  final String state;
  final String userId;
  final OrderTypes orderType;
  String? deviceId;
  final bool forceUpdate; //this field is only for returning orders

  ScanRequest({
    required this.barcode,
    required this.uid,
    required this.orderId,
    required this.state,
    required this.userId,
    required this.orderType,
    this.forceUpdate = false,
  });

  ScanRequest copyWith({
    String? uid,
    String? barcode,
    String? orderId,
    String? state,
    String? userId,
    OrderTypes? orderType,
  }) {
    return ScanRequest(
      barcode: uid ?? this.barcode,
      orderId: orderId ?? this.orderId,
      state: state ?? this.state,
      userId: userId ?? this.userId,
      orderType: orderType ?? this.orderType,
      uid: this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uid,
      'favoritecode': orderId,
      'state': state,
      'userid': userId,
      'orderType': orderType.name,
      "deviceId": deviceId,
      'checkTheFollow': "true",
      "forceUpdate": forceUpdate
    };
  }

  @override
  String toString() {
    return 'ScanRequest(barcode: $barcode, orderId: $orderId, isAddingState: $state, userId: $userId, orderType: ${orderType.name})';
  }

  @override
  bool operator ==(covariant ScanRequest other) {
    if (identical(this, other)) return true;

    return other.barcode == barcode &&
        other.orderId == orderId &&
        other.state == state &&
        other.userId == userId &&
        other.orderType == orderType;
  }

  @override
  int get hashCode {
    return barcode.hashCode ^
        orderId.hashCode ^
        state.hashCode ^
        userId.hashCode ^
        orderType.hashCode;
  }
}
