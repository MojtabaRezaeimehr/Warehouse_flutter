import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/search_cubit.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/models/remote/product.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_else_widget.dart';
import 'package:warehouse_amf/screens/widgets/custom/number_picker.dart';
import 'package:warehouse_amf/screens/widgets/search_loading_widget.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';
import 'package:warehouse_amf/utils/enums/searching_keys.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';

class ProductPicker extends StatefulWidget {
  const ProductPicker({
    super.key,
    required this.selectedCompany,
  });

  final Company selectedCompany;

  @override
  State<ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<ProductPicker> {
  //key is GTIN of product , value is productName and maxScanQuantity
  Map<String, (String, int)> limitedProducts = {};

  late SearchCubit searchCubit;
  late NewOrderCubit newOrderCubit;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    newOrderCubit = BlocProvider.of<NewOrderCubit>(context);
    searchCubit = BlocProvider.of<SearchCubit>(context);
    searchCubit.searchIn(SearchingKey.products);

    super.initState();
  }

  @override
  void dispose() {
    //reset
    searchCubit.searchIn(SearchingKey.companies);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            suffixIcon: const Icon(Icons.search),
            hintText: Translations.search.name.tr(),
          ),
          onSubmitted: (value) {
            searchCubit.query(value);
          },
        ),
        Expanded(
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                return Stack(
                  children: [
                    Center(
                      child: Text(
                        Translations.searchIn.name.tr(args: [
                          Translations.product.name.tr(),
                        ]),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    startButton(context)
                  ],
                );
              } else if (state is LoadingSearch) {
                return const SearchLoadingWidget();
              } else if (state is LoadingSearchError) {
                return Center(
                  child: Text(state.error),
                );
              } else if (state is FetchedSearch) {
                return Stack(
                  children: [
                    IfElseWidget(
                      condition: state.values.isEmpty,
                      ifWidget: Center(
                        child: Text(
                          Translations.foundNoCompany.name.tr(),
                        ),
                      ),
                      elseWidget: ListView.separated(
                        itemBuilder: (context, index) {
                          Product product = (state.values[index] as Product);
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    Text(
                                      "${Translations.id.name.tr()} : ${product.gtin}",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                  ],
                                ),
                              ),
                              NumberPicker(
                                onIncrement: (int val) =>
                                    limitedProducts[product.gtin] =
                                        (product.name, val),
                                onDecrement: (int val) {
                                  if (val == 0) {
                                    limitedProducts.removeWhere(
                                      (key, value) => key == product.gtin,
                                    );
                                  } else {
                                    limitedProducts[product.gtin] =
                                        (product.name, val);
                                  }
                                },
                                initialValue: 0,
                              )
                            ],
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const Divider(height: 20),
                        itemCount: state.values.length,
                      ),
                    ),
                    startButton(context),
                  ],
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

  Widget startButton(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.9),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          minimumSize: const Size(150, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          iconColor: Theme.of(context).colorScheme.onTertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
        ),
        onPressed: () async {
          //start a new outgoing order
          List<ScannedProduct> limitedProduct = [];
          limitedProducts.forEach(
            (key, value) {
              limitedProduct.add(
                ScannedProduct(
                  product: Product(
                    id: "-1",
                    name: value.$1,
                    gtin: key,
                  ),
                  scanQuantity: 0,
                  maxScanQuantity: value.$2,
                ),
              );
            },
          );

          Navigator.popAndPushNamed(context, kRouteScan);

          newOrderCubit.startOutgoingOrder(
            widget.selectedCompany,
            limitedProduct.isEmpty ? null : limitedProduct,
          );
        },
        icon: const Icon(Icons.done),
        label: Text(
          Translations.confirm.name.tr(),
        ),
      ),
    );
  }
}
