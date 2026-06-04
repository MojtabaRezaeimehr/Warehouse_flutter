import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

import '../../../utils/consts/app_version.dart';

class LogoAndVer extends StatelessWidget {
  const LogoAndVer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryFixed,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/amf.png",
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 5),
          Text(
            "${Translations.version.name.tr()} $kVersion",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}
