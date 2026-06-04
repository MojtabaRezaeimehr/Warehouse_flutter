
import 'package:flutter/material.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_widget.dart';
//this widget intends to show info about products and companies fetched from server
class InfoCard extends StatelessWidget {
  final String title;
  final String desc;
  final String? subDesc;
  const InfoCard({
    super.key,
    required this.title,
    required this.desc,
    this.subDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis
            ),
          ),
          Text(
            desc,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          IfWidget(
            condition: subDesc != null,
            child: Text(
              "$subDesc",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
