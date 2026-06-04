import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/scanned_child.dart';
import 'package:warehouse_amf/screens/order_details/widgets/scanned_child_card.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class Expansion extends StatefulWidget {
  const Expansion(
      {super.key,
      required this.uid,
      required this.orderId,
      this.showChildColor,
      required this.isTheHighestlevel});
  final String uid;
  final int orderId;
  final Color? showChildColor;
  final bool isTheHighestlevel;

  @override
  State<Expansion> createState() => _ExpansionState();
}

class _ExpansionState extends State<Expansion> {
  Future<ApiResponse<List<ScannedChild>>>? futureScannedChild;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        Translations.showChildren.name.tr(),
      ),
      leading: const Icon(
        Icons.account_tree,
      ),
      collapsedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      childrenPadding: const EdgeInsets.all(8.0),
      backgroundColor: widget.showChildColor ??
          Theme.of(context).colorScheme.surfaceContainerLow,
      collapsedBackgroundColor: widget.isTheHighestlevel
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.tertiaryContainer,
      collapsedIconColor: widget.isTheHighestlevel
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onTertiaryContainer,
      collapsedTextColor: widget.isTheHighestlevel
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onTertiaryContainer,
      iconColor: Theme.of(context).colorScheme.onSurface,
      textColor: Theme.of(context).colorScheme.onSurface,
      onExpansionChanged: (opened) {
        if (opened) {
          futureScannedChild ??= RemoteServices.ordersRepo.fetchScannedChildren(widget.uid, widget.orderId).then(
              (value) {
                setState(() {});
                return value;
              },
            );
        }
      },
      children: [
        FutureBuilder(
          future: futureScannedChild,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData && snapshot.data is ApiResponseFailed) {
              return Text((snapshot.data as ApiResponseFailed).message);
            }
            return Column(
              children: snapshot.data!.values!.map(
                (scannedChild) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ScannedChildCard(
                      orderId: widget.orderId,
                      scannedChild: scannedChild,
                      showChildColor: widget.showChildColor ==
                                  Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow ||
                              widget.showChildColor == null
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}
