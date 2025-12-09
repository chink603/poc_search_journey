import 'package:oda_data_schema/main.core.export.dart';

import 'models.dart';

class SearchCampaignModel {
  SearchCampaignModel(
      {required this.groupedBySubCategory,
      required this.subCategories,
      required this.groupedBySubCategoryCount,
      required this.groupCount,
      required this.groupedAll});

  factory SearchCampaignModel.empty() {
    return SearchCampaignModel(
        groupedBySubCategory: {},
        subCategories: [],
        groupedBySubCategoryCount: {},
        groupCount: 0,
        groupedAll: []);
  }

  final int groupCount;
  final List<LoyaltyProgramProductSpec> groupedAll;
  final Map<String, List<LoyaltyProgramProductSpec>> groupedBySubCategory;

  final Map<String, int> groupedBySubCategoryCount;
  final List<SearchCategoryModel> subCategories;
}