import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/validate_user_response.dart';

abstract class UserRepo {
  Future<ApiResponse<ValidateUserResponse>> validateUser(
      String username, String password);
}
