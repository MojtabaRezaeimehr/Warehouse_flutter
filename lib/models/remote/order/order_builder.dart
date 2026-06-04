import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';

class OrderBuilder {
  int? id;
  int scannedCount = 0;
  Company? distributer;
  String? documentNo;
  DateTime? date;
  OrderTypes? orderType;

  Order build() {
    if (id == null || date == null || orderType == null) {
      throw Exception("Required fields are missing in OrderBuilder!");
    }
    return Order(
        id: id!,
        scannedCount: scannedCount,
        distributer: distributer,
        date: date!,
        orderType: orderType!,
        documentNo: documentNo);
  }

  reset() {
    id = null;
    distributer = null;
    documentNo = null;
    date = null;
    orderType = null;
    scannedCount = 0;
  }
}
