import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warehouse_amf/models/local/barcode.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/utils/color/color.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';
import 'package:warehouse_amf/utils/enums/scan_responses.dart';
import 'package:warehouse_amf/utils/enums/scan_type.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Barcode>? barcodes;

  @override
  void initState() {
    () async {
      LocalServices.scannedHistoryRepo.readAllHistory().then(
        (barcodes) {
          barcodes.sort(
            (a, b) => b.scanDate.compareTo(a.scanDate),
          );
          setState(() {
            this.barcodes = barcodes;
          });
        },
      );
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        duration: kShimmerDuration,
        baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
        highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      enabled: barcodes == null,
      child: ListView.separated(
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 5,
                children: [
                  Text(
                    barcodes?[index].value ?? "55456565548554",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        barcodes != null
                            ? barcodes![index]
                                .scanDate
                                .toPersianDate(showTime: true)
                            : "13:28 1404/047/17",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      label(
                        barcodes?[index].scanResponse.name.tr(),
                        barcodes != null
                            ? barcodes![index].scanResponse == ScanResponses.ok
                                ? greenColor
                                : redColor
                            : null,
                      ),
                      const SizedBox(width: 5),
                      label(
                        barcodes?[index].scanType.name.tr(),
                        barcodes != null
                            ? barcodes![index].scanType == ScanType.add
                                ? greenColor
                                : redColor
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 30,
        ),
        itemCount: barcodes?.length ?? 10,
      ),
    );
  }

  Container label(String? text, Color? labelColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: labelColor,
      ),
      child: Text(
        text ?? "abab",
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
