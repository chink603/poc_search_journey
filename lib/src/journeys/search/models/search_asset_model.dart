import 'package:oda_data_schema/main.core.export.dart';

class SearchAssetModel {
  SearchAssetModel({
     this.isLogin = false,
     this.mobileNumber = '',
     this.rawNtype = '',
     this.currentAsset,
     this.isGetPackage = false,
     this.mobileNumberInternal = '',
  });

  final EntityRef? currentAsset;
  final bool isGetPackage;
  final bool isLogin;
  final String mobileNumber;
  final String mobileNumberInternal;
  final String rawNtype;
}