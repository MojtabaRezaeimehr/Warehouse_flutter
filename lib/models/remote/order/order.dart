// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/functions.dart'; // For dprint

class Order {
  final int id;
  final int scannedCount;
  final Company? distributer;
  //api orders(those were started by firooz powerbi t3)
  //have documentation No
  final String? documentNo;
  final DateTime date; // add this field
  final OrderTypes orderType; // add this field
  final int? progress;

  Order({
    required this.id,
    required this.scannedCount,
    this.distributer,
    this.documentNo,
    required this.date,
    required this.orderType,
    this.progress,
  });

  Order copyWith({
    int? id,
    int? totalCount,
    Company? distributer,
    String? documentNo,
    DateTime? date,
    OrderTypes? orderType,
    int? progress,
  }) {
    return Order(
      id: id ?? this.id,
      scannedCount: totalCount ?? scannedCount,
      distributer: distributer ?? this.distributer,
      documentNo: documentNo ?? this.documentNo,
      date: date ?? this.date,
      orderType: orderType ?? this.orderType,
      progress: progress ?? this.progress,
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
      'progress': progress,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    // --- Safely parse ID ---
    int parsedId = map['OrderId'] as int? ?? -1; // Default to -1 if missing or not int

    // --- Safely parse scannedCount ---
    int parsedScannedCount = map['scannedCount'] as int? ?? 0;

    // --- Safely parse distributer ---
    Company? parsedDistributer;
    final nid = map['DistributerCompanyNid']?.toString().trim(); // Trim whitespace
    final companyName = map['distributerCompanyName']?.toString();

    if (nid != null && nid.isNotEmpty && companyName != null && companyName.isNotEmpty) {
      try {
        // Ensure keys passed to Company.fromMap are exactly what it expects
        // Assuming Company.fromMap expects 'nationalid' and 'companyfaname'
        parsedDistributer = Company.fromMap({
          'nationalid': nid,
          'companyfaname': companyName,
          // Add other necessary Company fields here if Company.fromMap requires them
        });
      } catch (e) {
        dprint("Error parsing distributer for Order ID ${parsedId}: $e");
        parsedDistributer = null; // Set to null if Company parsing fails
      }
    } else {
      // If NID or Name is missing/empty, distributer is null.
      parsedDistributer = null;
    }

    // --- Safely parse documentNo ---
    String? parsedDocumentNo = map['documentCode']?.toString().trim();
    if (parsedDocumentNo != null && parsedDocumentNo.isEmpty) {
      parsedDocumentNo = null; // Treat empty string as null
    }

    // --- Safely parse date ---
    DateTime parsedDate = DateTime.now(); // Default date
    try {
      if (map['createdAt'] != null && map['createdAt'] is String && map['createdAt'].isNotEmpty) {
        parsedDate = DateTime.parse(map['createdAt']);
      } else {
        dprint("createdAt is null, empty, or not a string for Order ID ${parsedId}. Using default date.");
      }
    } catch (e) {
      dprint("Error parsing createdAt date for Order ID ${parsedId}: ${map['createdAt']}. Error: $e");
    }

    // --- Safely parse orderType (CASE-INSENSITIVE) ---
    OrderTypes parsedOrderType = OrderTypes.incoming; // Default type
    try {
      final orderTypeString = map['ordertype']?.toString().toLowerCase().trim();
      if (orderTypeString != null && orderTypeString.isNotEmpty) {
        // Find the enum value case-insensitively
        parsedOrderType = OrderTypes.values.firstWhere(
          (element) => element.name.toLowerCase() == orderTypeString,
          // If not found, it will throw StateError. Catch it.
          // Or provide a default value here.
        );
      } else {
        dprint("ordertype is null, empty, or not a string for Order ID ${parsedId}. Using default type.");
      }
    } catch (e) {
      // This catch typically handles StateError from firstWhere if no match is found
      dprint("Error parsing orderType for Order ID ${parsedId}: ${map['ordertype']}. Error: $e");
      // parsedOrderType remains its default value
    }

    // --- Safely parse progress ---
    int? parsedProgress = map['progress'] as int? ?? 0; // Default to 0 if null or not int


    return Order(
      id: parsedId,
      scannedCount: parsedScannedCount,
      distributer: parsedDistributer,
      documentNo: parsedDocumentNo,
      date: parsedDate,
      orderType: parsedOrderType,
      progress: parsedProgress,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, totalCount: $scannedCount, distributer: $distributer, documentNo: $documentNo, date: $date, orderType: $orderType, progress: $progress)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.scannedCount == scannedCount &&
        other.distributer == distributer &&
        other.documentNo == documentNo &&
        other.date == date &&
        other.orderType == orderType &&
        other.progress == progress;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        scannedCount.hashCode ^
        distributer.hashCode ^
        documentNo.hashCode ^
        date.hashCode ^
        orderType.hashCode ^
        progress.hashCode;
  }
}

