import 'package:mya_ui_design/mya_ui_design.dart';

class SearchProductBadgeModel {
  final String badgeLabelText;
  final MyaBadgeStyle? badgeStyle;
  final String? prefixIconBadge;
  final String? suffixIconBadge;
  final bool badgeValid;

  SearchProductBadgeModel({
    required this.badgeLabelText,
    this.badgeStyle,
    this.prefixIconBadge,
    this.suffixIconBadge,
    required this.badgeValid,
  });
}

class SearchProductGameLogo {
  final List<String?> images;
  final String? package;
  final double width;
  final double height;

  SearchProductGameLogo({
    required this.images,
    this.package = 'ui_design',
    this.width = 48,
    this.height = 32,
  });
}