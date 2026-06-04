import 'package:warehouse_amf/models/remote/user.dart';

class ValidateUserResponse {
  final User user;
  final String token;

  ValidateUserResponse({required this.user, required this.token});
}
