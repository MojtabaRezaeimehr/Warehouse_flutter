import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_amf/bloc/cubit/order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/models/remote/order/load_order_request.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/models/remote/order/order_builder.dart';
import 'package:warehouse_amf/models/remote/product.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_type_cubit.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/products/products_repo.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';

part 'new_order_state.dart';

class NewOrderCubit extends Cubit<NewOrderState> {
  final OrdersRepo _ordersRepo;
  final ProductsRepo _productsRepo;

  final UserAuthCubit userAuthCubit;
  final TargetPlatform targetPlatform;

  StartOrderRequest? _startOrderRequest;
  final OrderBuilder _orderBuilder = OrderBuilder();
  String? userId;
  String? deviceId;

  NewOrderCubit(
    this.userAuthCubit,
    this.targetPlatform, {
    OrdersRepo? ordersRepo,
    ProductsRepo? productsRepo,
  })  : _ordersRepo = ordersRepo ?? RemoteServices.ordersRepo,
        _productsRepo = productsRepo ?? RemoteServices.productsRepo,
        super(NewOrderInitial());

  Future<void> _startOrder(String distributorNid, OrderTypes orderType,
      Company? company, List<ScannedProduct> limitedProducts,
      {String? documentCode, String? orderId}) async {
    emit(StartingOrderState());

    if (userId == null || deviceId == null) {
      userId = (userAuthCubit.state as UserAuthorized).user.id.toString();
      deviceId = await getDeviceId(targetPlatform);
    }

    _startOrderRequest = StartOrderRequest(
      isOrderApi: documentCode != null,
      documentNo: documentCode,
      orderid: orderId ?? "",
      isNewOrder: orderId == null,
      distributerNid: distributorNid,
      quantity: 0,
      orderType: orderType,
      details: "",
      userId: userId!,
      deviceId: deviceId!,
    );
    var response = await _ordersRepo.startOrder(_startOrderRequest!);

    if (response is ApiResponseSucceeded) {
      final orderId = response.values!;
      _orderBuilder
        ..id = orderId
        ..date = DateTime.now()
        ..distributer = company
        ..documentNo = documentCode
        ..orderType = orderType;

      //a prev order has been continued if orderid is provided
      //setUp or update limitedProducts(it will be passed to orderStartedState)
      if (_startOrderRequest?.isNewOrder == false) {
        var isListUpdated =
            await setUpScannedProducts(orderId, limitedProducts);
        if (!isListUpdated) {
          //failed to load prev data(scan quantity) of scanned products
          emit(
            StartingOrderErrorState(
              message: "failed to load prev order data",
              date: DateTime.now(),
            ),
          );
          return;
        }
      }

      //post order limit info after updating continueing API order
      //if not server get info with 0 scanQuantity and may store it!
      if (orderType == OrderTypes.outgoing &&
          limitedProducts.isNotEmpty) {
        //post limit info to server
        _ordersRepo.postOrderLimitInfo(limitedProducts, "$orderId");
      }

      //emitting new state
      emit(
        OrderStartedState(
            orderTypes: orderType,
            orderId: orderId,
            scannedProducts: limitedProducts,
            distributer: company,
            documentNo: documentCode),
      );
    } else {
      emit(
        StartingOrderErrorState(
          date: DateTime.now(),
          message: (response as ApiResponseFailed).message,
        ),
      );
    }
  }

  startIncomingOrder({String? orderId}) async {
    await _startOrder("", OrderTypes.incoming, null, [], orderId: orderId);
  }

  startReturningOrder(Company company, {String? orderId}) async {
    await _startOrder(company.nid, OrderTypes.returning, company, [],
        orderId: orderId);
  }

  startOutgoingOrder(Company company, List<ScannedProduct>? limitedProducts,
      {String? documentCode, String? orderId}) async {
    await _startOrder(
      company.nid,
      OrderTypes.outgoing,
      company,
      limitedProducts ?? [],
      documentCode: documentCode,
      orderId: orderId,
    );
  }

  bool resumeOrder(Order order) {
    if (order.id == -1 ||
        order.documentNo != null ||
        (order.orderType == OrderTypes.outgoing && order.distributer == null)) {
      //! this is not for resuming Api orders
      dprint("Failed to resume given order! id:${order.id} docNo is null?: ${order.documentNo==null}");
      return false;
    }

    switch (order.orderType) {
      case OrderTypes.incoming:
        startIncomingOrder(orderId: order.id.toString());
      case OrderTypes.returning:
        startReturningOrder(order.distributer!, orderId: order.id.toString());
      case OrderTypes.outgoing:
        startOutgoingOrder(
          order.distributer!,
          [], //scannedProducts will be fetched and updated later on in _startOrder()
          orderId: order.id.toString(),
        );
    }
    return true;
  }

  bool isOrderLimited() {
    if (state is OrderStartedState) {
      return (state as OrderStartedState)
              .scannedProducts
              .firstOrNull
              ?.maxScanQuantity !=
          null;
    }
    return false;
  }

  Future<bool> isOrderCompleted() async {
    if (isOrderLimited()) {
      var response = await _ordersRepo.isOrderCompleted(_orderBuilder.id ?? -1);
      if (response is ApiResponseSucceeded) {
        return response.values!;
      }
    }
    return true;
  }

  finishOrder(
    OrderCubit orderCubit, {
    bool manuallyRequested = false,
  }) async {
    if (_startOrderRequest == null && state is! OrderStartedState) {
      return;
    }

    var castedState = state as OrderStartedState;

    //manuallyRequested is only true when user finishes order manually
    //this prevent deleting order accidentally when app goes inactive
    dprint(
        "finishing order orderBuilder.totalCount  ${_orderBuilder.scannedCount}");

    if (manuallyRequested) {
      if (_orderBuilder.scannedCount == 0) {
        //order is empty,send delete req
        _ordersRepo.deleteOrder(castedState.orderId);

        //reset builder with def values
        _orderBuilder.reset();
      } else {
        //add this order to cached order in orderState
        var order = _orderBuilder.build();
        orderCubit.addOrder(order);

        //reset builder with def values
        _orderBuilder.reset();

        //save order on server
        //server finishes(save) order with the same API of starting order
        _ordersRepo.startOrder(_startOrderRequest!.copyWith(isNewOrder: false));
      }
      return;
    }

    //auto save order is called
    if (_orderBuilder.scannedCount != 0) {
      //notify server of app being inactive
      //server finishes(save) order with the same API of starting order
      _ordersRepo.startOrder(_startOrderRequest!.copyWith(isNewOrder: false));
    }
  }

  void reset() => emit(NewOrderInitial());

  void putScannedProduct(String gtin, ScanTypeCubit scanTypeCubit) async {
    String defProductName = Translations.loading.name.tr();
    var castedState = state as OrderStartedState;

    //fetch product count from server
    int scanQuantity = -1;
    var countResponse = await _ordersRepo.fetchProductCountInOrder(
      gtin,
      castedState.orderId.toString(),
    );
    if (countResponse is ApiResponseSucceeded) {
      scanQuantity = countResponse.values ?? -1;
    }

    // if we have a scanned product with this gtin ,get its index
    int scannedProductIndex = castedState.scannedProducts.indexWhere(
      (element) => element.product.gtin == gtin,
    );

    // Remove scannedProduct if (COUNT IS ZERO AFTER DELETE) and conditions are met
    final bool removeScannedProduct = scanQuantity == 0 &&
        scannedProductIndex != -1 && // scannedProduct exists
        scanTypeCubit.state
            is DeletingState && // avoid removing when adding — server might send 0 incorrectly
        !isOrderLimited(); // skip if order is LIMITED (cant remove limit conditions!)

    if (removeScannedProduct) {
      final updatedProducts = List.of(castedState.scannedProducts)
        ..removeAt(scannedProductIndex);
      emit(
        castedState.copyWith(scannedProducts: updatedProducts),
      );
      // castedState is obsolete after emit
      updateOrderCount((state as OrderStartedState).scannedProducts);
      return; // early exit
    }

    //find existing or create a new ScannedProduct
    ScannedProduct scannedProduct;
    if (scannedProductIndex != -1) {
      //update quantity
      scannedProduct = castedState.scannedProducts[scannedProductIndex]
          .copyWith(scanQuantity: scanQuantity);
      //remove the obsolete(prev) scannedProduct
      castedState.scannedProducts.removeAt(scannedProductIndex);
    } else {
      //create new ScannedProduct
      scannedProduct = ScannedProduct(
        product: Product(id: "-1", name: defProductName, gtin: gtin),
        scanQuantity: scanQuantity,
      );
    }

    //update scanned product list

    //put the scanned propduct if its done
    int index = 0;
    if (scannedProduct.scanQuantity == scannedProduct.maxScanQuantity) {
      index = castedState.scannedProducts.length;
    }

    var updatedProducts = List.of(castedState.scannedProducts)
      ..insert(index, scannedProduct);
    emit(castedState.copyWith(scannedProducts: updatedProducts));
    //reinitalize castedState for new scanQuantity
    castedState = state as OrderStartedState;

    //if the product name needs to be fetched
    if (scannedProduct.product.name == defProductName) {
      var response = await _productsRepo.fetchproductName(gtin);
      if (response is ApiResponseSucceeded) {
        //update scanned product list with the fetched named
        var updatedProducts = castedState.scannedProducts.map(
          (e) {
            if (e.product.gtin == gtin) {
              return e.copyWith(
                product: e.product.copyWith(name: response.values ?? "null"),
              );
            }
            return e;
          },
        ).toList();

        emit(castedState.copyWith(scannedProducts: updatedProducts));
      }
    }

    updateOrderCount(castedState.scannedProducts);
  }

  void updateOrderCount(List<ScannedProduct> scannedProducts) {
    int count = 0;
    for (var element in scannedProducts) {
      count += element.scanQuantity;
    }

    _orderBuilder.scannedCount = count;
  }

  int getOrderScannedCount() => _orderBuilder.scannedCount;

  //this method recieves a List of scanned products as input
  //and updates the list according to real data fatched from server
  Future<bool> setUpScannedProducts(
      int orderId, List<ScannedProduct> scannedProducts) async {
    dprint("in setUpScannedProducts");
    bool result = false;
    if (scannedProducts.isNotEmpty) {
      result = await _setUpApiScannedProducts(scannedProducts, orderId);
    } else {
      result = await _setUpScannedProducts(scannedProducts, orderId);
    }

    updateOrderCount(scannedProducts);
    return result;
  }

  Future<bool> _setUpApiScannedProducts(
      List<ScannedProduct> scannedProducts, int orderId) async {
    var response = await _ordersRepo.fetchApiOrderProducts(orderId);
    if (response is ApiResponseFailed) {
      return false;
    }

    var orderProducts = response.values!;
    if (orderProducts.isEmpty) {
      //we have failed to fetch order products
      return false;
    }

    for (var i = 0; i < scannedProducts.length; i++) {
      var element = scannedProducts[i];
      scannedProducts[i] = element.copyWith(
        scanQuantity: orderProducts[element.product.gtin],
      );
    }

    return true;
  }

  Future<bool> _setUpScannedProducts(
      List<ScannedProduct> scannedProducts, int orderId) async {
    var response = await _ordersRepo.fetchOrderProducts(orderId);
    if (response is ApiResponseFailed) {
      return false;
    }
    scannedProducts.clear();
    scannedProducts.addAll(response.values!);
    return true;
  }
}
