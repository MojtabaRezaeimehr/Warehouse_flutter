import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/order_detail_cubit.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/screens/orders/widgets/delete_option.dart';
import 'package:warehouse_amf/screens/orders/widgets/print_label.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_widget.dart';
import 'package:warehouse_amf/screens/widgets/detail_row.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              height: order.orderType == OrderTypes.outgoing ? 219 : 154,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  DeleteOption(order: order),
                  const Divider(),
                  InkWell(
                    onTap: () {
                      var orderStarted = BlocProvider.of<NewOrderCubit>(context)
                          .resumeOrder(order);
                      if (orderStarted) {
                        Navigator.of(context).popAndPushNamed(kRouteScan);
                      } else {
                        ToastHelper.showErrorToast(
                          Text(Translations.error.name.tr()),
                          Text(Translations.failedToEditTheOrder.name.tr()),
                        );
                        Vibration.vibrate();
                      }
                    },
                    child: ListTile(
                      leading: const Icon(
                        Icons.edit,
                      ),
                      title: Text(Translations.editOrder.name.tr()),
                    ),
                  ),
                  const Divider(),
                  IfWidget(
                    condition: order.orderType == OrderTypes.outgoing,
                    child: PrintLabel(
                      order: order,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        child: Column(
          children: [
            const Spacer(),
            DetailRow(
              iconData: Icons.key,
              title: Translations.id.name.tr(),
              value: "${order.id}",
            ),
            const Divider(),
            DetailRow(
              iconData: Icons.merge_type,
              title: Translations.orderType.name.tr(),
              value: order.orderType.name.tr(),
            ),
            const Divider(),
            IfWidget(
              condition: order.orderType != OrderTypes.incoming,
              child: DetailRow(
                iconData: Icons.apartment,
                title: order.orderType == OrderTypes.outgoing
                    ? Translations.recieverCompany.name.tr()
                    : Translations.returnerCompany.name.tr(),
                value: order.distributer?.name ?? "-",
              ),
            ),
            IfWidget(
              condition: order.orderType == OrderTypes.incoming,
              child: DetailRow(
                iconData: Icons.apartment,
                title: Translations.scannedCount.name.tr(),
                value: "${order.scannedCount}",
              ),
            ),
            const Divider(),
            DetailRow(
              iconData: Icons.code,
              title: Translations.documentCode.name.tr(),
              value: order.documentNo != null && order.documentNo!.isNotEmpty
                  ? order.documentNo!
                  : " - ",
            ),
            const Divider(),
            DetailRow(
              iconData: Icons.date_range,
              title: Translations.date.name.tr(),
              value: order.date.toPersianDate(showTime: true),
            ),
            const Spacer(),
            InkWell(
              onTap: () {},
              splashColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<OrderDetailCubit>(context)
                        .fetchOrderDetails(order.id);
                    Navigator.pushNamed(context, kRouteOrderDetail);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_red_eye,
                          color: Theme.of(context).colorScheme.onPrimary),
                      const SizedBox(width: 5),
                      Text(
                        Translations.seeDetail.name.tr(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
