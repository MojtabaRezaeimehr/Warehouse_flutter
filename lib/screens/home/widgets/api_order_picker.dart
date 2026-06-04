import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/screens/home/cubit/api_search_cubit.dart';
import 'package:warehouse_amf/screens/widgets/info_card.dart';
import 'package:warehouse_amf/screens/widgets/resume_dialog.dart';
import 'package:warehouse_amf/screens/widgets/search_loading_widget.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/helpers/toastification_helper.dart';

class ApiOrderPicker extends StatefulWidget {
  const ApiOrderPicker({
    super.key,
  });

  @override
  State<ApiOrderPicker> createState() => _ApiOrderPickerState();
}

class _ApiOrderPickerState extends State<ApiOrderPicker> {
  late ApiSearchCubit apiSearchCubit;
  late NewOrderCubit newOrderCubit;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    newOrderCubit = BlocProvider.of<NewOrderCubit>(context);
    apiSearchCubit = BlocProvider.of<ApiSearchCubit>(context);
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    apiSearchCubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            suffixIcon: const Icon(Icons.search),
            hintText: Translations.search.name.tr(),
          ),
          onSubmitted: (value) {
            apiSearchCubit.query(value);
          },
        ),
        Expanded(
          child: BlocBuilder<ApiSearchCubit, ApiSearchState>(
            builder: (context, state) {
              if (state is ApiSearchInitial) {
                return Center(
                  child: Text(
                    Translations.entertheOrderCode.name.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (state is ApiLoadingSearch) {
                return const SearchLoadingWidget();
              } else if (state is ApiLoadingSearchError) {
                return Center(
                  child: Text(state.error),
                );
              } else if (state is ApiFetchedSearch) {
                if (state.apiOrders.isEmpty) {
                  return Center(
                    child: Text(
                      Translations.foundNoOrders.name.tr(),
                    ),
                  );
                }
                return ListView.separated(
                  itemBuilder: (context, index) {
                    var apiOrder = state.apiOrders[index];
                    return Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: InfoCard(
                            title: apiOrder.documentCode,
                            desc:
                                "${Translations.company.name.tr()}: ${apiOrder.distributer.name}",
                            subDesc: apiOrder.city,
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: () async {
                            var result = await apiSearchCubit.startApiOrder(
                              apiOrder,
                              newOrderCubit,
                              (double percentage) async {
                                bool? result = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ResumeDialog(
                                      title: Text(
                                          "$percentage% ${Translations.orderIsDone.name.tr()}"),
                                    );
                                  },
                                );
                                return result ?? false;
                              },
                            );

                            if (result.$1) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                (timeStamp) {
                                  if (mounted) {
                                    Navigator.of(context)
                                        .popAndPushNamed(kRouteScan);
                                  }
                                },
                              );
                            } else {
                              if (result.$2 != null) {
                                ToastHelper.showErrorToast(
                                  Text(Translations.error.name.tr()),
                                  Text(result.$2!),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.done),
                        )
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemCount: state.apiOrders.length,
                );
              } else {
                throw UnimplementedError();
              }
            },
          ),
        )
      ],
    );
  }
}
