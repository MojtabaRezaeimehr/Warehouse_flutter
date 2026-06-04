import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/screens/widgets/custom/flip_view.dart';
import 'package:warehouse_amf/utils/color/color.dart';
import 'package:warehouse_amf/utils/enums/scan_responses.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';

//this widget acts like a wrapper to keep flipView reusable and independent

class ResultViewer extends StatefulWidget {
  const ResultViewer({
    super.key,
  });

  @override
  State<ResultViewer> createState() => _ResultViewerState();
}

class _ResultViewerState extends State<ResultViewer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanCubit, ScanState>(
      builder: (context, state) {
        bool showFrontCard = true;

        if (state is PostedBarcode &&
            state.scanDate
                .add(const Duration(seconds: 2))
                .isAfter(DateTime.now())) {
          showFrontCard = false;
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {});
            }
          });
        }

        return FlipView(
          // key: UniqueKey(),
          valueNotifier: ValueNotifier(showFrontCard),
          showFrontCard: showFrontCard,
          frontCard: Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceContainerHigh),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translations.uid.name.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  state is PostingBarcodeDone
                      ? getUidFromBarcode(state.barcode) ??
                          Translations.error.name.tr()
                      : "",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          backCard: Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: (state is PostedBarcode &&
                      state.scanResponse == ScanResponses.ok)
                  ? greenColor 
                  :   redColor,
            ),
            child: Text(
              state is PostedBarcode
                  ? state.scanResponse.name.tr()
                  : state is PostingBarcodeError
                      ? state.error
                      : "",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
