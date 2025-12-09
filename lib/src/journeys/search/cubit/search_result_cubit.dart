import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_fe_framework/oda_framework.dart'
    hide OdaCoreLanguage, CoreLanguage;
import 'package:oda_search_micro_journey/src/journeys/search/utils/util.dart';
import 'package:core/core_lang/core_lang.dart';

import '../models/models.dart';

part 'search_result_state.dart';

class SearchResultCubit extends OdaCubit<ODACubitState> {
  SearchResultCubit({required super.context})
      : super(initialState: SearchResultInitial());

  void setUpResult(
      SearchResultModel searchResultModel, String searchText) async {
    emit(SearchResultLoading());
    final selectedCategoryType =
        _autoSelectCategoryType(searchResultModel.categoryList);
    final packageCards =
        await _initLoadPackageCards(searchResultModel.packageList);
    final loyaltyProductList = searchResultModel.privilegeList?.toList();
    final searchCampaignModel = await filterMapCampaignsAndSubCategories(
        searchResultModel.subCategoryList?[CategoryType.privilege] ?? [],
        loyaltyProductList ?? []);
    final subCategories = selectSubCategoryByType(
        searchCampaignModel.subCategories, selectedCategoryType);
    emit(SearchResultSuccess(
        packageCards: packageCards,
        subCategories: subCategories,
        searchResultModel: searchResultModel,
        selectedCategoryType: selectedCategoryType,
        searchCampaignModel: searchCampaignModel,
        loyaltyProductList: loyaltyProductList,
        campaigns: searchCampaignModel.groupedAll,
        campaignCount: searchCampaignModel.groupCount));
  }

  void selectCategory(CategoryType categoryType) {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      final subCategories = selectSubCategoryByType(
          currentState.searchCampaignModel.subCategories, categoryType);
      emit(
        currentState.copyWith(
            selectedCategoryType: categoryType, subCategories: subCategories),
      );
    }
  }

  void selectSubCategory(SearchCategoryModel model) {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      if (model.type == CategoryType.privilege) {
        final campaigns = model.value
            ? currentState.searchCampaignModel.groupedBySubCategory[model.id]
            : currentState.searchCampaignModel.groupedAll;
        final campaignCount = model.value
            ? currentState
                .searchCampaignModel.groupedBySubCategoryCount[model.id]
            : currentState.searchCampaignModel.groupCount;
        emit(currentState.copyWith(
          campaigns: campaigns,
          campaignCount: campaignCount,
        ));
      }
    }
  }

  Future<void> loadMore() async {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      if (currentState.selectedCategoryType == CategoryType.package) {
        if (currentState.packageCards.length >=
            currentState.searchResultModel.packageList!.length) {
          return;
        }
        final cards = await _initLoadPackageCards(currentState
            .searchResultModel.packageList!
            .skip(currentState.packageCards.length)
            .toList());
        emit(currentState
            .copyWith(packageCards: [...currentState.packageCards, ...cards]));
      }
      
    }
  }

  CategoryType _autoSelectCategoryType(
      List<SearchCategoryModel>? categoryList) {
    if (categoryList == null || categoryList.isEmpty) return CategoryType.none;
    return categoryList.length == 1
        ? categoryList.first.type
        : CategoryType.none;
  }

  List<SearchCategoryModel> selectSubCategoryByType(
      List<SearchCategoryModel> searchCampaignModel, CategoryType type) {
    return type == CategoryType.privilege ? searchCampaignModel : [];
  }

  Future<List<PackageCardViewModel>> _initLoadPackageCards(
      List<ProductOffering>? packageList) async {
    if (packageList == null) return [];
    final packageCardHelper = PackageCardHelper(
      coreLanguage: CoreLanguage(),
    );
    final packageCards = <PackageCardViewModel>[];
    final packageInit = packageList.take(10);
    for (final po in packageInit) {
      final card = await packageCardHelper.preparePackageCardViewModel(po);
      card.icons = await packageCardHelper.getIconsPackage(po);
      packageCards.add(card);
    }
    return packageCards;
  }

  Future<SearchCampaignModel> filterMapCampaignsAndSubCategories(
    List<SearchCategoryModel> subCategories,
    List<LoyaltyProgramProductSpec> data,
  ) async {
    if (data.isEmpty) {
      return SearchCampaignModel.empty();
    }
    final Map<String, List<String>> subCatIdCache = {};
    final campaignsByCatId = <String, List<LoyaltyProgramProductSpec>>{};

    // 1. สร้าง Set ของ category IDs แบบเร็ว
    final allCategoryIds = <String>{};
    for (final p in data) {
      final category = await p.category;
      if (category.isNotEmpty) {
        final categoryId = category[0].TORO_syncCategoryId;
        if (categoryId != null && categoryId.isNotEmpty) {
          allCategoryIds.add(categoryId);
          campaignsByCatId.putIfAbsent(categoryId, () => []).add(p);
        }
      }
    }

    if (allCategoryIds.isEmpty) {
      return SearchCampaignModel.empty();
    }
    final campaignsBySubCat = <String, List<LoyaltyProgramProductSpec>>{};
    // 2. กรอง subCategories แบบเร็ว
    List<SearchCategoryModel> resultSubCategories = <SearchCategoryModel>[];
    for (final subCat in subCategories) {
      final key = subCat.id.toString();

      // ใช้ cache สำหรับ split results
      final ids =
          subCatIdCache[key] ??= key.split(',').map((e) => e.trim()).toList();

      // Early return เมื่อเจอ match แรก
      bool hasMatch = false;
      for (final id in ids) {
        if (allCategoryIds.contains(id)) {
          hasMatch = true;
          break; // หยุดทันทีเมื่อเจอ
        }
      }

      if (hasMatch) {
        resultSubCategories.add(subCat);
        final campaignsForThisSubCat = <LoyaltyProgramProductSpec>{};
        for (final id in ids) {
          campaignsForThisSubCat.addAll(campaignsByCatId[id] ?? []);
        }
        if (campaignsForThisSubCat.isNotEmpty) {
          campaignsBySubCat[key] = campaignsForThisSubCat.toList();
        }
      }
    }
    // 3. นับจำนวน campaign ของแต่ละ sub-category
    final groupedBySubCategoryCount =
        campaignsBySubCat.map((k, v) => MapEntry(k, v.length));
    final groupCount = data.length;
    // Step 6: Return map grouped max limitCampaign
    final groupedAllMax =
        campaignsBySubCat.map((k, v) => MapEntry(k, v.take(20).toList()));

    if (resultSubCategories.length == 1) {
      resultSubCategories.first.value == true;
    }
    return SearchCampaignModel(
        groupedBySubCategory: groupedAllMax,
        subCategories: resultSubCategories,
        groupedBySubCategoryCount: groupedBySubCategoryCount,
        groupCount: groupCount,
        groupedAll: data.take(20).toList());
  }
}
