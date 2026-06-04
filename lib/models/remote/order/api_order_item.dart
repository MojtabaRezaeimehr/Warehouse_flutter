import 'dart:convert';
import 'package:warehouse_amf/models/remote/product.dart';

class ApiOrderItem {
  final Product product;
  final int quantity;
  ApiOrderItem({
    required this.product,
    required this.quantity,
  });

  ApiOrderItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return ApiOrderItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory ApiOrderItem.fromMap(Map<String, dynamic> map) {
    return ApiOrderItem(
      product: Product(
        id: "-1",
        name: (map['ProductFrName'] as String?) ?? map['api_Name'] as String,
        gtin: (map['GTIN'] as String?) ?? map['api_code'] as String,
      ),
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiOrderItem.fromJson(String source) =>
      ApiOrderItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ApiOrder( product: ${product.toMap()},quantity: $quantity)';
  }

  @override
  bool operator ==(covariant ApiOrderItem other) {
    if (identical(this, other)) return true;

    return other.product == product && other.quantity == quantity;
  }

  @override
  int get hashCode {
    return product.hashCode ^ quantity.hashCode;
  }
}
