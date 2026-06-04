import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/local/storage/storage_repo.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';
import 'package:warehouse_amf/utils/functions.dart';

class LogService extends LogRepo {
  final StorageRepo _storageRepo;

  static LogService? instance;

  factory LogService({StorageRepo? storageRepo}) {
    instance ??=
        LogService._pvConstructor(storageRepo ?? LocalServices.storageRepo());
    return instance!;
  }

  LogService._pvConstructor(this._storageRepo);

  @override
  deleteOldLogs() async {
    var logs = await readAllLogs();
    var threshold =
        DateTime.now().subtract(const Duration(days: kLogThresholdInDays));
    for (var element in logs) {
      if (element.date.isBefore(threshold)) {
        await _storageRepo.delete("log-${element.date}");
      }
    }
  }

  @override
  logThis(Log log) async {
    dprint(log.desc);
    await _storageRepo.write(
      "log-${log.date}",
      log.toJson(),
    );
  }

  @override
  readAllLogs() async {
    var allData = await _storageRepo.readAll();
    List<Log> logs = [];
    allData.forEach(
      (key, value) {
        if (key.contains("log-")) {
          logs.add(Log.fromJson(value));
        }
      },
    );
    return logs;
  }

  @override
  readAllLogsAsString() async {
    var allData = await _storageRepo.readAll();
    String logs = "";
    allData.forEach(
      (key, value) {
        if (key.contains("log-")) {
          logs += "$value\n";
        }
      },
    );
    return logs;
  }

  @override
  quickLog(String desc) async {
    dprint(desc);

    var date = DateTime.now();
    await _storageRepo.write(
      "log-$date",
      Log(date: date, desc: desc).toJson(),
    );
  }
}
