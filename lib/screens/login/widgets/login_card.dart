import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/screens/widgets/loading_dialog.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class LogInCard extends StatefulWidget {
  const LogInCard({super.key});

  @override
  State<LogInCard> createState() => _LogInCardState();
}

class _LogInCardState extends State<LogInCard> {
  var usernameController = TextEditingController();
  var passController = TextEditingController();
  var usernameNode = FocusNode();
  var passNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
      child: Column(
        children: [
          const Spacer(),
          TextField(
            focusNode: usernameNode,
            controller: usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelText: Translations.username.name.tr(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          TextField(
            obscureText: true,
            focusNode: passNode,
            controller: passController,
            onSubmitted: (value) async {
              //validate username and pass
              await logInPressed(context);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelText: Translations.password.name.tr(),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                //validate username and pass
                await logInPressed(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              child: Text(
                'login'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Future<void> logInPressed(BuildContext context) async {
    //validate username and pass
    LoadingDialog.show(context);
    var authCubit = BlocProvider.of<UserAuthCubit>(context);
    await authCubit.validateUser(
        usernameController.text.trim(), passController.text.trim());
    LoadingDialog.dismiss();
    //disable focus of textfiels
    usernameNode.unfocus();
    passNode.unfocus();
  }
}
