import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/screens/settings/cubit/expansion_cubit.dart';
import 'package:warehouse_amf/screens/settings/cubit/user_role_cubit.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_else_widget.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_widget.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class ScanSection extends StatefulWidget {
  const ScanSection({
    super.key,
  });

  @override
  State<ScanSection> createState() => _ScanSectionState();
}

class _ScanSectionState extends State<ScanSection> {
  var expansionController = ExpansibleController();
  var intentActionController = TextEditingController();
  var intentDataController = TextEditingController();
  AppConfig? appConfig;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        getInitialSize();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    intentActionController.dispose();
    super.dispose();
  }

  void getInitialSize() async {
    var config = LocalServices.appConfigRepo.fetchConfig();
    setState(() {
      appConfig = config;
    });
  }

  @override
  Widget build(BuildContext context) {
    var expansionCubit = BlocProvider.of<ExpansionCubit>(context);

    return BlocListener<ExpansionCubit, ExpansionState>(
      listener: (context, state) {
        if (state is! ScaningExpanded && expansionController.isExpanded) {
          expansionController.collapse();
        }
      },
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        controller: expansionController,
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        collapsedBackgroundColor:
            Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onExpansionChanged: (value) {
          if (value) {
            expansionCubit.expandScanning();
          }
        },
        title: Text(
          Translations.scanning.name.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          IfElseWidget(
            condition:
                BlocProvider.of<UserRoleCubit>(context).state is UserIsAdmin,
            ifWidget: intentConfigRow(
              context,
              intentActionController,
              AppConfigKey.inentAction,
            ),
            elseWidget: Center(
              child: Text(Translations.accessDenied.name.tr()),
            ),
          ),
          const SizedBox(height: 10),
          IfWidget(
            condition:
                BlocProvider.of<UserRoleCubit>(context).state is UserIsAdmin,
            child: intentConfigRow(
              context,
              intentDataController,
              AppConfigKey.intentDataKey,
            ),
          ),
        ],
      ),
    );
  }

  Row intentConfigRow(BuildContext context, TextEditingController controller,
      AppConfigKey appConfigKey) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: appConfigKey == AppConfigKey.inentAction
                  ? appConfig?.inentAction
                  : appConfig?.intentDataKey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          icon: const Icon(Icons.done),
          onPressed: () {
            if (appConfig == null) {
              return;
            }
            if (controller.text.isEmpty) {
              Vibration.vibrate();
              ToastHelper.showErrorToast(
                Text(Translations.error.name.tr()),
                Text(Translations.fillAllFields.name.tr()),
              );
              return;
            }

            LocalServices.appConfigRepo.updateConfig(
              appConfigKey,
              controller.text,
            );
            appConfig = AppConfig.updateWithKeyValue(
              appConfigKey,
              controller.text,
              appConfig!,
            );
            controller.value = TextEditingValue.empty;
            ToastHelper.showSuccessToast(
              null,
              Text(Translations.updatedSettings.name.tr()),
            );
            //effect appconfig changes
            setState(() {});
          },
        ),
        const SizedBox(width: 5),
        IconButton.filledTonal(
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: const Icon(Icons.copy),
          onPressed: () {
            if (appConfig != null) {
              Clipboard.setData(ClipboardData(
                text: appConfigKey == AppConfigKey.inentAction
                    ? appConfig!.inentAction
                    : appConfig!.intentDataKey,
              ));
              ToastHelper.showSuccessToast(
                null,
                Text(Translations.copied.name.tr()),
              );
            }
          },
        ),
      ],
    );
  }
}
