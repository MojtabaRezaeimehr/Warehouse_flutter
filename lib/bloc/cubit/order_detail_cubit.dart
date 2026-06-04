import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/models/remote/order/order_detail.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';

part 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrdersRepo _ordersRepo;

  OrderDetailCubit({OrdersRepo? ordersRepo})
      : _ordersRepo = ordersRepo ?? RemoteServices.ordersRepo,
        super(OrderDetailInitial());

  void fetchOrderDetails(int orderId) async {
    emit(LoadingOrderDetails());

    var response = await _ordersRepo.fetchOrderDetail(orderId);
    if (response is ApiResponseSucceeded) {
      emit(FetchedOrderDetails(orderDetails: response.values!));
    } else {
      emit(
        LoadingOrdersDetailsError(
            error: (response as ApiResponseFailed).message),
      );
    }
  }
}
