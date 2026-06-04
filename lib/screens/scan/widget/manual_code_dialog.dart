import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';

class ManualCodeDialog extends StatefulWidget {
  const ManualCodeDialog({
    super.key,
  });

  @override
  State<ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<ManualCodeDialog> {
  TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16),
      children: [
        TextField(
          onSubmitted: (value) {
            submit(context);
          },
          onChanged: (value) {
            //barcode is inserted using laser(hand-held) on web
            //if so automatically start creating scan req and post to server
            if (isBarcodeValid(value.trim())) {
              submit(context);
            }
          },
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            hintText: Translations.enterLabelId.name.tr(),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Translations.rndCode.name.tr()),
              Text(Translations.uid.name.tr()),
              Text(Translations.barcode.name.tr()),
            ],
          ),
        ),
        const SizedBox(height: 5),
        TextButton(
          onPressed: () {
            submit(context);
          },
          child: Text(
            Translations.confirm.name.tr(),
          ),
        ),
      ],
    );
  }

  void submit(BuildContext context) {
    BlocProvider.of<ScanCubit>(context)
        .createBarcodeAndPost(textController.text.trim());
    Navigator.of(context).pop();
  }
}
