import 'dart:convert';
import 'package:warehouse_amf/models/remote/product.dart';

class ScannedProduct {
  final Product product;
  final int scanQuantity;
  final int? maxScanQuantity;
  ScannedProduct({
    required this.product,
    required this.scanQuantity,
    this.maxScanQuantity,
  });

  ScannedProduct copyWith({
    Product? product,
    int? scanQuantity,
    int? maxScanQuantity,
  }) {
    return ScannedProduct(
      product: product ?? this.product,
      scanQuantity: scanQuantity ?? this.scanQuantity,
      maxScanQuantity: maxScanQuantity ?? this.maxScanQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gtin': product.gtin,
      'scanQuantity': scanQuantity,
      'maxlimit': maxScanQuantity,
    };
  }

  Map<String, dynamic> toMapWithOrderId(String orderId) {
    return <String, dynamic>{
      'gtin': product.gtin,
      "whorderid": orderId,
      'maxlimit': maxScanQuantity,
    };
  }

  factory ScannedProduct.fromMap(Map<String, dynamic> map) {
    return ScannedProduct(
      product: Product.fromMap(map['product'] as Map<String, dynamic>),
      scanQuantity: map['scanQuantity'] as int,
      maxScanQuantity: map['maxQuantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScannedProduct.fromJson(String source) =>
      ScannedProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ProductLimit(product: $product, scanQuantity: $scanQuantity, maxQuantity: $maxScanQuantity)';

  @override
  bool operator ==(covariant ScannedProduct other) {
    if (identical(this, other)) return true;

    return other.product == product &&
        other.scanQuantity == scanQuantity &&
        other.maxScanQuantity == maxScanQuantity;
  }

  @override
  int get hashCode =>
      product.hashCode ^ scanQuantity.hashCode ^ maxScanQuantity.hashCode;
}
