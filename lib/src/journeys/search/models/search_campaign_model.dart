import 'models.dart';

class SearchCampaignModel {
  SearchCampaignModel({
    required this.groupedBySubCategoryIds,
    required this.subCategories,
    required this.groupedBySubCategoryCount,
    required this.groupCount,
    required this.groupedAll,
  });

  factory SearchCampaignModel.empty() {
    return SearchCampaignModel(
      groupedBySubCategoryIds: {},
      subCategories: [],
      groupedBySubCategoryCount: {},
      groupCount: 0,
      groupedAll: const {},
    );
  }

  final int groupCount;
  final Map<String, int> groupedAll;
  final Map<String, List<String>> groupedBySubCategoryIds;

  final Map<String, int> groupedBySubCategoryCount;
  final List<SearchCategoryModel> subCategories;
}
