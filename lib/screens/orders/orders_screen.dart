import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/screens/orders/widgets/order_card.dart';
import 'package:warehouse_amf/screens/orders/widgets/orders_loading_widget.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var scrollController = ScrollController();
  late UserAuthCubit userAuthCubit;
  late OrderCubit orderCubit;

  var selectedChips = [
    OrderTypes.incoming,
    OrderTypes.outgoing,
    OrderTypes.returning,
  ];

  int? queriedId;

  @override
  void initState() {
    orderCubit = BlocProvider.of<OrderCubit>(context);
    userAuthCubit = BlocProvider.of<UserAuthCubit>(context);

    if (orderCubit.state is! FetchedOrders) {
      orderCubit.fetchOrdersForUser(userAuthCubit);
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          (scrollController.position.maxScrollExtent)) {
        orderCubit.fetchMoreOrders(userAuthCubit);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            suffixIcon: const Icon(Icons.search),
            hintText: Translations.search.name.tr(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => queryInOrders(value),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 5,
          children: [
            FilterChip(
              label: Text(OrderTypes.incoming.name.tr()),
              selected: selectedChips.contains(OrderTypes.incoming),
              onSelected: (value) {
                chipsOnSelect(OrderTypes.incoming);
              },
            ),
            FilterChip(
              label: Text(OrderTypes.outgoing.name.tr()),
              selected: selectedChips.contains(OrderTypes.outgoing),
              onSelected: (value) {
                chipsOnSelect(OrderTypes.outgoing);
              },
            ),
            FilterChip(
              label: Text(OrderTypes.returning.name.tr()),
              selected: selectedChips.contains(OrderTypes.returning),
              onSelected: (value) {
                chipsOnSelect(OrderTypes.returning);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is FetchingOrders || state is OrderInitial) {
                return const OrdersLoadingWidget();
              } else if (state is FetchingOrdersError) {
                return Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, size: 50),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                    )
                  ],
                );
              } else if (state is FetchedOrders) {
                if (state.orders.isEmpty) {
                  return Center(
                    child: Text(Translations.foundNoOrders.name.tr()),
                  );
                }
                //filter orders
                var filteredOrders = state.orders.where(
                  (element) =>
                      selectedChips.contains(element.orderType) &&
                      (queriedId != null
                          ? element.id.toString().contains("$queriedId")
                          : true),
                );

                if (filteredOrders.length < 5 && state.hasMore) {
                  //filtered order maybe empty ,keep fecthing more orders
                  orderCubit.fetchMoreOrders(userAuthCubit);
                } else if (filteredOrders.isEmpty && !state.hasMore) {
                  return Center(
                    child: Text(Translations.foundNoOrders.name.tr()),
                  );
                }

                return ListView.separated(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    return OrderCard(
                      order: filteredOrders.elementAt(index),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: filteredOrders.length,
                );
              } else {
                throw UnimplementedError();
              }
            },
          ),
        ),
      ],
    );
  }

  void queryInOrders(String value) {
    setState(() {
      value.isNotEmpty ? queriedId = int.parse(value) : queriedId = null;
    });
  }

  void chipsOnSelect(OrderTypes orderType) {
    //in case this type i already selected and
    // not the only selected type, remove it

    if (selectedChips.contains(orderType)) {
      if (selectedChips.length > 1) {
        selectedChips.remove(orderType);
      }
    } else {
      selectedChips.add(orderType);
    }
    setState(() {});
  }
}
