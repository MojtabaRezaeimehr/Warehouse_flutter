import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_amf/models/remote/scanned_child.dart';
import 'package:warehouse_amf/screens/order_details/widgets/expansion.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_else_widget.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_widget.dart';
import 'package:warehouse_amf/screens/widgets/detail_row.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class ScannedChildCard extends StatefulWidget {
  const ScannedChildCard(
      {super.key, required this.scannedChild, this.showChildColor,required this.orderId});

  final ScannedChild scannedChild;
  final Color? showChildColor;
  final int orderId;

  @override
  State<ScannedChildCard> createState() => _OrderDetailCardState();
}

class _OrderDetailCardState extends State<ScannedChildCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: widget.scannedChild.hasChildren
                ? const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )
                : BorderRadius.circular(8),
            color: widget.showChildColor ??
                Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              DetailRow(
                    title: Translations.uid.name.tr(),
                    value:widget.scannedChild.uid,
                  ),
              IfElseWidget(
                condition: widget.scannedChild.hasChildren,
                ifWidget: const Divider(),
                elseWidget: const SizedBox(height: 10),
              ),
              IfWidget(
                condition: widget.scannedChild.hasChildren,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DetailRow(
                    title: Translations.packingLevel.name.tr(),
                    value: "${widget.scannedChild.levelId}",
                  ),
                ),
              ),
            ],
          ),
        ),
        IfWidget(
          condition: widget.scannedChild.hasChildren,
          child: Expansion(
            isTheHighestlevel: false,
            uid: widget.scannedChild.uid,
            showChildColor: widget.showChildColor,
            orderId: widget.orderId,
          ),
        ),
      ],
    );
  }
}
