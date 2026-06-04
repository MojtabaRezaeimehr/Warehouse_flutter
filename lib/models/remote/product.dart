import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String gtin;
  Product({
    required this.id,
    required this.name,
    required this.gtin,
  });

  Product copyWith({
    String? id,
    String? name,
    String? gtin,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      gtin: gtin ?? this.gtin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productfrname': name,
      'gtin': gtin,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['productfrname'],
      gtin: map['gtin'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Product(id: $id, name: $name, gtin: $gtin)';

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.gtin == gtin;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ gtin.hashCode;
}
