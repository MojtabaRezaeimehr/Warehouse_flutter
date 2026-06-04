import 'package:warehouse_amf/services/remote/companies/companies_repo.dart';
import 'package:warehouse_amf/services/remote/companies/companies_service.dart';
import 'package:warehouse_amf/services/remote/connection/connection_repo.dart';
import 'package:warehouse_amf/services/remote/connection/connection_service.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/orders/orders_service.dart';
import 'package:warehouse_amf/services/remote/products/products_repo.dart';
import 'package:warehouse_amf/services/remote/products/products_service.dart';
import 'package:warehouse_amf/services/remote/scan/scan_repo.dart';
import 'package:warehouse_amf/services/remote/scan/scan_service.dart';
import 'package:warehouse_amf/services/remote/user/user_repo.dart';
import 'package:warehouse_amf/services/remote/user/user_service.dart';

class RemoteServices {
  static final CompaniesRepo companiesRepo = CompaniesService();
  static final ConnectionRepo connectionRepo = ConnectionService();
  static final OrdersRepo ordersRepo = OrdersService();
  static final ProductsRepo productsRepo = ProductService();
  static final ScanRepo scanRepo = ScanService();
  static final UserRepo userRepo = UserService();
}
