part of 'search_cubit.dart';

sealed class SearchState extends Equatable {
  const SearchState(this.searchingKey);
  final SearchingKey searchingKey;

  @override
  List<Object?> get props => [searchingKey.hashCode];
}

final class SearchInitial extends SearchState {
  const SearchInitial(super.searchingKey);
}

final class LoadingSearch extends SearchState {
  final CancelToken cancelToken;

  const LoadingSearch(super.searchingKey, {required this.cancelToken});
  @override
  List<Object?> get props => [cancelToken.hashCode];
}

final class LoadingSearchError extends SearchState {
  final String error;

  const LoadingSearchError(super.searchingKey, {required this.error});

  @override
  List<Object?> get props => [error];
}

final class FetchedSearch extends SearchState {
  final List values;

  const FetchedSearch(super.searchingKey, {required this.values});
  @override
  List<Object?> get props => [values];
}
