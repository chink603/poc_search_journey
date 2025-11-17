class SearchKeywordConfig {
  SearchKeywordConfig({
    required this.keyword,
    required this.navigation,
    this.arguments,
  });

  factory SearchKeywordConfig.fromJson(Map<dynamic, dynamic> json) {
    return SearchKeywordConfig(
      keyword: json['keyword'] ?? '',
      navigation: json['navigation'] ?? '',
      // arguments: json['arguments'] != null
      //     ? ArgumentsCustom.fromJson(json['arguments'])
      //     : null,
    );
  }

  final ArgumentsCustom? arguments;
  final String keyword;
  final String navigation;
}

class ArgumentsCustom {
  ArgumentsCustom({this.categoryId, this.subCategoryId});

  factory ArgumentsCustom.fromJson(Map<String, dynamic> json) {
    return ArgumentsCustom(
      categoryId: json['categoryId'],
      subCategoryId: json['subCategoryId'],
    );
  }

  final String? categoryId;
  final String? subCategoryId;
}