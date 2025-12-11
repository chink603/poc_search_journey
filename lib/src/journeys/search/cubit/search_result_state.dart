part of 'search_result_cubit.dart';

final class SearchResultState extends ODACubitSingleState {}

final class SearchResultInitial extends SearchResultState {}

final class SearchResultLoading extends SearchResultState {}

final class SearchResultSuccess extends SearchResultState {
  final SearchResultModel searchResultModel;
  final CategoryType selectedCategoryType;
  final List<SearchCategoryModel> subCategories;
  final List<PackageCardViewModel> packageCards;
  final List<LoyaltyProgramProductSpec>? loyaltyProductList;
  final SearchCampaignModel searchCampaignModel;
  final int campaignCount;
  final List<int> campaignsSortedBy;
  SearchResultSuccess({
    required this.campaignsSortedBy,
    required this.searchResultModel,
    required this.selectedCategoryType,
    required this.packageCards,
    required this.subCategories,
    required this.searchCampaignModel,
    required this.loyaltyProductList,
    required this.campaignCount,
  });

  SearchResultSuccess copyWith(
      {SearchResultModel? searchResultModel,
      CategoryType? selectedCategoryType,
      List<PackageCardViewModel>? packageCards,
      List<SearchCategoryModel>? subCategories,
      SearchCampaignModel? searchCampaignModel,
      List<LoyaltyProgramProductSpec>? loyaltyProductList,
      int? campaignCount,
      List<int>? campaignsSortedBy}) {
    return SearchResultSuccess(
      campaignsSortedBy: campaignsSortedBy ?? this.campaignsSortedBy,
      searchResultModel: searchResultModel ?? this.searchResultModel,
      selectedCategoryType: selectedCategoryType ?? this.selectedCategoryType,
      packageCards: packageCards ?? this.packageCards,
      subCategories: subCategories ?? this.subCategories,
      searchCampaignModel: searchCampaignModel ?? this.searchCampaignModel,
      loyaltyProductList: loyaltyProductList ?? this.loyaltyProductList,
      campaignCount: campaignCount ?? this.campaignCount,
    );
  }
}
