part of 'order_detail_cubit.dart';

sealed class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

final class OrderDetailInitial extends OrderDetailState {}

final class LoadingOrderDetails extends OrderDetailState {}

final class LoadingOrdersDetailsError extends OrderDetailState {
  final String error;

  const LoadingOrdersDetailsError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class FetchedOrderDetails extends OrderDetailState {
  final List<OrderDetail> orderDetails;

  const FetchedOrderDetails({required this.orderDetails});
  @override
  List<Object?> get props => [orderDetails];
}
