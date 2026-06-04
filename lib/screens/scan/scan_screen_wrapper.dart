import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/screens/scan/cubit/android_scanner_cubit.dart';
import 'package:warehouse_amf/screens/scan/scan_screen.dart';
import 'package:warehouse_amf/screens/scan/widget/starting_order_state.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_else_widget.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class ScanScreenWrapper extends StatelessWidget {
  const ScanScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Vibration.vibrate();
          ToastHelper.showToast(Text(Translations.pleaseUseTheFinishButton.name.tr()));
        }
      },
      child: BlocBuilder<NewOrderCubit, NewOrderState>(
        builder: (context, state) {
          if (state is NewOrderInitial || state is StartingOrderState) {
            return const StartingOrderStateWidget();
          } else if (state is StartingOrderErrorState) {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      Translations.ok.name.tr(),
                    ),
                  )
                ],
              ),
            );
          }
          return IfElseWidget(
            condition: Theme.of(context).platform == TargetPlatform.android,
            ifWidget: BlocProvider(
              create: (context) => AndroidScannerCubit(),
              child: const ScanScreen(),
            ),
            elseWidget: const ScanScreen(),
          );
        },
      ),
    );
  }
}
