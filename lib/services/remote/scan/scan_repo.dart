import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/scan/scan_request.dart';
import 'package:warehouse_amf/utils/enums/scan_responses.dart';

abstract class ScanRepo {
  Future<ApiResponse<ScanResponses>> postBarcode(ScanRequest scanRequest);
  Future<ApiResponse<String>> getBarcodeOfUID(String uid);
  Future<ApiResponse<String>> getBarcodeOfRND(String rnd);
}
