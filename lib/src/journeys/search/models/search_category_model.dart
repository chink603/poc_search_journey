

import '../utils/category_type.dart';

class SearchCategoryModel  {
  const SearchCategoryModel({
    required this.id,
    required this.label,
    this.icon,
    required this.value,
    this.type = CategoryType.none,
  });
  final String id;
  final String label;
  final String? icon;
  final bool value;
  final CategoryType type;

  SearchCategoryModel copyWith({
    String? id,
    String? label,
    String? icon,
    bool? value,
    CategoryType? type,
  }) {
    return SearchCategoryModel(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }
}