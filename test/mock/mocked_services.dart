import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/local/scanned_history/scanned_history_repo.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/products/products_repo.dart';
import 'package:warehouse_amf/services/remote/scan/scan_repo.dart';
import 'package:warehouse_amf/services/remote/user/user_repo.dart';

class MockDio extends Mock implements Dio {}

class MockLogService extends Mock implements LogRepo {}

class MockUserRepo extends Mock implements UserRepo {}

class MockAppConfigRepo extends Mock implements AppConfigRepo {}

class MockOrdersRepo extends Mock implements OrdersRepo {}

class MockProductsRepo extends Mock implements ProductsRepo {}

class MockScanRepo extends Mock implements ScanRepo {}

class MockScanHistoryRepo extends Mock implements ScannedHistoryRepo {}

class FakeLogRepo implements LogRepo {
  @override
  deleteOldLogs() {}
  @override
  readAllLogs() {}
  @override
  readAllLogsAsString() {}

  @override
  logThis(Log log) {
    // ignore: avoid_print
    print(log.desc);
  }

  @override
  quickLog(String desc) {
    // ignore: avoid_print
    print(desc);
  }

}
