part of 'search_result_cubit.dart';

final class SearchResultState extends ODACubitSingleState {}

final class SearchResultInitial extends SearchResultState {}

final class SearchResultLoading extends SearchResultState {}

final class SearchResultSuccess extends SearchResultState {
  final SearchResultModel searchResultModel;
  final CategoryType selectedCategoryType;
  final SearchCategoryModel? selectedSubCategory;
  final List<SearchCategoryModel> subCategories;
  final List<PackageCardViewModel> packageCards;
  final Map<String, LoyaltyProgramProductSpec>? loyaltyProductList;
  final SearchCampaignModel searchCampaignModel;
  final int campaignCount;
  final List<String> campaignsSortedBy;
  final List<SearchCategoryModel> filterCategory;
  SearchResultSuccess({
    required this.campaignsSortedBy,
    required this.searchResultModel,
    required this.selectedCategoryType,
    this.selectedSubCategory,
    required this.packageCards,
    required this.subCategories,
    required this.searchCampaignModel,
    required this.loyaltyProductList,
    required this.campaignCount,
    required this.filterCategory,
  });

  SearchResultSuccess copyWith(
      {SearchResultModel? searchResultModel,
      CategoryType? selectedCategoryType,
      List<PackageCardViewModel>? packageCards,
      List<SearchCategoryModel>? subCategories,
      SearchCampaignModel? searchCampaignModel,
      Map<String, LoyaltyProgramProductSpec>? loyaltyProductList,
      int? campaignCount,
      List<String>? campaignsSortedBy,
      List<SearchCategoryModel>? filterCategory,
      SearchCategoryModel? selectedSubCategory}) {
    return SearchResultSuccess(
      campaignsSortedBy: campaignsSortedBy ?? this.campaignsSortedBy,
      searchResultModel: searchResultModel ?? this.searchResultModel,
      selectedCategoryType: selectedCategoryType ?? this.selectedCategoryType,
      packageCards: packageCards ?? this.packageCards,
      subCategories: subCategories ?? this.subCategories,
      searchCampaignModel: searchCampaignModel ?? this.searchCampaignModel,
      loyaltyProductList: loyaltyProductList ?? this.loyaltyProductList,
      campaignCount: campaignCount ?? this.campaignCount,
      filterCategory: filterCategory ?? this.filterCategory,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
    );
  }
}
