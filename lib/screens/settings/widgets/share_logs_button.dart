import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warehouse_amf/screens/widgets/loading_dialog.dart';
import 'package:warehouse_amf/services/local/log/log_service.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class ShareLogsButton extends StatelessWidget {
  const ShareLogsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    //! dont remove this line,if so the button text wont update according to locale changes
    EasyLocalization.of(context)?.locale;

    return FilledButton.icon(
      label: Text(Translations.shareLogs.name.tr()),
      onPressed: () async {
        LoadingDialog.showLightDialog(context);
        var logs = await LogService().readAllLogsAsString();

        if (kIsWeb) {
          await Share.share(logs);
        } else {
          var path = await getTemporaryDirectory();
          var file = File("${path.absolute.path}/logs.txt");
          var xFile = XFile("${path.absolute.path}/logs.txt");
          await file.writeAsString(logs);

          await Share.shareXFiles([xFile]);
        }
        LoadingDialog.dismiss();
      },
      icon: const Icon(Icons.share),
    );
  }
}
