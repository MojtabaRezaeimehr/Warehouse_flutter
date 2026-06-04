import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/models/local/app_config.dart';
import 'package:warehouse_amf/screens/settings/cubit/expansion_cubit.dart';
import 'package:warehouse_amf/screens/widgets/custom/number_picker.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class PrintingSection extends StatefulWidget {
  const PrintingSection({
    super.key,
  });

  @override
  State<PrintingSection> createState() => _PrintingSectionState();
}

class _PrintingSectionState extends State<PrintingSection> {
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
        if (state is! PrintingExpanded && expansionController.isExpanded) {
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
            expansionCubit.expandPrinting();
          }
        },
        title: Text(
          Translations.printing.name.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          NumberPicker(
            label: Text(
              Translations.fontSize.name.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            initialValue: int.parse(appConfig?.fontSize ?? "1"),
            onDecrement: (int val) => LocalServices.appConfigRepo
                .updateConfig(AppConfigKey.fontSize, "$val"),
            onIncrement: (int val) => LocalServices.appConfigRepo
                .updateConfig(AppConfigKey.fontSize, "$val"),
          ),
          const Divider(height: 30),
          NumberPicker(
            label: Text(
              Translations.labelSize.name.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            initialValue: int.parse(appConfig?.labelSize ?? "1"),
            onDecrement: (int val) => LocalServices.appConfigRepo
                .updateConfig(AppConfigKey.labelSize, "$val"),
            onIncrement: (int val) => LocalServices.appConfigRepo
                .updateConfig(AppConfigKey.labelSize, "$val"),
          ),
        ],
      ),
    );
  }
}
