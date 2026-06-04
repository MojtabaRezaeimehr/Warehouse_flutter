import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:warehouse_amf/models/remote/order/order_detail.dart';
import 'package:warehouse_amf/screens/order_details/widgets/expansion.dart';
import 'package:warehouse_amf/screens/widgets/detail_row.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class OrderDetailCard extends StatefulWidget {
  const OrderDetailCard({super.key, required this.orderDetail});

  final OrderDetail orderDetail;

  @override
  State<OrderDetailCard> createState() => _OrderDetailCardState();
}

class _OrderDetailCardState extends State<OrderDetailCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              DetailRow(
                  iconData: Icons.key,
                  title: Translations.uid.name.tr(),
                  value: widget.orderDetail.uid),
              const Divider(),
              DetailRow(
                  iconData: Icons.token,
                  title: Translations.product.name.tr(),
                  value: widget.orderDetail.productFaName),
              const Divider(),
              DetailRow(
                  iconData: Icons.numbers,
                  title: Translations.packingLevel.name.tr(),
                  value: "${widget.orderDetail.levelId}"),
              const Divider(),
              DetailRow(
                  iconData: Icons.precision_manufacturing,
                  title: Translations.productionOrder.name.tr(),
                  value: widget.orderDetail.productionOrderId),
              const Divider(),
              DetailRow(
                  iconData: Icons.warehouse,
                  title: Translations.warehouseOrder.name.tr(),
                  value: "${widget.orderDetail.warehouseOrderId}"),
              const Divider(),
              DetailRow(
                  iconData: Icons.date_range,
                  title: Translations.date.name.tr(),
                  value: DateTime.parse(widget.orderDetail.createdAt)
                      .toPersianDate(showTime: true)),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Expansion(
          isTheHighestlevel: true,
          uid: widget.orderDetail.uid,
          showChildColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          orderId: widget.orderDetail.warehouseOrderId,
        ),
      ],
    );
  }
}
