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
  final List<LoyaltyProgramProductSpec>? campaigns;
  final int campaignCount;
  SearchResultSuccess( {
    required this.searchResultModel,
    required this.selectedCategoryType,
    required this.packageCards,
    required this.subCategories,
    required this.searchCampaignModel,
    required this.loyaltyProductList,
    required this.campaigns,
    required this.campaignCount,
  });

  SearchResultSuccess copyWith(
      {SearchResultModel? searchResultModel,
      CategoryType? selectedCategoryType,
      List<PackageCardViewModel>? packageCards,
      List<SearchCategoryModel>? subCategories,
      SearchCampaignModel? searchCampaignModel,
      List<LoyaltyProgramProductSpec>? loyaltyProductList,
      List<LoyaltyProgramProductSpec>? campaigns,
      int? campaignCount}) {
    return SearchResultSuccess(
      searchResultModel: searchResultModel ?? this.searchResultModel,
      selectedCategoryType: selectedCategoryType ?? this.selectedCategoryType,
      packageCards: packageCards ?? this.packageCards,
      subCategories: subCategories ?? this.subCategories,
      searchCampaignModel: searchCampaignModel ?? this.searchCampaignModel,
      loyaltyProductList: loyaltyProductList ?? this.loyaltyProductList,
      campaigns: campaigns ?? this.campaigns,
      campaignCount: campaignCount ?? this.campaignCount,
    );
  }
}
