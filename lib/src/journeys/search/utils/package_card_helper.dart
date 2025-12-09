import 'package:collection/collection.dart' hide IterableZip;
import 'package:core/core.dart' show CurrentLang;
import 'package:core/core_lang/core_lang.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:next_core/next_core.dart';
import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_data_tmf620_product_catalog_management/data/models/models.dart';
import 'package:oda_data_tmf620_product_catalog_management/oda_data_tmf620_product_catalog_management.dart';
import 'package:oda_presentation_universal/utils/format_number.dart';

import '../models/models.dart';

class PackageCardHelper {
  PackageCardHelper({
    required this.coreLanguage,
  }) {
    _monthsKey = getLanguagesMultipleKey(<String>['month', 'months']);
    _yearsKey = getLanguagesMultipleKey(<String>['year', 'years']);
  }

  Future<({String price, String subUnit})> _extractPriceInfo(ProductOffering po) async {
    final productOfferingPriceList = await po.productOfferingPrice;
    final productOfferingPrice = productOfferingPriceList.isNotEmpty
        ? productOfferingPriceList.first
        : null;
    final price = await displayPrice(productOfferingPrice);
    final unitOfMeasureAmount = await productOfferingPrice?.getUnitOfMeasureAmount;
    final unitOfMeasureUnit = await productOfferingPrice?.getUnitOfMeasureUnit;
    final subUnit = getUnitOfMeasure(
      unitOfMeasureAmount,
      unitOfMeasureUnit,
    );
    return (price: price, subUnit: subUnit);
  }

  final String callbackRoute = '/product-package/usage-and-package-detail';
  final CoreLanguage coreLanguage;
  final String defaultIconKey = 'image_square_default_myais';
  final String detailPageRoute = '/product-package/package-detail';
  final String optionPageRoute = '/product-package/select-effective-date';
  final String searchBadgeText = 'badge';

  late final List<String> _monthsKey;
  late final List<String> _yearsKey;

  Future<PackageCardViewModel> preparePackageCardViewModel(
    ProductOffering? productOffering,
  ) async {
    if (productOffering == null) {
      throw ArgumentError('ProductOffering cannot be null');
    }

    final SearchProductBadgeModel? badgeInfo =
        await _extractBadgeInfo(productOffering);
    final ({String price, String subUnit}) priceInfo =
        await _extractPriceInfo(productOffering);

    final productSpec = await productOffering.productSpecification;
    final String chipLabelText =
        productSpec?.TORO_productType == 'main'
            ? coreLanguage.getLanguageByKey('package_badge_main')
            : coreLanguage.getLanguageByKey('on_top_package');

    final actualPrice = await productOffering.getActualPrice;
    final excludeText = priceInfo.price.isNotEmpty
        ? getExcludeText(actualPrice.toNumberFormat)
        : null;

    final bool isNetGift =
        productSpec?.TORO_ussdCode?.isNotEmpty == true;

    final headingText = await productOffering.getName ?? '';
    return PackageCardViewModel(
      id: productOffering.id,
      productOffering: productOffering,
      excludeText: excludeText,
      headingTitle: headingText,
      price: priceInfo.price,
      unit: priceInfo.price.isNotEmpty
          ? coreLanguage.getLanguageByKey('currency_sign_baht')
          : '',
      subUnit: priceInfo.price.isNotEmpty ? priceInfo.subUnit : '',
      listItemInfoDetail: const [],
      listGameLogo: null,
      badgeLabelText: badgeInfo?.badgeLabelText,
      badgeStyle: badgeInfo?.badgeStyle,
      prefixIcon: badgeInfo?.prefixIconBadge,
      suffixIcon: badgeInfo?.suffixIconBadge,
      chipLabelText: chipLabelText,
      isNetGift: isNetGift,
    );
  }

  Future<SearchPackageIconsModel> getIconsPackage(
      ProductOffering productOffering) async {
    final productSpec = await productOffering.productSpecification;
    final results = await Future.wait([
      _getListItemInfoDetailCardPackage(productOffering),
      productSpec?.TORO_productType
                  ?.toLowerCase()
                  .trim()
                  .contains('main') ==
              true
          ? _getIconPrivilege(productSpec)
          : Future.value(null),
    ]);

    final List<SearchItemInfoDetailModel> listItemInfoDetail =
        (results[0] as List<SearchItemInfoDetailModel>? ?? [])
            .map((e) => e.copyWith(
                  titleText: removeInfinHtml(html: e.titleText),
                  iconKey: e.iconKey != null ? getmappingKeyIcon(e.iconKey!) : null,
                ))
            .whereType<SearchItemInfoDetailModel>()
            .toList();
    final privilegeIcons = results[1] as List<Attachment>?;

    final listGameLogo =
        await _getGamingLogoForProductType(productOffering, privilegeIcons);
    
    return SearchPackageIconsModel(
      listInfoDetail: listItemInfoDetail,
      listGameLogo: listGameLogo,
    );
  }

  Future<SearchProductBadgeModel> extractBadgeProductOffering(Attachment attachment) async {
    //model
    String extractedTextBadge = '';
    List<String> extractedBadgeContent = <String>[];
    MyaBadgeStyle extractedTypeBadge = MyaBadgeStyle.hotOffers;
    bool foundBadgeContent = false;
    bool foundBadgeColor = false;

    final displayInfoResult = await attachment.TORO_displayInfo;
    final CoreDataList<String>? displayInfo = displayInfoResult?.value;
    String prefixIconBadge = '';
    String suffixIconBadge = '';
    if (displayInfo != null) {
      for (final String value in displayInfo) {
        final String badgeValue = value.trim().toLowerCase();
        if (badgeValue.startsWith('badgecontent=')) {
          final String extractedBadgeContentvalue =
              value.split('=').last.trim();
          foundBadgeContent = true;
          extractedBadgeContent = extractedBadgeContentvalue.split('|');
        }
        if (badgeValue.startsWith('badgecolor=')) {
          String content = value.split('=').last.trim();
          if (content == 'hot_offers') {
            content = 'hotOffers';
          }
          final MyaBadgeStyle? parsedTypeContent =
              matchedMyaBadgeStyle(content);
          if (parsedTypeContent != null) {
            extractedTypeBadge = parsedTypeContent;
            foundBadgeColor = true;
          }
        }

        if (foundBadgeContent && foundBadgeColor) {
          break;
        }
      }

      prefixIconBadge = (extractedBadgeContent.firstWhereIndexedOrNull(
                (
                  int index,
                  String element,
                ) =>
                    index == 0 &&
                    element.contains('[') &&
                    element.contains(']'),
              ) ??
              '')
          .replaceAll('[', '')
          .replaceAll(']', '');
      suffixIconBadge = (extractedBadgeContent.lastWhereIndexedOrNull(
                (int index, String element) =>
                    index == (extractedBadgeContent.length - 1) &&
                    element.contains('[') &&
                    element.contains(']'),
              ) ??
              '')
          .replaceAll('[', '')
          .replaceAll(']', '');

      extractedTextBadge = extractedBadgeContent
          .where(
            (String element) =>
                !element.contains('[') && !element.contains(']'),
          )
          .join(' ');
    }

    final bool isValid = foundBadgeContent && foundBadgeColor;
    return SearchProductBadgeModel(
      badgeLabelText: extractedTextBadge,
      badgeStyle: extractedTypeBadge,
      prefixIconBadge: prefixIconBadge.isNotEmpty ? prefixIconBadge : null,
      suffixIconBadge: suffixIconBadge.isNotEmpty ? suffixIconBadge : null,
      badgeValid: isValid,
    );
  }

  Future<String> displayPrice(ProductOfferingPrice? productOfferingPrice) async {
    if (productOfferingPrice == null || productOfferingPrice.usable == null) {
      return '';
    }
    
    final price = await productOfferingPrice.getPrice;
    return (price != null && price > 0) ? price.toNumberFormat : '';
  }

  String getUnitOfMeasure(
    double? unitOfMeasureAmount,
    String? unitOfMeasureUnit,
  ) {
    final String unit = unitOfMeasureUnit ?? '';

    final double amount = unitOfMeasureAmount ?? 0;
    if (_monthsKey
            .where(
              (String e) =>
                  e.toLowerCase().trim() ==
                  unitOfMeasureUnit?.toLowerCase().trim(),
            )
            .isNotEmpty ||
        _yearsKey
            .where(
              (String e) =>
                  e.toLowerCase().trim() ==
                  unitOfMeasureUnit?.toLowerCase().trim(),
            )
            .isNotEmpty) {
      if (amount <= 1) {
        return unit;
      }
    }
    return amount > 0 ? '${amount.toNumber} $unit' : unit;
  }

  List<String> getLanguagesMultipleKey(List<String> keys) {
    final List<String> results = <String>[];
    for (final String key in keys) {
      results.addAll(getLanguages(key));
    }
    return results;
  }

  List<String> getLanguages(String key) {
    final List<String> results = <String>[];
    for (final String lang in CurrentLang().localeList) {
      results.add(getLanguage(key, lang: lang));
    }
    return results;
  }

  String getLanguage(
    String key, {
    String? lang,
  }) {
    return coreLanguage.getLanguageByKey(key,
        language: lang ?? CurrentLang().currentLanguage);
  }

  String? getExcludeText(String excludeText) {
    if (excludeText == '') {
      return null;
    }
    return '''${getLanguage('package_vat_included')} $excludeText ${getLanguage('currency_sign_baht')}''';
  }

  List<SearchImageLogoModel>? getListGamingLogo(
      List<Attachment>? listGamingLogo) {
    SearchImageLogoModel data;
    final List<SearchImageLogoModel> dataList = <SearchImageLogoModel>[];
    if (listGamingLogo != null && listGamingLogo.isNotEmpty) {
      for (final Attachment element in listGamingLogo) {
        data = SearchImageLogoModel(
          iconKey: element.name ?? defaultIconKey,
        );
        dataList.add(data);
      }
    }
    return dataList;
  }

  Future<List<SearchItemInfoDetailModel>?> getListItemInfoDetailCardPackage(
    ProductOffering productOffering,
    List<ProductSpecCharacteristic>? productSpecCharacteristic, {
    bool isInternetDaily = false,
  }) async {
    final List<SearchItemInfoDetailModel> dataList =
        <SearchItemInfoDetailModel>[];

    if (productSpecCharacteristic != null &&
        productSpecCharacteristic.isNotEmpty) {
      for (final ProductSpecCharacteristic productSpec
          in productSpecCharacteristic) {

        final ProductSpecCharacteristic? productSpecCharData =
           await getProductSpecCharacteristicLanguage(
          productOffering,
          productSpec.id,
        );

        final CoreDataList<ProductSpecCharacteristicValue>
            productSpecProductSpecCharacteristicValue =
            await productSpec.productSpecCharacteristicValue;

        final String text =
            '''${productSpec.name} ${productSpecProductSpecCharacteristicValue.isNotEmpty ? productSpecProductSpecCharacteristicValue.first.value.as<String?>() : ''} ${productSpecProductSpecCharacteristicValue.isNotEmpty ? (productSpecProductSpecCharacteristicValue.first.unitOfMeasure ?? '') : ''}''';

        final subTitleText = isInternetDaily ? await productSpec.getDescriptionDaily : null;
        final bool checkTypeIsIconColor = !checkIconTypeIsIconColor(productSpecCharData);
        final attachment = await productSpecCharData?.attachment;
        final iconKey = (attachment?.isNotEmpty ?? false)
              ? attachment?.first.name ?? defaultIconKey : defaultIconKey;
              
        final SearchItemInfoDetailModel data = SearchItemInfoDetailModel(
          titleText: productSpecCharData?.name ?? text,
          subtitleText: subTitleText,
          iconKey: iconKey,
          isColor: checkTypeIsIconColor,
        );
        dataList.add(data);
      }
    }
    return dataList;
  }

  Future<ProductSpecCharacteristic?> getProductSpecCharacteristicLanguage(
    ProductOffering? productOffering,
    String? productSpecCharacteristicId,
  ) async {
    final List<ProductSpecCharacteristic> productSpecCharDataAttachmentResult =
        (await (await productOffering?.productSpecification)
                ?.getProductSpecCharacteristic)!
            .where(
              (ProductSpecCharacteristic x) =>
                  x.id == productSpecCharacteristicId,
            )
            .toList();

    final ProductSpecCharacteristic? productSpecCharDataAttachment =
        (productSpecCharDataAttachmentResult.isNotEmpty)
            ? productSpecCharDataAttachmentResult.first
            : null;
    return productSpecCharDataAttachment;
  }

  bool checkIconTypeIsIconColor(
    ProductSpecCharacteristic? productSpecCharData,
  ) {
    final bool checkTypeIsIconColor =
        (productSpecCharData?.isInternet ?? false) ||
            (productSpecCharData?.isVerticalApp ?? false) ||
            (productSpecCharData?.isContentMusic ?? false) ||
            (productSpecCharData?.isContentVDO ?? false);
    return checkTypeIsIconColor;
  }

  MyaBadgeStyle? matchedMyaBadgeStyle(String content) {
    try {
      return MyaBadgeStyle.values.firstWhere(
        (MyaBadgeStyle e) =>
            e.toString().split('.').last.toLowerCase() == content.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  String getmappingKeyIcon(String? subkey) {
    final String? data = CoreConfiguration().getConfigByPath('mappingKeyIcon.$subkey');
    return data ?? subkey ?? 'iconui_general_default';
  }

  String removeInfinHtml({required String? html}) {
    if (html == null) return '';
    return html.replaceAll('&infin;</span>&nbsp;', '</span>');
  }

  Future<List<SearchItemInfoDetailModel>?> _getListItemInfoDetailCardPackage(
      ProductOffering productOffering) async {
    final ProductSpecification? spec =
        await productOffering.productSpecification;
    if (spec != null && spec.usable != null) {
      final List<ProductSpecCharacteristic> characteristics =
          await spec.productSpecCharacteristicShortDisplayOnTop;
      return getListItemInfoDetailCardPackage(
        productOffering,
        characteristics,
      );
    }
    return null;
  }

  Future<List<SearchImageLogoModel>?> _getGamingLogoForProductType(
      ProductOffering productOffering, List<Attachment>? privilegeIcons) async {
    final spec = await productOffering.productSpecification;
    if (spec?.TORO_productType?.toLowerCase().trim().contains('main') == true) {
      return getListGamingLogo(privilegeIcons);
    }
    if (spec?.TORO_productType?.toLowerCase().trim().contains('ontop') ==
        true) {
      final entertainIcons = await spec?.getIconEntertainsContentMusicVDO;
      return getListGamingLogo(entertainIcons);
    }
    return null;
  }

  Future<List<Attachment>?> _getIconPrivilege(
      ProductSpecification? productSpecChar) async {
    return await productSpecChar?.getIconPrivileges;
  }

  Future<SearchProductBadgeModel?> _extractBadgeInfo(ProductOffering po) async {
    final attachmentsList = await po.getAttachment;
    final attachmentBadge = attachmentsList.firstWhereOrNull(
        (att) => att.attachmentType?.trim().toLowerCase() == searchBadgeText);
    return attachmentBadge != null
        ? await extractBadgeProductOffering(attachmentBadge)
        : null;
  }
}
