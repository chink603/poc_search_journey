part of 'search_result_cubit.dart';

final class SearchResultState extends ODACubitSingleState {}

final class SearchResultInitial extends SearchResultState {}

final class SearchResultSuccess extends SearchResultState {
  final SearchResultModel searchResultModel;
  final CategoryType selectedCategoryType;
  final List<PackageCardViewModel> packageCards;

  SearchResultSuccess({
    required this.searchResultModel,
    required this.selectedCategoryType,
    required this.packageCards,
  });

  SearchResultSuccess copyWith(
      {SearchResultModel? searchResultModel,
      CategoryType? selectedCategoryType,
      List<PackageCardViewModel>? packageCards}) {
    return SearchResultSuccess(
      searchResultModel: searchResultModel ?? this.searchResultModel,
      selectedCategoryType: selectedCategoryType ?? this.selectedCategoryType,
      packageCards: packageCards ?? this.packageCards,
    );
  }
}
