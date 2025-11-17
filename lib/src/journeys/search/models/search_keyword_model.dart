import 'package:oda_data_schema/system/search_keyword_config_list_schema.dart';

class SearchKeywordModel {
  const SearchKeywordModel({
    required this.distinctWords,
    required this.searchRoutes,
    required this.quickMenus,
    required this.searchSubRoutes,
    required this.keywordCoupons,
  });

  final List<String> distinctWords;
  final List<SearchKeywordConfigListSchema> searchRoutes;
  final List<SearchKeywordConfigListSchema> quickMenus;
  final List<SearchKeywordConfigListSchema> searchSubRoutes;
  final List<SearchKeywordConfigListSchema> keywordCoupons;
  SearchKeywordModel.empty()
      : this(
          distinctWords: [],
          searchRoutes: [],
          quickMenus: [],
          searchSubRoutes: [],
          keywordCoupons: [],
        );
}