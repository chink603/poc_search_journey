import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_fe_framework/oda_framework.dart'
    hide OdaCoreLanguage, CoreLanguage;
import 'package:oda_search_micro_journey/src/journeys/search/utils/util.dart';
import 'package:core/core_lang/core_lang.dart';

import '../models/models.dart';
import '../utils/search_util.dart';

part 'search_result_state.dart';

class SearchResultCubit extends OdaCubit<ODACubitState> {
  SearchResultCubit({required super.context})
      : super(initialState: SearchResultInitial());

  void reset() {
    SearchUtil.clearAllCaches();
    emit(SearchResultInitial());
  }

  void setUpResult(
      SearchResultModel searchResultModel, String searchText) async {
    emit(SearchResultLoading());
    final selectedCategoryType =
        _autoSelectCategoryType(searchResultModel.categoryList);

    final filterCategory = _filterSearchCategoryByType(
        searchResultModel.filterList?[selectedCategoryType] ?? [],
        selectedCategoryType);

    final packageCards = await _loadPackageCards(searchResultModel.packageList);
    final loyaltyProductList = searchResultModel.privilegeList?.toList();
    final searchCampaignModel = await _filterMapCampaignsAndSubCategories(
        searchResultModel.subCategoryList?[CategoryType.privilege] ?? [],
        loyaltyProductList ?? []);
    final subCategories = _selectSubCategoryByType(
        searchCampaignModel.subCategories, selectedCategoryType);
    emit(SearchResultSuccess(
        filterCategory: filterCategory,
        packageCards: packageCards,
        subCategories: subCategories,
        searchResultModel: searchResultModel,
        selectedCategoryType: selectedCategoryType,
        searchCampaignModel: searchCampaignModel,
        loyaltyProductList: _mapCampaigns(loyaltyProductList ?? []),
        campaignsSortedBy: searchCampaignModel.groupedAll,
        campaignCount: searchCampaignModel.groupedAllCount));
  }

  void selectCategory(CategoryType categoryType) {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      final subCategories = _selectSubCategoryByType(
          currentState.searchCampaignModel.subCategories, categoryType);
      final filterCategory = _filterSearchCategoryByType(
          currentState.searchResultModel.filterList?[categoryType] ?? [],
          categoryType);
      emit(
        currentState.copyWith(
            selectedCategoryType: categoryType,
            subCategories: subCategories,
            filterCategory: filterCategory),
      );
    }
  }

  void selectFilterCategory(List<SearchCategoryModel> model) async {
    if (model.isEmpty) return;

    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      final category = currentState.selectedCategoryType;
      final findOneSelected = model.firstWhere((element) => element.value,
          orElse: () => const SearchCategoryModel(
              id: '', label: '', value: false, type: CategoryType.none));
      if (currentState.filterCategory.any((element) =>
          element.id == findOneSelected.id &&
          element.value == findOneSelected.value)) {
        return;
      }
      final oldFilterList = currentState.searchResultModel.filterList;
      if (oldFilterList == null) return;
      final newFilterList = Map.of(oldFilterList);
      newFilterList[category] = model;

      switch (category) {
        case CategoryType.privilege:
          final sortNumber = int.tryParse(findOneSelected.id) ?? 0;
          final campaigns = await _sortCampaigns(
              sortNumber, currentState.loyaltyProductList!.values.toList());
          final searchCampaignModel = await _filterMapCampaignsAndSubCategories(
              currentState.searchResultModel.subCategoryList?[category] ?? [],
              campaigns);
          final compareSubCategory = _compareSelectSubCategory(
              searchCampaignModel.subCategories,
              currentState.selectedSubCategory);
          final selectedSubCategory = compareSubCategory.firstWhere((element) => element.value, orElse: () => const SearchCategoryModel(
              id: '', label: '', value: false, type: CategoryType.none));

          final selectCampaignsSort = selectedSubCategory.value
              ? searchCampaignModel.groupedBySubCategoryIds[
                      selectedSubCategory.id] ??
                  searchCampaignModel.groupedAll
              : searchCampaignModel.groupedAll;
          final campaignCount = selectedSubCategory.value
              ? searchCampaignModel.groupedBySubCategoryCount[
                      selectedSubCategory.id] ??
                  searchCampaignModel.groupedAllCount
              : searchCampaignModel.groupedAllCount;

          emit(currentState.copyWith(
            filterCategory: model,
            subCategories: compareSubCategory,
            searchCampaignModel: searchCampaignModel,
            campaignsSortedBy: selectCampaignsSort,
            campaignCount: campaignCount,
            searchResultModel: currentState.searchResultModel.copyWith(
              filterList: newFilterList,
            ),
          ));
          break;
        default:
          break;
      }
    }
  }

  void selectSubCategory(SearchCategoryModel model) {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      if (model.type == CategoryType.privilege) {
        final campaigns = model.value
            ? currentState
                    .searchCampaignModel.groupedBySubCategoryIds[model.id] ??
                []
            : currentState.searchCampaignModel.groupedAll;
        final campaignCount = model.value
            ? currentState
                    .searchCampaignModel.groupedBySubCategoryCount[model.id] ??
                0
            : currentState.searchCampaignModel.groupedAllCount;

        if (campaigns.isEmpty || campaignCount == 0) {
          return;
        }
        emit(currentState.copyWith(
          selectedSubCategory: model,
          campaignsSortedBy: campaigns,
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
        final cards = await _loadPackageCards(currentState
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

  List<SearchCategoryModel> _selectSubCategoryByType(
      List<SearchCategoryModel> searchCampaignModel, CategoryType type) {
    return type == CategoryType.privilege ? searchCampaignModel : [];
  }

  List<SearchCategoryModel> _filterSearchCategoryByType(
      List<SearchCategoryModel>? searchCampaignModel, CategoryType type) {
    if (searchCampaignModel == null) return [];
    return type == CategoryType.privilege ? searchCampaignModel : [];
  }

  // Package
  Future<List<PackageCardViewModel>> _loadPackageCards(
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

  // Privilege

  // Sort
  Future<List<LoyaltyProgramProductSpec>> _sortCampaigns(
      int sortNumber, List<LoyaltyProgramProductSpec> campaigns) async {
    final sortedCampaigns =
        await SearchUtil.sortCampaigns(campaigns, sortNumber);
    return sortedCampaigns;
  }

  Future<SearchCampaignModel> _filterMapCampaignsAndSubCategories(
    List<SearchCategoryModel> subCategories,
    List<LoyaltyProgramProductSpec> data,
  ) async {
    if (data.isEmpty) {
      return SearchCampaignModel.empty();
    }

    final Map<String, List<String>> subCatIdCache = {};
    final campaignsByCatId = <String, List<String>>{};
    final categoryCache = <String, String>{};
    final allCategoryIds = <String>{};
    final groupedAll = <String>[];
    for (var i = 0; i < data.length; i++) {
      final p = data[i];

      final category = await p.category;
      if (category.isEmpty) continue;
      final cateFirst = category.first;
      final categoryId = cateFirst.TORO_syncCategoryId;
      final campaignId = p.id;

      if (categoryId == null || categoryId.isEmpty || campaignId.isEmpty) {
        continue;
      }

      categoryCache[categoryId] = cateFirst.TORO_categoryType ?? '';

      allCategoryIds.add(categoryId);

      groupedAll.add(campaignId);

      campaignsByCatId.putIfAbsent(categoryId, () => []).add(campaignId);
    }

    if (allCategoryIds.isEmpty) {
      return SearchCampaignModel.empty();
    }

    SearchUtil.setCacheCategory(categoryCache);
    // 2) กรอง subCategories และสร้าง map: subCatKey -> campaignIds
    final campaignsBySubCatIds = <String, List<String>>{};
    final resultSubCategories = <SearchCategoryModel>[];

    for (final subCat in subCategories) {
      final key = subCat.id.toString();

      final ids =
          subCatIdCache[key] ??= key.split(',').map((e) => e.trim()).toList();

      bool hasMatch = false;
      for (final id in ids) {
        if (allCategoryIds.contains(id)) {
          hasMatch = true;
          break;
        }
      }

      if (!hasMatch) continue;

      resultSubCategories.add(subCat);

      final campaignsForThisSubCatIds = <String>{};
      for (final id in ids) {
        campaignsForThisSubCatIds.addAll(campaignsByCatId[id] ?? []);
      }

      if (campaignsForThisSubCatIds.isNotEmpty) {
        campaignsBySubCatIds[key] = campaignsForThisSubCatIds.toList();
      }
    }

    final groupedBySubCategoryCount =
        campaignsBySubCatIds.map((k, v) => MapEntry(k, v.length));

    if (resultSubCategories.length == 1) {
      resultSubCategories.first.value == true;
    }

    return SearchCampaignModel(
      groupedBySubCategoryIds: campaignsBySubCatIds,
      subCategories: resultSubCategories,
      groupedBySubCategoryCount: groupedBySubCategoryCount,
      groupedAllCount: groupedAll.length,
      groupedAll: groupedAll,
    );
  }

  Map<String, LoyaltyProgramProductSpec>? _mapCampaigns(
      List<LoyaltyProgramProductSpec>? data) {
    if (data == null || data.isEmpty) return null;
    final map = <String, LoyaltyProgramProductSpec>{};
    for (final element in data) {
      map[element.id] = element;
    }
    return map;
  }


  List<SearchCategoryModel> _compareSelectSubCategory(
      List<SearchCategoryModel> subCategories,
      SearchCategoryModel? selectedSubCategory) {
    if (subCategories.isEmpty || selectedSubCategory == null) return subCategories;
    if (!selectedSubCategory.value) return subCategories;
    final replacedSubCategories = subCategories
        .map((e) => e.id == selectedSubCategory.id
            ? e.copyWith(value: true)
            : e.copyWith(value: false))
        .toList();

    return replacedSubCategories;
  }
}
