import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/screens/settings/cubit/user_role_cubit.dart';
import 'package:warehouse_amf/screens/settings/settings_screen.dart';
import 'package:warehouse_amf/screens/widgets/user_role_validator.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

//this widget is a wrppaer to settings page
//it checks whether user is admin or not
class SettingsWrapperPage extends StatefulWidget {
  const SettingsWrapperPage({super.key});

  @override
  State<SettingsWrapperPage> createState() => _SettingsWrapperPageState();
}

class _SettingsWrapperPageState extends State<SettingsWrapperPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRoleCubit, UserRoleState>(
      builder: (context, state) {
        if (state is UserRoleInitial || state is UserHasWrongPassword) {
          return UserRoleValidator(
            onCancelText: Text(
              Translations.userEnter.name.tr(),
            ),
          );
        } else {
          return const SettingsPage();
        }
      },
    );
  }
}
