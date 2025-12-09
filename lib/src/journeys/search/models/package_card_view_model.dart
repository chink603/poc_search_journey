import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_data_schema/main.core.export.dart';

import 'models.dart';

class PackageCardViewModel {
  final String id;
  final ProductOffering productOffering;
  final String? excludeText;
  final String headingTitle;
  final String price;
  final String unit;
  final String? subUnit;
  final List<SearchItemInfoDetailModel> listItemInfoDetail;
  final List<SearchImageLogoModel>? listGameLogo;
  final String? badgeLabelText;
  final MyaBadgeStyle? badgeStyle;
  final String? prefixIcon;
  final String? suffixIcon;
  final String chipLabelText;
  final bool isNetGift;
  SearchPackageIconsModel? icons;

  PackageCardViewModel({
    required this.id,
    required this.productOffering,
    this.excludeText,
    required this.headingTitle,
    required this.price,
    required this.unit,
    this.subUnit,
    required this.listItemInfoDetail,
    this.listGameLogo,
    this.badgeLabelText,
    this.badgeStyle,
    this.prefixIcon,
    this.suffixIcon,
    required this.chipLabelText,
    required this.isNetGift,
    this.icons,
  });

  factory PackageCardViewModel.fromProductOfferingUnawaited(ProductOffering productOffering) {
    return PackageCardViewModel(
      id: productOffering.id,
      productOffering: productOffering,
      headingTitle: '',
      price: '',
      unit: '',
      subUnit: '',
      listItemInfoDetail: const [],
      chipLabelText: '',
      isNetGift: false,
    );
    
  }

  PackageCardViewModel copyWith({
    String? id,
    ProductOffering? productOffering,
    String? excludeText,
    String? headingTitle,
    String? price,
    String? unit,
    String? subUnit,
    List<SearchItemInfoDetailModel>? listItemInfoDetail,
    List<SearchImageLogoModel>? listGameLogo,
    String? badgeLabelText,
    MyaBadgeStyle? badgeStyle,
    String? prefixIcon,
    String? suffixIcon,
    String? chipLabelText,
    bool? isNetGift,
    String? icons,
  }) {
    return PackageCardViewModel(
      id: id ?? this.id,
      productOffering: productOffering ?? this.productOffering,
      excludeText: excludeText ?? this.excludeText,
      headingTitle: headingTitle ?? this.headingTitle,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      subUnit: subUnit ?? this.subUnit,
      listItemInfoDetail: listItemInfoDetail ?? this.listItemInfoDetail,
      listGameLogo: listGameLogo ?? this.listGameLogo,
      badgeLabelText: badgeLabelText ?? this.badgeLabelText,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      chipLabelText: chipLabelText ?? this.chipLabelText,
      isNetGift: isNetGift ?? this.isNetGift,
      icons: icons != null ? this.icons : this.icons,
    );
  }
}
