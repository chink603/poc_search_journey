

import 'package:oda_data_tmf658_loyalty_management/domain/domain.dart';

import '../utils/category_type.dart';

class SearchCategoryModel  {
  const SearchCategoryModel({
    required this.id,
    required this.label,
    this.icon,
    required this.value,
    this.priority,
    this.type = CategoryType.none,
  });
  final String id;
  final String label;
  final String? icon;
  final String? priority;
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

  factory SearchCategoryModel.fromEntityPrivilegeFilter(LoyaltyChipSortModel entity) {
    return SearchCategoryModel(
      id: entity.id.toString(),
      label: entity.keyCoreLang,
      icon: null,
      value: false,
      type: CategoryType.privilege,
    );
  }
    factory SearchCategoryModel.fromEntityPrivilegeSubCategory(LoyaltyCategoryConfigEntities entity) {
    return SearchCategoryModel(
      id: entity.id,
      label: entity.keyCoreLang,
      icon: entity.icon,
      priority: entity.priority,
      value: false,
      type: CategoryType.privilege,
    );
  }
}