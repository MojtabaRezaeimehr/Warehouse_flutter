import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/models/remote/order/load_order_request.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/models/remote/scan/scan_request.dart';
import 'package:warehouse_amf/models/remote/user.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';

var mockStartOrderRequest = StartOrderRequest(
  isOrderApi: false,
  orderid: "",
  isNewOrder: false,
  distributerNid: "",
  quantity: 0,
  orderType: OrderTypes.incoming,
  details: "",
  userId: "",
  deviceId: "",
);

var mockUser = User(
    id: 1,
    fname: "fname",
    lname: "lname",
    username: "username",
    phone: "phone",
    companyNid: "companyNid",
    companyName: "companyName");

var mockScanRequest = ScanRequest(
  barcode: "010693339565635121217160204130589959351723010010A71008",
  uid: "21716020413058995935",
  orderId: "orderId",
  state: "state",
  userId: "userId",
  orderType: OrderTypes.incoming,
);

var mockCompany = Company(id: "-1", name: "name", nid: "nid");

var mockOrder = Order(
  date: DateTime.now(),
  distributer: mockCompany,
  id: -1,
  orderType: OrderTypes.incoming,
  scannedCount: 2,
);
