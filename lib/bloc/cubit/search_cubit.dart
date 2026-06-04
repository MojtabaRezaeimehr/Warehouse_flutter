import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/services/remote/companies/companies_repo.dart';
import 'package:warehouse_amf/services/remote/products/products_repo.dart';
import 'package:warehouse_amf/services/remote/remote_services.dart';
import 'package:warehouse_amf/utils/enums/searching_keys.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final CompaniesRepo _companiesRepo;
  final ProductsRepo _productsRepo;

  SearchCubit({
    CompaniesRepo? companiesRepo,
    ProductsRepo? productsRepo,
  })  : _companiesRepo = companiesRepo ?? RemoteServices.companiesRepo,
        _productsRepo = productsRepo ?? RemoteServices.productsRepo,
        super(
          const SearchInitial(SearchingKey.companies),
        );

  void query(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial(state.searchingKey));
      return;
    }
    //user may look up companies with twp diff queries one after another
    //in this case the old req must be canceled
    if (state is LoadingSearch) {
      (state as LoadingSearch).cancelToken.cancel();
    }

    //emit loading for the newest query
    var cancelToken = CancelToken();
    emit(
      LoadingSearch(state.searchingKey, cancelToken: cancelToken),
    );

    ApiResponse<List> response = state.searchingKey == SearchingKey.companies
        ? await _companiesRepo.fetchCompanies(query, cancelToken)
        : await _productsRepo.fetchProducts(query, cancelToken);
    if (response is ApiResponseSucceeded) {
      emit(
        FetchedSearch(values: response.values ?? [], state.searchingKey),
      );
    } else {
      if ((response as ApiResponseFailed)
          .message
          .contains("request was manually cancelled")) {
        //this is infact no failure and was done on purpose
        return;
      }
      emit(
        LoadingSearchError(state.searchingKey,
            error: (response as ApiResponseFailed).message),
      );
    }
  }

  void searchIn(SearchingKey key) {
    switch (key) {
      case SearchingKey.companies:
        emit(const SearchInitial(SearchingKey.companies));
        break;
      case SearchingKey.products:
        emit(const SearchInitial(SearchingKey.products));
        break;
    }
  }
}
