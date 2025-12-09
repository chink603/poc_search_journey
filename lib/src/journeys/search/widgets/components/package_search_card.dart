import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_data_schema/main.core.export.dart';

import '../../models/models.dart';

class PackageCardWidget extends StatelessWidget {
  const PackageCardWidget({
    super.key,
    required this.viewModel,
    this.searchPackageIconsModel,
    required this.onSelectBuyNow,
    required this.onSelectPackageById,
    required this.buttonBuyNow,
    required this.buttonViewDetails,
  });
  final PackageCardViewModel viewModel;
  final SearchPackageIconsModel? searchPackageIconsModel;
  final String? buttonBuyNow;
  final String buttonViewDetails;

  final void Function(String productOfferingId) onSelectBuyNow;
  final void Function(ProductOffering? productOffering) onSelectPackageById;

  @override
  Widget build(BuildContext context) {
    return SearchPackageCardWidget(
      excludeText: viewModel.excludeText,
      headingTitle: viewModel.headingTitle,
      price: viewModel.price,
      unit: viewModel.unit,
      subUnit: viewModel.subUnit,
      listItemInfoDetail: searchPackageIconsModel?.listInfoDetail ??
          viewModel.listItemInfoDetail,
      listGameLogo:
          searchPackageIconsModel?.listGameLogo ?? viewModel.listGameLogo,
      badgeLabelText: viewModel.badgeLabelText,
      badgeStyle: viewModel.badgeStyle,
      prefixIcon: viewModel.prefixIcon,
      suffixIcon: viewModel.suffixIcon,
      textButtonSuccess: viewModel.isNetGift ? null : buttonBuyNow,
      onPressedSuccess: buttonBuyNow != null
          ? () {
              onSelectBuyNow(viewModel.id);
            }
          : null,
      textButtonCancel: buttonViewDetails,
      onPressedCancel: () {
        onSelectPackageById(viewModel.productOffering);
      },
      chipLabelText: viewModel.chipLabelText,
    );
  }
}

class SearchPackageCardWidget extends StatefulWidget {
  const SearchPackageCardWidget({
    super.key,
    this.chipLabelText,
    required this.headingTitle,
    this.supportingText,
    this.prefixIconKey,
    this.width,
    this.price,
    this.unit,
    this.subUnit,
    this.excludeText,
    this.paddingListChild,
    this.widthGameLogo,
    this.heightGameLogo,
    this.badgeStyle,
    this.badgeLabelText,
    this.prefixIcon,
    this.suffixIcon,
    this.textButtonSuccess,
    this.textButtonCancel,
    this.onPressedSuccess,
    this.onPressedCancel,
    this.listItemInfoDetail,
    this.listGameLogo,
    this.listFlag,
    this.flagCount = 9,
    this.valueCheckBox = false,
    this.onChangedCheckBox,
    this.showCheckBox = false,
    this.insuranceOffering,
    this.insuranceLogo,
    this.isSpace = false,
    this.isSpeed = false, // for PBB
    this.titleText,
    this.titleDownload,
    this.titleUpload,
  });
  static const String compType = 'cardPackage';
  final String? chipLabelText; // label text (ex. Main Package)
  final String headingTitle; // title text (ex. package name)
  final String? supportingText; // supporting text (ex. package name)
  final String? prefixIconKey; // icon key chip (ex. recurring icon)
  final double? width; // width card
  final String? price; // label 1 (ex. 999)
  final String? unit; // label 1 (ex. ฿)
  final String? subUnit; // label 2 (ex. 30 day, month)
  final String? excludeText; // additional text (ex. VAT included 1,033฿)

  final EdgeInsets? paddingListChild;
  final double? widthGameLogo; // width game logo
  final double? heightGameLogo; // height game logo
  final MyaBadgeStyle? badgeStyle; // badge style ex. exclusive, hot offers
  final String? badgeLabelText; // Label text badge (ex. Exclusive, Hot Offers)
  final String? prefixIcon; // icon prefix badge
  final String? suffixIcon; // icon suffix badge
  final String? textButtonSuccess; // text button primay
  final String? textButtonCancel; // text button secondary
  final void Function()? onPressedSuccess; // action button primary
  final void Function()? onPressedCancel; // action button secondary
  final List<SearchItemInfoDetailModel>?
      listItemInfoDetail; // list item info detail new
  final List<SearchImageLogoModel>? listGameLogo; // game logo new
  final List<SearchImageLogoModel>? listFlag; // game logo new
  final int flagCount; // count flag
  final bool? valueCheckBox;
  final void Function(bool)? onChangedCheckBox;
  final bool? showCheckBox;
  final ProductOffering? insuranceOffering;
  final String? insuranceLogo;
  final bool? isSpace;
  final bool? isSpeed;
  final Widget? titleText;
  final String? titleDownload;
  final String? titleUpload;

  @override
  State<SearchPackageCardWidget> createState() =>
      _SearchPackageCardWidgetState();
}

class _SearchPackageCardWidgetState extends State<SearchPackageCardWidget> {
  @override
  Widget build(BuildContext context) {
    final MyaTextStyle myaTextStyle = context.myaTextStyle;
    final MyaThemeColors myaColors = context.myaThemeColors;

    final Widget? priceAndUnit =
        (widget.price?.isEmpty ?? true) && (widget.subUnit?.isEmpty ?? true)
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.price?.isNotEmpty ?? false)
                    Text(
                      key: ValueKey<String>(
                        '${widget.key.stringValue}/labelText/0',
                      ),
                      '${widget.price} ${widget.unit} ',
                      style: myaTextStyle.bodyLargeExtraBold
                          .copyWith(color: myaColors.textIconMidText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if ((widget.price?.isNotEmpty ?? false) &&
                      (widget.subUnit?.isNotEmpty ?? false))
                    MyaDivider(
                      key: ValueKey<String>(
                        '${widget.key.stringValue}/${MyaDivider.compType}/0',
                      ),
                      type: MyaDividerType.vertical,
                      verticalHeight: 20,
                    ),
                  if (widget.subUnit != null)
                    Text(
                      key: ValueKey<String>(
                        '${widget.key.stringValue}/labelText/1',
                      ),
                      ' ${widget.subUnit}',
                      style: myaTextStyle.bodyLargeExtraBold
                          .copyWith(color: myaColors.textIconMidText),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              );

    return SizedBox(
      width: widget.width ?? MediaQuery.sizeOf(context).width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: MyaElevation.getElevation(
            context,
            MyaElevationLevel.elevation3,
          ),
          borderRadius: BorderRadius.circular(kRadius7),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          color: myaColors.bgContainer,
          shadowColor: myaColors.elevationWeight2,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius6),
          ),
          child: Stack(
            children: <Widget>[
              if (widget.badgeStyle != null && widget.badgeLabelText != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MyaBadge(
                      key: ValueKey<String>(
                        '${widget.key.stringValue}/${MyaBadge.compType}',
                      ),
                      badgeStyle: widget.badgeStyle!,
                      labelText: widget.badgeLabelText,
                      badgePosition: MyaBadgePosition.right,
                      prefixIcon: widget.prefixIcon,
                      suffixIcon: widget.suffixIcon,
                      paddingHorizontal: kPadding4,
                    ),
                  ],
                ),
              Padding(
                padding: EdgeInsets.only(
                  top: (widget.badgeStyle != null &&
                          widget.badgeLabelText != null)
                      ? kPadding8
                      : kPadding7,
                  bottom: kPadding7,
                  left: kPadding7,
                  right: kPadding7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.chipLabelText?.isNotEmpty ?? false)
                      MyaChipGeneral(
                        key: ValueKey<String>(
                          '${widget.key.stringValue}/${MyaChipGeneral.compType}',
                        ),
                        labelText: widget.chipLabelText ?? '',
                        prefixIconKey: widget.prefixIconKey,
                        size: MyaChipGeneralSize.small,
                      ),
                    const SizedBox(height: kGap4),
                    if (widget.supportingText?.isNotEmpty ?? false)
                      Text(
                        key: ValueKey<String>(
                          '${widget.key.stringValue}/supportingText',
                        ),
                        widget.supportingText ?? '',
                        style: myaTextStyle.labelLarge.copyWith(
                          color: myaColors.textIconMidText,
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (widget.showCheckBox ?? true)
                          MyaCheckbox(
                            value: widget.valueCheckBox ?? false,
                            onChanged: (bool v) {
                              setState(() {
                                // widget.valueCheckBox = v;
                                if (widget.onChangedCheckBox != null) {
                                  widget.onChangedCheckBox!(v);
                                }
                              });
                            },
                          ),
                        Expanded(
                          child: Text(
                            key: ValueKey<String>(
                              '${widget.key.stringValue}/headingText',
                            ),
                            widget.headingTitle,
                            style: myaTextStyle.bodyMedium.copyWith(
                              color: myaColors.textIconMidText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (priceAndUnit != null) const SizedBox(width: kGap3),
                        if (priceAndUnit != null)
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 132,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                priceAndUnit,
                                Text(
                                  key: ValueKey<String>(
                                    '${widget.key.stringValue}/additionalText',
                                  ),
                                  widget.excludeText ?? '',
                                  style: myaTextStyle.labelLarge.copyWith(
                                    color: myaColors.textIconSubdued,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if ((widget.listItemInfoDetail?.isNotEmpty ?? false) ||
                        (widget.isSpace ?? false))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: kGap4),
                        child: MyaDivider(
                          key: ValueKey<String>(
                            '${widget.key.stringValue}/${MyaDivider.compType}/1',
                          ),
                          type: MyaDividerType.horizontal,
                        ),
                      ),
                    if (widget.listItemInfoDetail?.isNotEmpty ?? false)
                      for (final SearchItemInfoDetailModel listItemInfoDetail
                          in widget.listItemInfoDetail ??
                              <SearchItemInfoDetailModel>[])
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: widget.paddingListChild ??
                                  const EdgeInsets.only(top: 8, right: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                key: ValueKey<String>(
                                  '${widget.key.stringValue}/listInfoDetail3/${widget.listItemInfoDetail?.indexOf(listItemInfoDetail)}',
                                ),
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: (listItemInfoDetail
                                                .iconKey?.isNotEmpty ??
                                            false)
                                        ? SizedBox(
                                            height: 28,
                                            child: MyaIcon(
                                              key: ValueKey<String>(
                                                '${widget.key.stringValue}/listInfoDetail3/${widget.listItemInfoDetail?.indexOf(listItemInfoDetail)}/${MyaIcon.compType}',
                                              ),
                                              iconKey: listItemInfoDetail
                                                      .iconKey ??
                                                  'image_square_default_myais',
                                              size: MyaIconSize.xs,
                                              color: myaColors.primaryOnSurface,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        if (listItemInfoDetail
                                            .titleText.isNotEmpty)
                                          listItemInfoDetail.titleText
                                                  .contains('</')
                                              ? Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                    minHeight: 28,
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: MyaHtml(
                                                    key: ValueKey<String>(
                                                      '${widget.key.stringValue}/listInfoDetail3/${widget.listItemInfoDetail?.indexOf(listItemInfoDetail)}/labelText',
                                                    ),
                                                    htmlData: listItemInfoDetail
                                                        .titleText,
                                                    customTextStyle:
                                                        myaTextStyle
                                                            .bodyMediumExtraThin
                                                            .copyWith(
                                                      color:
                                                          myaColors.blackWhite,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  key: ValueKey<String>(
                                                    '${widget.key.stringValue}/listInfoDetail3/${widget.listItemInfoDetail?.indexOf(listItemInfoDetail)}/labelText',
                                                  ),
                                                  listItemInfoDetail.titleText,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: myaTextStyle
                                                      .bodyMediumExtraThin
                                                      .copyWith(
                                                    color: myaColors
                                                        .textIconMidText,
                                                    height: 2,
                                                  ),
                                                ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (listItemInfoDetail.subtitleText?.isNotEmpty ??
                                false)
                              Row(
                                children: <Widget>[
                                  const SizedBox(width: 20),
                                  Text(
                                    key: ValueKey<String>(
                                      '${widget.key.stringValue}/subtitleText/${widget.listItemInfoDetail?.indexOf(listItemInfoDetail)}',
                                    ),
                                    '(${listItemInfoDetail.subtitleText})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: myaTextStyle.labelLarge.copyWith(
                                      color: myaColors.textIconMidText,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                    if (widget.insuranceOffering != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: kPadding4),
                            child: Row(
                              children: <Widget>[
                                MyaIcon(
                                  iconKey: 'iconui_general_insurance',
                                  size: MyaIconSize.xs,
                                  color: myaColors.primaryOnSurface,
                                ),
                                const SizedBox(width: kPadding3),
                                MyaHtml(
                                  // htmlData: widget
                                  //         .insuranceOffering
                                  //         ?.TORO_supportingLanguage
                                  //         .currentLanguage
                                  //         ?.name ??
                                  //     '',
                                  htmlData: '',
                                  customTextStyle:
                                      myaTextStyle.bodyMedium.copyWith(
                                    color: myaColors.blackWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.insuranceLogo?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: kPadding4,
                                left: kPadding8,
                              ),
                              child: MyaIcon(
                                iconKey: widget.insuranceLogo ?? '',
                                size: MyaIconSize.l,
                              ),
                            ),
                        ],
                      ),
                    if (widget.listGameLogo?.isNotEmpty ?? false)
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: <Widget>[
                            const SizedBox(width: 16),
                            Flexible(
                              child: GridView.count(
                                shrinkWrap: true,
                                primary: false,
                                padding: EdgeInsets.zero,
                                crossAxisCount: 8,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 4,
                                physics: const NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  for (final SearchImageLogoModel listGamingLogo
                                      in widget.listGameLogo?.take(8) ??
                                          <SearchImageLogoModel>[])
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: SizedBox(
                                        width: widget.widthGameLogo ?? 24,
                                        height: widget.heightGameLogo ?? 24,
                                        child: MyaImage(
                                          key: ValueKey<String>(
                                            '${widget.key.stringValue}/${MyaImage.compType}/${widget.listGameLogo?.indexOf(listGamingLogo)}',
                                          ),
                                          imageKey:
                                              listGamingLogo.iconKey ?? '',
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.listFlag?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(left: kPadding8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          children: <Widget>[
                            for (final SearchImageLogoModel listFlag
                                in widget.listFlag?.take(widget.flagCount) ??
                                    <SearchImageLogoModel>[])
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: MyaFlag(
                                  key: ValueKey<String>(
                                    '${widget.key.stringValue}/${MyaFlag.compType}/${widget.listFlag?.indexOf(listFlag)}',
                                  ),
                                  countryCode: listFlag.iconKey ?? '',
                                  size: widget.widthGameLogo ?? 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (widget.isSpace ?? false) const Spacer(),
                    if (widget.isSpeed ?? false) ...<Widget>{
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: MyaDivider(
                              key: ValueKey(
                                '${widget.key.stringValue}/${MyaDivider.compType}/1',
                              ),
                              type: MyaDividerType.horizontal,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              key: ValueKey<String>(
                                '${widget.key.stringValue}/titleText',
                              ),
                              '${widget.titleDownload} / ${widget.titleUpload}',
                              style: myaTextStyle.labelLarge.copyWith(
                                color: myaColors.textIconMidText,
                              ),
                            ),
                          ),
                          widget.titleText ?? const SizedBox(),
                        ],
                      ),
                    },
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: MyaButtonSet(
                          key: ValueKey<String>(
                            '${widget.key.stringValue}/${MyaButtonSet.compType}',
                          ),
                          position: MyaButtonSetPosition.horizontal,
                          buttonSize: MyaButtonSize.small,
                          resetButtonStyle: MyaButtonStyle.outlined,
                          resetButtonText:
                              (widget.textButtonSuccess?.isNotEmpty ?? false)
                                  ? widget.textButtonCancel
                                  : null,
                          onPressedResetButton:
                              (widget.textButtonSuccess?.isNotEmpty ?? false)
                                  ? widget.onPressedCancel
                                  : null,
                          selectButtonText:
                              widget.textButtonSuccess?.isNotEmpty ?? false
                                  ? widget.textButtonSuccess
                                  : widget.textButtonCancel,
                          onPressedSelectButton:
                              widget.textButtonSuccess?.isNotEmpty ?? false
                                  ? widget.onPressedSuccess
                                  : widget.onPressedCancel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
