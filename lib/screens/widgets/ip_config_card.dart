import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:warehouse_amf/screens/login/cubit/card_cubit.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_widget.dart';
import 'package:warehouse_amf/screens/widgets/loading_dialog.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

import '../login/cubit/connection_cubit.dart' as cs;

class IpConfigCard extends StatefulWidget {
  const IpConfigCard({
    super.key,
    this.showBackButton = true,
  });
  final bool showBackButton;

  @override
  State<IpConfigCard> createState() => _IpConfigCardState();
}

class _IpConfigCardState extends State<IpConfigCard> {
  var ipController = TextEditingController();
  var portController = TextEditingController();
  var ipNode = FocusNode();
  var portNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var cardCubit = BlocProvider.of<CardCubit>(context);
    var connectionCubit = BlocProvider.of<cs.ConnectionCubit>(context);

    return BlocListener<cs.ConnectionCubit, cs.ConnectionState>(
      listener: (BuildContext context, cs.ConnectionState connectionState) {
        if (connectionState is cs.ConnectionSuccessfull) {
          ToastHelper.showSuccessToast(
              null, Text(Translations.connectionSucceeded.name.tr()));
          if (widget.showBackButton) {
            //back to login card
            cardCubit.changeState();
          }
        } else if (connectionState is cs.ConnectionFailed) {
          ToastHelper.showErrorToast(null, const Text("connectionFailed").tr());
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IfWidget(
            condition: widget.showBackButton,
            child: IconButton(
              onPressed: () {
                cardCubit.changeState();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              keyboardType: TextInputType.number,
              focusNode: ipNode,
              controller: ipController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              maxLength: 15,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                //this is buggy on web
                if (kIsWeb) {
                  return;
                }
                //max len is 15
                if (value.length >= 15) {
                  return;
                }
                //in case user inputed 199 add a . after it auto
                String lastPart = value.split(".").last;
                if (lastPart.length == 3 &&
                    (lastPart.characters.lastOrNull != ".")) {
                  ipController.value = TextEditingValue(text: "$value.");
                }
                //two dots in a row are not allowed
                if (value.characters.endsWith(Characters(".."))) {
                  ipController.value = TextEditingValue(
                      text: value.substring(0, value.length - 1));
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'ip'.tr(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              keyboardType: TextInputType.number,
              focusNode: portNode,
              controller: portController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: 'port'.tr(),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    LoadingDialog.show(context);

                    String ip = ipController.text.trim();
                    String port = portController.text.trim();
                    //incase ip port is empy use the prev saved base url
                    if (ip.isEmpty && port.isEmpty) {
                      var config = LocalServices.appConfigRepo.fetchConfig();
                      dprint(config.baseUrl);
                      ip = config.baseUrl
                          .substring(7, config.baseUrl.indexOf(":", 7));
                      port = config.baseUrl
                          .substring(config.baseUrl.indexOf(":", 7) + 1);
                      ipController.value = TextEditingValue(text: ip);
                      portController.value = TextEditingValue(text: port);
                      await Future.delayed(const Duration(milliseconds: 500));
                    }

                    await connectionCubit.checkConnection(ip, port);
                    LoadingDialog.dismiss();

                    //disable focus of textfiels
                    ipNode.unfocus();
                    portNode.unfocus();
                  },
                  child: Text(Translations.testConnection.name.tr()),
                ),
                FilledButton(
                  onPressed: () {
                    if (ipController.text.trim().isEmpty ||
                        portController.text.tr().isEmpty) {
                      Vibration.vibrate();
                      ToastHelper.showErrorToast(
                        Text(Translations.error.name.tr()),
                        Text(Translations.fillAllFields.name.tr()),
                      );
                      return;
                    }
                    connectionCubit.updateBaseUrl(
                      ipController.text.trim(),
                      portController.text.trim(),
                    );
                    
                    //back to login card
                    cardCubit.changeState();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: Text(
                    'confirm'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
