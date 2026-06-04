import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/screens/scan/widget/scan_count_visualizer.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_else_widget.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class ScanDetail extends StatefulWidget {
  const ScanDetail({super.key});

  @override
  State<ScanDetail> createState() => _ScanDetailState();
}

class _ScanDetailState extends State<ScanDetail> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewOrderCubit, NewOrderState>(
      builder: (context, state) {
        String title = "${Translations.recieverCompany.name.tr()}:";
        String disName = "-";
        List<ScannedProduct> scannedProducts = [];

        if (state is OrderStartedState) {
          scannedProducts = state.scannedProducts;
          if (state.orderTypes == OrderTypes.incoming) {
            title = Translations.incomingOrder.name.tr();
            disName = "";
          } else if (state.orderTypes == OrderTypes.returning) {
            title = "${Translations.returnerCompany.name.tr()}:";
            disName = state.distributer?.name ?? "null";
          } else if (state.orderTypes == OrderTypes.outgoing) {
            disName = state.distributer?.name??"null";
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    disName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(),
            IfElseWidget(
              condition: scannedProducts.isEmpty,
              ifWidget: Expanded(
                child: Center(
                  child: Text(
                    Translations.scanHistroyWillBeShownHere.name.tr(),
                  ),
                ),
              ),
              elseWidget: Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return ScanCountVisualizer(
                      scanQuantity: scannedProducts[index].scanQuantity,
                      maxScanQuantity: scannedProducts[index].maxScanQuantity,
                      productName: scannedProducts[index].product.name,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemCount: scannedProducts.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
