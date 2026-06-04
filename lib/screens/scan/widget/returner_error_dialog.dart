
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/utils/enums/scanner_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class ReturnerErrorDialog extends StatefulWidget {
  const ReturnerErrorDialog(
    this.barcode,
    this.scannerType, {
    super.key,
  });
  final String barcode;
  final ScannerType scannerType;

  @override
  State<ReturnerErrorDialog> createState() => _ReturnerErrorDialogState();
}

class _ReturnerErrorDialogState extends State<ReturnerErrorDialog> {
  MenuController menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        MenuAnchor(
          consumeOutsideTap: true,
          controller: menuController,
          menuChildren: [
            Container(
              width: 200,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Translations.whatIsReturnerError.name.tr(),
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translations.returnerError.name.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                constraints: const BoxConstraints(maxHeight: 30, maxWidth: 30),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                ),
                onPressed: () =>
                    menuController.isOpen ? null : menuController.open(),
                icon: Transform.flip(
                  flipX: context.locale == const Locale('fa'),
                  child: Icon(
                    Icons.question_mark,
                    size: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(Translations.wishToContinue.name.tr()),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                var scanCubit = BlocProvider.of<ScanCubit>(context);
                var scanReq = scanCubit.generateScanRequest(widget.barcode,
                    forceUpdate: true);
                scanCubit.postBarcode(scanReq, widget.scannerType);
              },
              child: Text(
                Translations.confirm.name.tr(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                Translations.cancel.name.tr(),
              ),
            ),
          ],
        )
      ],
    );
  }
}
