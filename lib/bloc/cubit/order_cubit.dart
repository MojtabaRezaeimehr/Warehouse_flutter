import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/services/local/log/log_service.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrdersRepo _ordersRepo;

  OrderCubit({OrdersRepo? ordersRepo})
      : _ordersRepo = ordersRepo ?? RemoteServices.ordersRepo,
        super(OrderInitial());

  void fetchOrdersForUser(
    UserAuthCubit userAuthCubit, {
    int from = 0,
    int to = 50,
    bool fetchMore = false,
  }) async {
    if (!fetchMore) {
      emit(FetchingOrders());
    } else {
      emit(
        FetchingMoreOrders(
            orders: (state as FetchedOrders).orders,
            hasMore: (state as FetchedOrders).hasMore),
      );
    }

    int userId = (userAuthCubit.state as UserAuthorized).user.id;
    var response = await _ordersRepo.fetchOrdersForUser(userId, from, to);
    if (response is ApiResponseSucceeded) {
      var orders = response.values?.$1;
      if (state is FetchingMoreOrders) {
        //concatinate old orders with newly fetched one
        orders?.insertAll(0, (state as FetchedOrders).orders);
      }
      emit(FetchedOrders(
        orders: response.values?.$1 ?? [],
        hasMore: response.values?.$2 ?? false,
      ));
    } else {
      emit(
        FetchingOrdersError(error: (response as ApiResponseFailed).message),
      );
    }
  }

  fetchMoreOrders(UserAuthCubit userAuthCubit) {
    if (state is FetchingMoreOrders || state is! FetchedOrders) {
      //state is FetchingMoreOrders meaning there is
      //- an ongoing requets for fetching newOrders
      return;
    }
    var castedState = (state as FetchedOrders);
    if (castedState.hasMore) {
      LogService().quickLog("requesting for more user orders");
      fetchOrdersForUser(userAuthCubit,
          from: castedState.orders.length,
          to: castedState.orders.length + 50,
          fetchMore: true);
    }
  }

  addOrder(Order order) {
    if (state is! FetchedOrders) {
      return;
    }
    var castedState = state as FetchedOrders;

    //if given order is a continued Api order
    //we may have saved an older version already
    //remove prev version to save an updated one
    castedState.orders.removeWhere(
      (element) => element.id == order.id,
    );

    emit(
      FetchedOrders(
        orders: List.of(castedState.orders)..insert(0, order),
        hasMore: castedState.hasMore,
      ),
    );
  }

  Future<String?> deleteOrder(int id) async {
    if (state is! FetchedOrders) {
      return null;
    }
    String? result;

    //temporary emit LoadingOrders to force ui show loading widget
    var realState = (state as FetchedOrders);
    emit(FetchingOrders());

    var response = await _ordersRepo.deleteOrder(id);
    var updatedOrders = List.of(
      realState.orders,
    );
    if (response is ApiResponseSucceeded) {
      updatedOrders.removeWhere((element) => element.id == id);
    } else {
      result = (response as ApiResponseFailed).message;
    }

    //even if response is Failed we have to emit prev order
    //bc of temporary state we emitted earlier
    if (state is FetchingMoreOrders) {
      emit(
        FetchingMoreOrders(
          orders: updatedOrders,
          hasMore: realState.hasMore,
        ),
      );
    } else {
      emit(
        FetchedOrders(
          orders: updatedOrders,
          hasMore: realState.hasMore,
        ),
      );
    }
    return result;
  }
}
