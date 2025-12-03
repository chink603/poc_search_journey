// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:next_core/next_core.dart';
import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_data_tmf667_document_management/domain/domain.dart';

import '../utils/util.dart';
import 'models.dart';

class SearchResultModel {
  SearchResultModel({
    this.filterList,
    this.categoryList,
    this.subCategoryList,
    this.couponList,
    this.faqList,
    this.packageList,
    this.privilegeList,
    this.quickMenuList,
  });

  final List<SearchCategoryModel>? categoryList;
  final List<ProductOffering>? couponList;
  final List<DocumentEntity>? faqList;
  final Map<CategoryType, List<SearchCategoryModel>>? filterList;
  final List<ProductOffering>? packageList;
  final CoreDataResult<LoyaltyProgramProductSpec>? privilegeList;
  final List<SearchQuickMenuMaster>? quickMenuList;
  final Map<CategoryType, List<SearchCategoryModel>>? subCategoryList;

  SearchResultModel copyWith({
    List<SearchCategoryModel>? categoryList,
    List<ProductOffering>? couponList,
    List<DocumentEntity>? faqList,
    Map<CategoryType, List<SearchCategoryModel>>? filterList,
    List<ProductOffering>? packageList,
    CoreDataResult<LoyaltyProgramProductSpec>? privilegeList,
    List<SearchQuickMenuMaster>? quickMenuList,
    Map<CategoryType, List<SearchCategoryModel>>? subCategoryList,
  }) {
    return SearchResultModel(
      categoryList: categoryList ?? this.categoryList,
      couponList: couponList ?? this.couponList,
      faqList: faqList ?? this.faqList,
      filterList: filterList ?? this.filterList,
      packageList: packageList ?? this.packageList,
      privilegeList: privilegeList ?? this.privilegeList,
      quickMenuList: quickMenuList ?? this.quickMenuList,
      subCategoryList: subCategoryList ?? this.subCategoryList,
    );
  }
  bool isEmpty(){
    return packageList == null && privilegeList == null && faqList == null && couponList == null && quickMenuList == null ;
  }
}
