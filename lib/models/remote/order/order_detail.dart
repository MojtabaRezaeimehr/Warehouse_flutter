import 'dart:convert';

class OrderDetail {
  final String uid;
  final int levelId;
  final String productionOrderId;
  final int warehouseOrderId;
  final String productFaName;
  final String createdAt;
  OrderDetail({
    required this.uid,
    required this.levelId,
    required this.productionOrderId,
    required this.warehouseOrderId,
    required this.productFaName,
    required this.createdAt,
  });

  OrderDetail copyWith({
    String? uid,
    int? levelId,
    String? productionOrderId,
    int? warehouseOrderId,
    String? productFaName,
    String? createdAt,
  }) {
    return OrderDetail(
      uid: uid ?? this.uid,
      levelId: levelId ?? this.levelId,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      warehouseOrderId: warehouseOrderId ?? this.warehouseOrderId,
      productFaName: productFaName ?? this.productFaName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uid,
      'levelId': levelId,
      'orderid': productionOrderId,
      'whOrderId': warehouseOrderId,
      'productFrName': productFaName,
      'scanDateTime': createdAt,
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      uid: map['uuid'] as String,
      levelId: int.parse((map['uuid'] as String).substring(5, 6)),
      productionOrderId: map['orderid'] as String,
      warehouseOrderId: map['whOrderId'] as int,
      productFaName: map['productFrName'] as String,
      createdAt: map['scanDateTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderDetail.fromJson(String source) =>
      OrderDetail.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderDetail(uid: $uid, levelId: $levelId, productionOrderId: $productionOrderId, warehouseOrderId: $warehouseOrderId, productFaName: $productFaName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant OrderDetail other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.levelId == levelId &&
        other.productionOrderId == productionOrderId &&
        other.warehouseOrderId == warehouseOrderId &&
        other.productFaName == productFaName &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        levelId.hashCode ^
        productionOrderId.hashCode ^
        warehouseOrderId.hashCode ^
        productFaName.hashCode ^
        createdAt.hashCode;
  }
}
