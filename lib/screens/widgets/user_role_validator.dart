import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/screens/settings/cubit/user_role_cubit.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class UserRoleValidator extends StatefulWidget {
  const UserRoleValidator({
    super.key,
    this.onSubmit,
    this.onCancel,
    this.onCancelText,
  });

  final Function(String value)? onSubmit;
  final VoidCallback? onCancel;
  final Text? onCancelText;

  @override
  State<UserRoleValidator> createState() => _UserRoleValidatorState();
}

class _UserRoleValidatorState extends State<UserRoleValidator> {
  final controller = TextEditingController();
  late UserRoleCubit userRoleCubit;

  @override
  void initState() {
    userRoleCubit = BlocProvider.of<UserRoleCubit>(context);
    super.initState();
  }

  @override
  void dispose() {
    userRoleCubit.stopValidating();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRoleCubit, UserRoleState>(
      builder: (context, state) {
        //state is userRoleInitital or user tried with with wring pass
        //show a dialog and let user enter as admin or simple user

        //show error text if user tried to enter admin state with wrong pass
        String? errorText;
        if (state is UserHasWrongPassword) {
          controller.value = TextEditingValue.empty;
          Vibration.vibrate();
          errorText = Translations.wrongPassword.name.tr();
        }
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translations.enterAdminPassword.name.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 25),
                TextField(
                  obscureText: true,
                  controller: controller,
                  onSubmitted: (value) async {
                    await userRoleCubit.updateUserRole(controller.text.trim());
                    await widget.onSubmit?.call(value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                    ),
                    errorText: errorText,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await userRoleCubit
                            .updateUserRole(controller.text.trim());
                        await widget.onSubmit?.call(controller.text.trim());
                      },
                      child: Text(Translations.confirm.name.tr()),
                    ),
                    TextButton(
                      onPressed: () {
                        userRoleCubit.enterAsUser();
                        widget.onCancel?.call();
                      },
                      child: widget.onCancelText ??
                          Text(Translations.cancel.name.tr()),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
