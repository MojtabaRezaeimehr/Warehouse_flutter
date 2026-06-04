import 'package:warehouse_amf/models/local/log.dart';

abstract class LogRepo {
  logThis(Log log);
  quickLog(String desc);
  readAllLogs();
  readAllLogsAsString();
  deleteOldLogs();
}
