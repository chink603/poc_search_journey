
import 'models.dart';
class SearchPackageIconsModel {
  final List<SearchItemInfoDetailModel> listInfoDetail;
  final List<SearchImageLogoModel>? listGameLogo;

  SearchPackageIconsModel({
    required this.listInfoDetail,
    this.listGameLogo,
  });
}