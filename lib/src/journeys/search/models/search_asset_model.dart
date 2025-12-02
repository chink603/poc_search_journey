import 'package:core/utils/ntype_management/ntype_management.dart';
import 'package:oda_data_schema/main.core.export.dart';

class SearchAssetModel {
  SearchAssetModel( {
     this.isLogin = false,
     this.mobileNumber = '',
     this.rawNtype = '',
     this.currentAsset,
     this.isGetPackage = false,
     this.mobileNumberInternal = '',
     this.groupNType,
  });

  final EntityRef? currentAsset;
  final NType? groupNType;
  final bool isGetPackage;
  final bool isLogin;
  final String mobileNumber;
  final String mobileNumberInternal;
  final String? rawNtype;
}