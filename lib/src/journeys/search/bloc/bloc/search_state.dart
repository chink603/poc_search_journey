part of 'search_bloc.dart';

final class SearchInitialState extends ODAInitialState{}

final class SearchStartState extends ODAInitialState{
  final List<String> searchKeywordList;
  final List<String> searchHistory;
  final List<String> suggestKeywords;
  SearchStartState({required this.searchKeywordList, required this.searchHistory, required this.suggestKeywords});
}

final class SearchLoadingState extends ODALoadingState{}

final class SearchSuccessState extends ODASuccessState{
  final List<SearchCategoryModel> categories;
  final List<SearchCategoryModel> subCategories;
  SearchSuccessState({required this.categories, required this.subCategories});
}

final class SearchErrorState extends ODAFailureState{}

