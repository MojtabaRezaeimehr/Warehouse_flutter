// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Company {
  String id;
  final String name;
  final String nid;
  final String? province;
  final int? prefix;
  Company({
    required this.id,
    required this.name,
    required this.nid,
    this.province,
    this.prefix,
  });
  

  Company copyWith({
    String? id,
    String? name,
    String? nid,
    String? province,
    int? prefix,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      nid: nid ?? this.nid,
      province: province ?? this.province,
      prefix: prefix ?? this.prefix,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'companyfaname': name,
      'nationalid': nid,
      'province': province,
      'prefix': prefix,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      name: map['companyfaname'],
      nid: map['nationalid'],
      province: map['province'],
      prefix: map['prefix'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) => Company.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Company(id: $id, companyfaname: $name, nationalid: $nid, province: $province, prefix: $prefix)';
  }

  @override
  bool operator ==(covariant Company other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.nid == nid &&
      other.province == province &&
      other.prefix == prefix;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      nid.hashCode ^
      province.hashCode ^
      prefix.hashCode;
  }
}
