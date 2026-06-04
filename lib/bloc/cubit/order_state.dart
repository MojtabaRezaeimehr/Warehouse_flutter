part of 'order_cubit.dart';

sealed class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

final class OrderInitial extends OrderState {}

final class FetchingOrders extends OrderState {}

final class FetchingOrdersError extends OrderState {
  final String error;

  const FetchingOrdersError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class FetchedOrders extends OrderState {
  final List<Order> orders;
  final bool hasMore;

  const FetchedOrders({required this.orders, required this.hasMore});
  @override
  List<Object?> get props => [orders, hasMore];
}

final class FetchingMoreOrders extends FetchedOrders {
  const FetchingMoreOrders({required super.orders, required super.hasMore});
  @override
  List<Object?> get props => [orders, hasMore];
}
