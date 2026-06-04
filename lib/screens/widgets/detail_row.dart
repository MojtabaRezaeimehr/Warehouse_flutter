import 'package:flutter/material.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_widget.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    this.iconData,
    required this.title,
    required this.value,
  });

  final IconData? iconData;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 5),
        Text(
          title,
        ),
        const Text(
          " : ",
        ),
        Text(
          value,
        ),
        IfWidget(condition: iconData != null, child: const Spacer()),
        IfWidget(
          condition: iconData != null,
          child: Icon(
            iconData,
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}
