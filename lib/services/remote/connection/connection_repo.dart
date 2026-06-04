import '../../../models/remote/api_response.dart';

abstract class ConnectionRepo {
  Future<ApiResponse<void>> checkConnection(String url);
}
