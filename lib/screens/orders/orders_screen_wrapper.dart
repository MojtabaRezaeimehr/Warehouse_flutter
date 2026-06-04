import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/screens/orders/orders_screen.dart';

class OrdersScreenWrapper extends StatelessWidget {
  const OrdersScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        var orderCubit = BlocProvider.of<OrderCubit>(context);
        var userAuthCubit = BlocProvider.of<UserAuthCubit>(context);
        if (orderCubit.state is FetchingOrders ||
            orderCubit.state is OrderInitial) {
          return;
        }
        orderCubit.fetchOrdersForUser(userAuthCubit);
        await Future.delayed(const Duration(seconds: 1));
        return;
      },
      child:  CustomScrollView(
        scrollBehavior: NoScrollBehavior(),
        slivers: [
          const SliverFillRemaining(
            child: OrdersScreen(),
          )
        ],
      ),
    );
  }
}

class NoScrollBehavior extends ScrollBehavior{
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
