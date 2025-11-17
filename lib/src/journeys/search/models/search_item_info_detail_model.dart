class SearchItemInfoDetailModel {
  const SearchItemInfoDetailModel({
    required this.titleText,
    this.subtitleText,
    this.iconKey,
    this.isColor,
  });
  final String titleText;
  final String? subtitleText;
  final String? iconKey;
  final bool? isColor;

  SearchItemInfoDetailModel copyWith({
    String? titleText,
    String? subtitleText,
    String? iconKey,
    bool? isColor,
  }) {
    return SearchItemInfoDetailModel(
      titleText: titleText ?? this.titleText,
      subtitleText: subtitleText ?? this.subtitleText,
      iconKey: iconKey ?? this.iconKey,
      isColor: isColor ?? this.isColor,
    );
  }
}

class SearchImageLogoModel {
  const SearchImageLogoModel({
    this.iconKey,
  });
  final String? iconKey;
}