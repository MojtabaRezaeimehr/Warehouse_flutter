import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/bloc/cubit/theme_cubit.dart';
import 'package:warehouse_amf/screens/settings/cubit/expansion_cubit.dart';
import 'package:warehouse_amf/screens/settings/cubit/user_role_cubit.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class CustomizationSection extends StatefulWidget {
  const CustomizationSection({
    super.key,
  });

  @override
  State<CustomizationSection> createState() => _CustomizationSectionState();
}

class _CustomizationSectionState extends State<CustomizationSection> {
  var controller = TextEditingController();
  var expansionController = ExpansibleController();

  var langSelection = [true, false];
  var themeSelection = [true, false];

  String deviceId = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getDeviceId(Theme.of(context).platform).then(
        (value) => setState(() {
          deviceId = value;
        }),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var expansionCubit = BlocProvider.of<ExpansionCubit>(context);
    var themeCubit = BlocProvider.of<ThemeCubit>(context);

    return BlocListener<ExpansionCubit, ExpansionState>(
      listener: (context, state) {
        if (state is! CustomizationExpanded && expansionController.isExpanded) {
          expansionController.collapse();
        }
      },
      child: ExpansionTile(
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
            expansionCubit.expandCustomization();
          }
        },
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          Translations.customization.name.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Column(
            spacing: 5,
            children: [
              const SizedBox(height: 2),
              BlocBuilder<UserRoleCubit, UserRoleState>(
                builder: (context, state) {
                  if (state is UserIsAdmin) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              label: Text(Translations.newPassword.name.tr()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          icon: const Icon(Icons.done),
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              LocalServices.appConfigRepo.updateConfig(
                                  AppConfigKey.password, controller.text);
                              controller.value = TextEditingValue.empty;
                              ToastHelper.showSuccessToast(null,
                                  Text(Translations.passwordUpdated.name));
                            } else {
                              Vibration.vibrate();
                              ToastHelper.showErrorToast(
                                Text(Translations.error.name.tr()),
                                Text(
                                    Translations.passwordCantBeEmpty.name.tr()),
                              );
                            }
                          },
                        )
                      ],
                    );
                  } else {
                    return Text(Translations.accessDenied.name.tr());
                  }
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Translations.appLanguage.name.tr()),
                  ToggleButtons(
                    constraints:
                        const BoxConstraints(minWidth: 58, minHeight: 48),
                    isSelected: context.locale.languageCode == "fa"
                        ? [true, false]
                        : [false, true],
                    children: <Widget>[
                      const Text('فارسی'),
                      const Text('English'),
                    ],
                    onPressed: (int index) async {
                      context.setLocale(
                        index == 0 ? const Locale("fa") : const Locale("en"),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Translations.appTheme.name.tr()),
                  ToggleButtons(
                    constraints:
                        const BoxConstraints(minWidth: 58, minHeight: 48),
                    isSelected: themeCubit.state is DarkTheme
                        ? [false, true]
                        : [true, false],
                    children: <Widget>[
                      Text(Translations.light.name.tr()),
                      Text(Translations.dark.name.tr()),
                    ],
                    onPressed: (int index) {
                      themeCubit.changeState();
                    },
                  ),
                ],
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: deviceId),
                  );
                  ToastHelper.showToast(
                    Text("${Translations.copiedCode.name.tr()} $deviceId"),
                  );
                },
                child: Text("${Translations.deviceCode.name.tr()} $deviceId"),
              ),
              const SizedBox(height: 5)
            ],
          ),
        ],
      ),
    );
  }
}
