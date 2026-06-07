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

    // Fetch orders only if the state isn't already FetchedOrders
    if (orderCubit.state is! FetchedOrders) {
      orderCubit.fetchOrdersForUser(userAuthCubit);
    }

    scrollController.addListener(() {
      // Check if we are near the end of the scrollable area
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // Fetch more orders only if there might be more
        if (orderCubit.state is FetchedOrders && (orderCubit.state as FetchedOrders).hasMore) {
        orderCubit.fetchMoreOrders(userAuthCubit);
      }
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
                // Filter orders based on selected chips and queried ID
                // Convert to List immediately for predictable behavior
                var filteredOrders = state.orders.where(
                  (element) =>
                      selectedChips.contains(element.orderType) &&
                      (queriedId != null
                          ? element.id.toString().contains("$queriedId")
                          : true),
                ).toList(); // Convert to List

                // Display "No orders found" if the filtered list is empty
                if (filteredOrders.isEmpty) {
                  // Check if more orders exist, if so, attempt to fetch more.
                  // This handles cases where filtering might empty the list temporarily.
                  if (state.hasMore) {
                    // Trigger fetch and show loading indicator while doing so
                    // This helps to avoid showing "No orders found" if more are coming
                  orderCubit.fetchMoreOrders(userAuthCubit);
                    return const OrdersLoadingWidget();
                  } else {
                    // If no more orders are available and list is empty, show the message
                    return Center(
                    child: Text(Translations.foundNoOrders.name.tr()),
                  );
                }
                }

                // If there are filtered orders and we have few items but more data is available,
                // trigger fetch for more data to ensure smoother scrolling.
                if (filteredOrders.length < 5 && state.hasMore) {
                  orderCubit.fetchMoreOrders(userAuthCubit);
                }

                // Build the ListView. We know filteredOrders is not empty here.
                return ListView.separated(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    // Access element at index. filteredOrders.length is guaranteed to be >= 1 here.
                    return OrderCard(
                      order: filteredOrders.elementAt(index),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: filteredOrders.length, // Use the length of the filtered list
                );
              } else {
                // Fallback for any unhandled states
                return const Center(child: Text('Unknown state'));
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
    setState(() { // Ensure setState is called to trigger rebuild
    if (selectedChips.contains(orderType)) {
      if (selectedChips.length > 1) {
        selectedChips.remove(orderType);
      }
    } else {
      selectedChips.add(orderType);
    }
    });
  }
}

