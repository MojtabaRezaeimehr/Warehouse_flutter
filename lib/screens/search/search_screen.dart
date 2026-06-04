import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/models/remote/product.dart';
import 'package:warehouse_amf/screens/widgets/search_loading_widget.dart';
import 'package:warehouse_amf/screens/widgets/info_card.dart';
import 'package:warehouse_amf/screens/search/widget/initial_widget.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/enums/searching_keys.dart';

import 'package:warehouse_amf/bloc/cubit/search_cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController controller = TextEditingController();

  late Timer timer;
  late SearchCubit searchCubit;
  //to prevent timer requesting for the same query muliple time
  String? oldQuery;

  @override
  void initState() {
    searchCubit = BlocProvider.of<SearchCubit>(context);

    timer = Timer.periodic(
        const Duration(seconds: 3), (timer) => validateAndQuery());
    super.initState();
  }

  void validateAndQuery() {
    var query = controller.text.trim();
    if (query != oldQuery) {
      searchCubit.query(query);
      oldQuery = query;
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                suffixIcon: const Icon(Icons.search),
                hintText: Translations.search.name.tr(),
              ),
              onSubmitted: (value) => validateAndQuery()),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 70),
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                return const SearchInitialWidget();
              } else if (state is LoadingSearchError) {
                return Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, size: 50),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                    )
                  ],
                );
              } else if (state is LoadingSearch) {
                return const SearchLoadingWidget();
              } else if (state is FetchedSearch) {
                if (state.values.isEmpty) {
                  return Center(
                    child: Text(
                      state.searchingKey == SearchingKey.companies
                          ? Translations.foundNoCompany.name.tr()
                          : Translations.foundNoProduct.name.tr(),
                    ),
                  );
                }

                return ListView.separated(
                  itemBuilder: (context, index) {
                    String title;
                    String desc;
                    if (state.searchingKey == SearchingKey.companies) {
                      title = (state.values[index] as Company).name;
                      desc =
                          "${Translations.nid.name.tr()}: ${(state.values[index] as Company).nid}";
                    } else {
                      title = (state.values[index] as Product).name;
                      desc =
                          "${Translations.id.name.tr()}: ${(state.values[index] as Product).gtin}";
                    }
                    return InfoCard(
                      title: title,
                      desc: desc,
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
