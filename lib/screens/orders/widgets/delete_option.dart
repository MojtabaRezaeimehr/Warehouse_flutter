
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/order_cubit.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/screens/settings/cubit/user_role_cubit.dart';
import 'package:warehouse_amf/screens/widgets/user_role_validator.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class DeleteOption extends StatelessWidget {
  const DeleteOption({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              children: [
                UserRoleValidator(
                  onCancel: () => Navigator.popUntil(
                    context,
                    ModalRoute.withName(kRouteHome),
                  ),
                  onSubmit: (value) async {
                    if (BlocProvider.of<UserRoleCubit>(context)
                        .state is! UserIsAdmin) {
                      return;
                    }
    
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName(kRouteHome),
                    );
                    var result =
                        await BlocProvider.of<OrderCubit>(context)
                            .deleteOrder(order.id);
                    if (result != null) {
                      ToastHelper.showErrorToast(
                        Text(Translations.error.name.tr()),
                        Text(result),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        leading: const Icon(
          Icons.delete,
        ),
        title: Text(Translations.deleteOrder.name.tr()),
      ),
    );
  }
}
