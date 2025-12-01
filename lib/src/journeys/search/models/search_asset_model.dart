import 'package:oda_data_schema/main.core.export.dart';

class SearchAssetModel {
  SearchAssetModel({
    required this.isLogin,
    required this.mobileNumber,
    required this.rawNtype,
    required this.currentAsset,
    required this.isGetPackage,
    required this.mobileNumberInternal,
  });

  final EntityRef? currentAsset;
  final bool isGetPackage;
  final bool isLogin;
  final String mobileNumber;
  final String mobileNumberInternal;
  final String rawNtype;
}