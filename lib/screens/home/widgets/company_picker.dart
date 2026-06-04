import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/search_cubit.dart';
import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/screens/home/widgets/product_picker.dart';
import 'package:warehouse_amf/screens/widgets/info_card.dart';
import 'package:warehouse_amf/screens/widgets/search_loading_widget.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/enums/searching_keys.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';

class CompanyPicker extends StatefulWidget {
  const CompanyPicker({
    super.key,
    required this.orderType,
  });

  final OrderTypes orderType;

  @override
  State<CompanyPicker> createState() => _CompanyPickerState();
}

class _CompanyPickerState extends State<CompanyPicker> {
  late SearchCubit searchCubit;
  late NewOrderCubit newOrderCubit;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    newOrderCubit = BlocProvider.of<NewOrderCubit>(context);
    searchCubit = BlocProvider.of<SearchCubit>(context);
    searchCubit.searchIn(SearchingKey.companies);
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    if (widget.orderType == OrderTypes.returning) {
      //reset search cubit state to leave search page
      //with initial state
      //note that for outgoing order product picker comes up
      //after this dispose and it needs to search in product
      searchCubit.searchIn(SearchingKey.companies);
    }
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
                return Center(
                  child: Text(
                    Translations.searchIn.name.tr(
                      args: [Translations.company.name.tr()],
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (state is LoadingSearch) {
                return const SearchLoadingWidget();
              } else if (state is LoadingSearchError) {
                return Center(
                  child: Text(state.error),
                );
              } else if (state is FetchedSearch) {
                if (state.values.isEmpty) {
                  return Center(
                    child: Text(
                      Translations.foundNoCompany.name.tr(),
                    ),
                  );
                }
                return ListView.separated(
                  itemBuilder: (context, index) {
                    Company company = (state.values[index] as Company);
                    return Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: InfoCard(
                            title: company.name,
                            desc:
                                "${Translations.nid.name.tr()}: ${(state.values[index] as Company).nid}",
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: () async {
                            if (widget.orderType == OrderTypes.outgoing) {
                              Navigator.of(context).pop();
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.75,
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 16),
                                    child: ProductPicker(
                                      selectedCompany: company,
                                    ),
                                  );
                                },
                              );
                            } else {
                              dprint("starting a new returning");
                              Navigator.popAndPushNamed(context, kRouteScan);

                              //start a new returning
                              newOrderCubit.startReturningOrder(
                                company,
                              );
                            }
                          },
                          icon: const Icon(Icons.done),
                        )
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemCount: state.values.length,
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
