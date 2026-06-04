part of 'api_search_cubit.dart';

sealed class ApiSearchState extends Equatable {
  const ApiSearchState();

  @override
  List<Object?> get props => [];
}

final class ApiSearchInitial extends ApiSearchState {
  const ApiSearchInitial();
}

final class ApiLoadingSearch extends ApiSearchState {
  final CancelToken cancelToken;

  const ApiLoadingSearch({required this.cancelToken});
  @override
  List<Object?> get props => [cancelToken.hashCode];
}

final class ApiLoadingSearchError extends ApiSearchState {
  final String error;

  const ApiLoadingSearchError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class ApiFetchedSearch extends ApiSearchState {
  final List<ApiOrder> apiOrders;

  const ApiFetchedSearch({required this.apiOrders});
  @override
  List<Object?> get props => [apiOrders];
}
