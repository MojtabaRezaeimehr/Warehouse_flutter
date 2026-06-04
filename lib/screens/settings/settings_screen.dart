import 'package:flutter/material.dart';
import 'package:warehouse_amf/screens/settings/widgets/connection_section.dart';
import 'package:warehouse_amf/screens/settings/widgets/customization_section.dart';
import 'package:warehouse_amf/screens/settings/widgets/logo_and_ver.dart';
import 'package:warehouse_amf/screens/settings/widgets/printing_section.dart';
import 'package:warehouse_amf/screens/settings/widgets/scan_section.dart';
import 'package:warehouse_amf/screens/settings/widgets/share_logs_button.dart';
import 'package:warehouse_amf/screens/settings/widgets/user_profile.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LogoAndVer(),
          UserProfile(),
          //for sake of different spacing and not using multiple sizedbox
          //these widg are wrapped with a column
          Column(
            spacing: 5,
            children: [
              CustomizationSection(),
              ConnectionSection(),
              ScanSection(),
              PrintingSection(),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ShareLogsButton(),
          )
        ],
      ),
    );
  }
}
