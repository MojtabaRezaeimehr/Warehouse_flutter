import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/order_detail_cubit.dart';
import 'package:warehouse_amf/screens/order_details/widgets/order_detail_card.dart';
import 'package:warehouse_amf/screens/orders/widgets/orders_loading_widget.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String? queriedString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  suffixIcon: const Icon(Icons.search),
                  hintText: Translations.search.name.tr(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => queryInOrders(value),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
                  builder: (context, state) {
                    if (state is LoadingOrderDetails ||
                        state is OrderDetailInitial) {
                      return const OrdersLoadingWidget();
                    } else if (state is LoadingOrdersDetailsError) {
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
                    } else if (state is FetchedOrderDetails) {
                      if (state.orderDetails.isEmpty) {
                        return Center(
                          child: Text(Translations.foundNoBarcode.name.tr()),
                        );
                      }

                      //filter orders
                      var filteredOrders = state.orderDetails
                          .where(
                            (element) => queriedString != null
                                ? element.uid.contains(queriedString!)
                                : true,
                          )
                          .toList();

                      if (filteredOrders.isEmpty) {
                        return Center(
                          child: Text(Translations.foundNoBarcode.name.tr()),
                        );
                      }

                      return ListView.separated(
                        itemBuilder: (context, index) {
                          return OrderDetailCard(
                            orderDetail: filteredOrders[index],
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
          ),
        ),
      ),
    );
  }

  void queryInOrders(String uid) {
    setState(() {
      uid.isNotEmpty ? queriedString = uid : queriedString = null;
    });
  }
}
