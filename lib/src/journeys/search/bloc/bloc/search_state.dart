part of 'search_bloc.dart';

final class SearchInitialState extends ODAInitialState {}

final class SearchStartState extends ODAInitialState {
  final String searchText;
  final List<String> searchKeywordList;
  final List<String> searchHistory;
  final List<String> suggestKeywords;
  SearchStartState(
      {required this.searchText,
      required this.searchKeywordList,
      required this.searchHistory,
      required this.suggestKeywords});

  SearchStartState copyWith({
    String? searchText,
    List<String>? searchKeywordList,
    List<String>? searchHistory,
    List<String>? suggestKeywords,
  }) {
    return SearchStartState(
      searchText: searchText ?? this.searchText,
      searchKeywordList: searchKeywordList ?? this.searchKeywordList,
      searchHistory: searchHistory ?? this.searchHistory,
      suggestKeywords: suggestKeywords ?? this.suggestKeywords,
    );
  }
}

final class SearchLoadingState extends ODALoadingState {
  final String searchText;
  SearchLoadingState({required this.searchText});
}

final class SearchSuccessState extends ODASuccessState {
  final SearchResultModel result;
  final String searchText;
  SearchSuccessState({required this.searchText, required this.result});
}

final class SearchErrorState extends ODAFailureState {}
