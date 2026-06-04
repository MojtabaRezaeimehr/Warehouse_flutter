import 'package:warehouse_amf/models/local/barcode.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_repo.dart';
import 'package:warehouse_amf/services/local/scanned_history/scanned_history_repo.dart';
import 'package:warehouse_amf/services/local/storage/storage_repo.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';

class ScannedHistoryService extends ScannedHistoryRepo {
  final StorageRepo _storageRepo;
  final LogRepo _logRepo;

  static ScannedHistoryService? instance;

  factory ScannedHistoryService({StorageRepo? storageRepo, LogRepo? logRepo}) {
    instance ??= ScannedHistoryService._pvConstructor(
      storageRepo ?? LocalServices.storageRepo(),
      logRepo ?? LocalServices.logRepo,
    );
    return instance!;
  }

  ScannedHistoryService._pvConstructor(this._storageRepo, this._logRepo);

  @override
  deleteOldHistory() async {
    var barcodes = await readAllHistory();
    var threshold =
        DateTime.now().subtract(const Duration(days: kHistoryThresholdInDays));
    for (var element in barcodes) {
      if (element.scanDate.isBefore(threshold)) {
        await _storageRepo.delete("history-${element.scanDate}");
      }
    }
  }

  @override
  Future<List<Barcode>> readAllHistory() async {
    var allData = await _storageRepo.readAll();
    List<Barcode> barcodes = [];
    allData.forEach(
      (key, value) {
        if (key.contains("history-")) {
          barcodes.add(Barcode.fromJson(value));
        }
      },
    );
    return barcodes;
  }

  @override
  addToHistory(Barcode barcode) async {
    await _storageRepo.write(
      "history-${barcode.scanDate}",
      barcode.toJson(),
    );
    _logRepo.logThis(
      Log(
          date: barcode.scanDate,
          desc: "added ${barcode.value} to scan history",
          tag: "history service"),
    );
  }
}
