part of 'new_order_cubit.dart';

sealed class NewOrderState extends Equatable {
  const NewOrderState();

  @override
  List<Object?> get props => [];
}

final class NewOrderInitial extends NewOrderState {}

final class StartingOrderState extends NewOrderState {}

final class StartingOrderErrorState extends NewOrderState {
  final String message;
  final DateTime date;

  const StartingOrderErrorState({required this.message, required this.date});
  @override
  List<Object?> get props => [message.hashCode, date.hashCode];
}

final class OrderStartedState extends NewOrderState {
  final OrderTypes orderTypes;
  final int orderId;
  final List<ScannedProduct> scannedProducts;
  final Company? distributer; //only for outgoing and returing orders
  final String? documentNo; //only for API orders

  bool isOrderLimited() =>
      scannedProducts.any((element) => element.maxScanQuantity != null);

  const OrderStartedState({
    required this.orderTypes,
    required this.orderId,
    required this.scannedProducts,
    this.distributer,
    this.documentNo,
  });

  OrderStartedState copyWith({
    OrderTypes? orderTypes,
    int? orderId,
    List<ScannedProduct>? scannedProducts,
    Company? distributer,
    String? documentNo,
  }) {
    return OrderStartedState(
      orderTypes: orderTypes ?? this.orderTypes,
      orderId: orderId ?? this.orderId,
      scannedProducts: scannedProducts ?? this.scannedProducts,
      distributer: distributer ?? this.distributer,
      documentNo: documentNo ?? this.documentNo,
    );
  }

  @override
  List<Object?> get props =>
      [orderId, scannedProducts, orderTypes, distributer, documentNo];
}
