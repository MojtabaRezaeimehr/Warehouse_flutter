import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_type_cubit.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class ScanTypeSwitch extends StatefulWidget {
  const ScanTypeSwitch({
    super.key,
  });

  @override
  State<ScanTypeSwitch> createState() => _ScanTypeSwitchState();
}

class _ScanTypeSwitchState extends State<ScanTypeSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<Color?> colorTweenAnim;
  late ScanTypeCubit scanTypeCubit;

  @override
  void initState() {
    scanTypeCubit = BlocProvider.of<ScanTypeCubit>(context);
    animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    colorTweenAnim = ColorTween(
      begin: const Color(0xFFA23831),
      end: const Color(0xFF138517),
    ).animate(animController);
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    scanTypeCubit.reset();
    super.dispose();
  }

  //0xFFA23831
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanTypeCubit, ScanTypeState>(
      builder: (context, state) {
        if (state is AddingState) {
          animController.reverse();
        } else {
          animController.forward();
        }
        return AnimatedBuilder(
            animation: colorTweenAnim,
            builder: (context, child) {
              return FilledButton.tonal(
                style: FilledButton.styleFrom(
                  fixedSize: const Size(90, 40),
                  backgroundColor: colorTweenAnim.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => scanTypeCubit.changeState(),
                child: Text(
                  state is AddingState
                      ? Translations.delete.name.tr()
                      : Translations.add.name.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            });
      },
    );
  }
}
