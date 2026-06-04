import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class ResumeDialog extends StatelessWidget {
  const ResumeDialog({
    super.key, this.title,
  });

  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(8),
      title: title,
      children: [
        const SizedBox(height: 10),
        Text(
          Translations.wishToContinue.name.tr(),
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(Translations.cancel.name.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(Translations.confirm.name.tr()),
            ),
          ],
        )
      ],
    );
  }
}
