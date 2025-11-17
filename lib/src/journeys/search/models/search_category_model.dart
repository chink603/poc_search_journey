
import 'package:equatable/equatable.dart';

class SearchCategoryModel extends Equatable {
  const SearchCategoryModel({
    required this.id,
    required this.label,
    this.icon,
    required this.value,
  });
  final String id;
  final String label;
  final String? icon;
  final bool value;

  SearchCategoryModel copyWith({
    String? id,
    String? label,
    String? icon,
    bool? value,
  }) {
    return SearchCategoryModel(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      value: value ?? this.value,
    );
  }
 static SearchCategoryModel empty() {
    return const SearchCategoryModel(
      id: '',
      label: '',
      icon: '',
      value: false,
    );
  }
  @override
  List<Object?> get props => [id, label, icon, value];
}