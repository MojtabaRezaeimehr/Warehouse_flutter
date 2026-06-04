import 'package:flutter/material.dart';

class ScanCountVisualizer extends StatelessWidget {
  final String productName;
  final int scanQuantity;
  final int? maxScanQuantity;
  const ScanCountVisualizer({
    super.key,
    required this.scanQuantity,
    required this.productName,
    this.maxScanQuantity,
  })  : assert((maxScanQuantity ?? scanQuantity) >= scanQuantity),
        assert(maxScanQuantity != 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(productName),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                value: maxScanQuantity != null
                    ? scanQuantity / maxScanQuantity!
                    : 1,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 80,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                "$scanQuantity${maxScanQuantity != null ? "/$maxScanQuantity" : ""}",
                style: TextTheme.of(context).titleMedium,
              ),
            ),
          ],
        )
      ],
    );
  }
}
