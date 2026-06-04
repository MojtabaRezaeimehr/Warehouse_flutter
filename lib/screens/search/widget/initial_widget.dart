import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/screens/widgets/custom/infinity_symbol_anim.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/enums/searching_keys.dart';
import '../../../bloc/cubit/search_cubit.dart';

class SearchInitialWidget extends StatelessWidget {
  const SearchInitialWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var searchCubit = BlocProvider.of<SearchCubit>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          const InfinitySymbolAnim(
            child: Icon(Icons.search, size: 70),
          ),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              return Column(
                //these text are warpped with column to group them and avoid -
                //rebuilding infinity symbol widget when state changes
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translations.searchIn.name.tr(args: [
                      state.searchingKey == SearchingKey.companies
                          ? Translations.company.name.tr()
                          : Translations.product.name.tr(),
                    ]),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  InkWell(
                    onTap: () => searchCubit.searchIn(
                      state.searchingKey == SearchingKey.companies
                          ? SearchingKey.products
                          : SearchingKey.companies,
                    ),
                    child: Text(
                      Translations.lookingFor.name.tr(args: [
                        state.searchingKey == SearchingKey.companies
                            ? Translations.products.name.tr()
                            : Translations.companies.name.tr(),
                      ]),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
