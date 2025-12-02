import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_data_tmf667_document_management/domain/domain.dart';

import 'models.dart';

class SearchResultModel {
  SearchResultModel({
    required this.faqList,
    required this.packageList,
    required this.privilegeList,
    required this.quickMenuList,
    required this.couponList,
    required this.categoryList,
  });

  final List<SearchCategoryModel> categoryList;
  final List<ProductOffering> couponList;
  final List<DocumentEntity> faqList;
  final List<ProductOffering> packageList;
  final List<ProductOffering> privilegeList;
  final List<SearchQuickMenuMaster> quickMenuList;
}
