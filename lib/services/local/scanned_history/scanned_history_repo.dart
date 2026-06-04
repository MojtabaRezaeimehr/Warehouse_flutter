
import 'package:warehouse_amf/models/local/barcode.dart';

abstract class ScannedHistoryRepo {
  addToHistory(Barcode barcode);
  Future<List<Barcode>> readAllHistory();
  deleteOldHistory();
}
