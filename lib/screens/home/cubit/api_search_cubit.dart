import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/order/api_order.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

part 'api_search_state.dart';

class ApiSearchCubit extends Cubit<ApiSearchState> {
  final OrdersRepo _ordersRepo;

  ApiSearchCubit({OrdersRepo? ordersRepo})
      : _ordersRepo = ordersRepo ?? RemoteServices.ordersRepo,
        super(
          const ApiSearchInitial(),
        );

  void query(String query) async {
    //user may look up companies with twp diff queries one after another
    //in this case the old req must be canceled
    if (state is ApiLoadingSearch) {
      (state as ApiLoadingSearch).cancelToken.cancel();
    }

    //emit loading for the newest query
    var cancelToken = CancelToken();
    emit(
      ApiLoadingSearch(cancelToken: cancelToken),
    );

    ApiResponse<List<ApiOrder>> response =
        await _ordersRepo.fetchApiOrders(query, cancelToken);
    if (response is ApiResponseSucceeded) {
      emit(
        ApiFetchedSearch(apiOrders: response.values ?? []),
      );
    } else {
      if ((response as ApiResponseFailed)
          .message
          .contains("request was manually cancelled")) {
        //this is infact no failure and was done on purpose
        return;
      }
      emit(
        ApiLoadingSearchError(error: (response as ApiResponseFailed).message),
      );
    }
  }

  Future<(bool, String?)> startApiOrder(
      ApiOrder apiOrder,
      NewOrderCubit newOrderCubit,
      Future<bool> Function(double percentage) onResumeDialog) async {
    //check if selected order has been started already
    //if so set the old order id and resume it
    var response = await _ordersRepo.getApiOrderProgress(apiOrder.documentCode);
    if (response is ApiResponseSucceeded) {
      List<ScannedProduct> limitedProduct = [];
      for (var item in apiOrder.items) {
        limitedProduct.add(
          ScannedProduct(
            product: item.product,
            scanQuantity: 0,
            maxScanQuantity: item.quantity,
          ),
        );
      }

      var castedResponse = response as ApiResponseSucceeded<(int?, String)>;
      String percentageStr = castedResponse.values!.$2;
      double percentage = double.parse(
        percentageStr.substring(0, percentageStr.length - 1),
      );
      if (percentage == 100) {
        //this document-code is done and can not be continued
        return (false, Translations.orderIsDone.name.tr());
      } else {
        if (percentage != 0) {
          if (!await onResumeDialog.call(percentage)) {
            return (false, null);
          }
        }
        //resume prev order.
        int? orderId =
            castedResponse.values!.$1; //if null a new order is started
        newOrderCubit.startOutgoingOrder(
          apiOrder.distributer,
          limitedProduct,
          documentCode: apiOrder.documentCode,
          orderId: orderId?.toString(),
        );
      }
      return (true, null);
    } else {
      return (false, (response as ApiResponseFailed).message);
    }
  }

  void reset() => emit(const ApiSearchInitial());
}
