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
    final previousState = state; // Store previous state for potential use in fetchMore

    if (!fetchMore) {
      emit(FetchingOrders());
    } else {
      // Ensure previousState is FetchedOrders before casting
      if (previousState is FetchedOrders) {
        emit(
        FetchingMoreOrders(
              orders: previousState.orders, hasMore: previousState.hasMore),
      );
    } else {
        // If not FetchedOrders, we cannot fetchMore, so return or handle error
      return;
    }
    }

    int userId = (userAuthCubit.state as UserAuthorized).user.id;
    var response = await _ordersRepo.fetchOrdersForUser(userId, from, to);
    if (response is ApiResponseSucceeded) {
      List<Order> newOrders = [];
      bool hasMore = false;

      try {
        if (response.values is Map<String, dynamic>) {
          var mapData = response.values as Map<String, dynamic>;

          if (mapData.containsKey('orders') && mapData['orders'] is List) {
            List<dynamic> rawOrders = mapData['orders'];
            // *** CORRECTED LINE: Use fromMap directly ***
            newOrders = rawOrders.map((jsonMap) => Order.fromMap(jsonMap as Map<String, dynamic>)).toList();

          } else {
            print("API response map does not contain 'orders' key or it's not a list.");
          }

          if (mapData.containsKey('hasMore') && mapData['hasMore'] is bool) {
            hasMore = mapData['hasMore'];
          } else {
            print("API response map does not contain 'hasMore' key or it's not a bool.");
          }
        } else {
          print("Unexpected response.values type: ${response.values.runtimeType}");
          newOrders = [];
          hasMore = false;
        }

      } catch (e, stacktrace) { // Capture stacktrace for better debugging
        print("Error processing API response values: $e");
        print("Stacktrace: $stacktrace"); // Log the stacktrace

        // If parsing fails due to an error within Order.fromMap or list processing
        // it could be the source of "Bad state: No element!" if combinedOrders becomes empty.
        emit(FetchingOrdersError(error: "Failed to parse order data. Please check order structure."));
        return; // Stop execution here if parsing fails
      }

      // ... rest of the logic: combine orders and emit FetchedOrders ...
      List<Order> combinedOrders = [];

      if (fetchMore && previousState is FetchedOrders) {
        combinedOrders.addAll(previousState.orders);
        combinedOrders.addAll(newOrders);
      } else {
        combinedOrders = newOrders;
      }

      // ... inside OrderCubit fetchOrdersForUser, just before emitting FetchedOrders ...

print("DEBUG: Emitting FetchedOrders with:");
print("  combinedOrders length: ${combinedOrders.length}");
if (combinedOrders.isNotEmpty) {
  print("  First order ID: ${combinedOrders.first.id}"); // Log first order ID to check parsing
  print("  First order type: ${combinedOrders.first.orderType}");
  print("  First order date: ${combinedOrders.first.date}");
} else {
  print("  combinedOrders is empty.");
}
print("  hasMore: $hasMore");
print("  previousState was: ${previousState.runtimeType}"); // See what state it was before fetching

      emit(FetchedOrders(
        orders: combinedOrders,
        hasMore: hasMore,
      ));
    } else {
      emit(FetchingOrdersError(error: (response as ApiResponseFailed).message));
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



