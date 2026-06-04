import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/remote/connection/connection_repo.dart';
import 'package:warehouse_amf/services/remote/dio_initializer.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';
import '../../../models/remote/api_response.dart';
import '../../../utils/enums/app_config_key.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  final AppConfigRepo _configRepo;
  final ConnectionRepo _connectionRepo;

  ConnectionCubit({AppConfigRepo? configRepo, ConnectionRepo? connectionRepo})
      : _configRepo = configRepo ?? LocalServices.appConfigRepo,
        _connectionRepo = connectionRepo ?? RemoteServices.connectionRepo,
        super(ConnectionInitial());

  Future<void> checkConnection(String ip, String port) async {

    String newUrl = "http://$ip:$port";
    var response = await _connectionRepo.checkConnection(newUrl);

    if (response is ApiResponseSucceeded) {
      //save the new config
      updateBaseUrl(ip, port);
      emit(ConnectionSuccessfull(DateTime.now()));
    } else {
      emit(ConnectionFailed(DateTime.now()));
    }
  }

  void updateBaseUrl(String ip, String port) {
    //save the new config
    _configRepo.updateConfig(
      AppConfigKey.baseUrl,
      "http://$ip:$port",
    );
    //update DioInitializer
    DioInitializer.updateBaserUrl();
  }
}
