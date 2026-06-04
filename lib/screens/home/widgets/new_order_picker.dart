import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/screens/home/widgets/api_order_picker.dart';
import 'package:warehouse_amf/screens/home/widgets/company_picker.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class NewOrderPicker extends StatelessWidget {
  const NewOrderPicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 272,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              Navigator.pushNamed(context, kRouteScan);
              BlocProvider.of<NewOrderCubit>(context).startIncomingOrder();
            },
            child: ListTile(
              title: Text(Translations.incomingOrder.name.tr()),
              leading: const Icon(Icons.input),
            ),
          ),
          const Divider(),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Container(
                    height: MediaQuery.sizeOf(context).height * 0.75,
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
                    child: const CompanyPicker(
                      orderType: OrderTypes.outgoing,
                    ),
                  );
                },
              );
            },
            child: ListTile(
              title: Text(Translations.outgoingOrder.name.tr()),
              leading: const Icon(Icons.output),
            ),
          ),
          const Divider(),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Container(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
                    child: const CompanyPicker(
                      orderType: OrderTypes.returning,
                    ),
                  );
                },
              );
            },
            child: ListTile(
              title: Text(Translations.returningOrder.name.tr()),
              leading: const Icon(Icons.keyboard_return),
            ),
          ),
          const Divider(),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Container(
                    height: MediaQuery.sizeOf(context).height * 0.75,
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
                    child: const ApiOrderPicker(),
                  );
                },
              );
            },
            child: ListTile(
              title: Row(
                children: [
                  Text(Translations.outgoingOrder.name.tr()),
                  Text(" (${Translations.systematic.name.tr()}) "),
                ],
              ),
              leading:    const Icon(Icons.api),
            ),
          ),
        ],
      ),
    );
  }
}
