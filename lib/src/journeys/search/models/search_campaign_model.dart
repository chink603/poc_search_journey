import 'models.dart';

class SearchCampaignModel {
  SearchCampaignModel({
    required this.groupedBySubCategoryIds,
    required this.subCategories,
    required this.groupedBySubCategoryCount,
    required this.groupedAllCount,
    required this.groupedAll,
  });

  factory SearchCampaignModel.empty() {
    return SearchCampaignModel(
      groupedBySubCategoryIds: {},
      subCategories: [],
      groupedBySubCategoryCount: {},
      groupedAllCount: 0,
      groupedAll: const [],
    );
  }

  final int groupedAllCount;
  final List<String> groupedAll;
  final Map<String, List<String>> groupedBySubCategoryIds;

  final Map<String, int> groupedBySubCategoryCount;
  final List<SearchCategoryModel> subCategories;
}
