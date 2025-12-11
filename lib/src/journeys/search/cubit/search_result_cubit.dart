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

  void reset() {
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

    final packageCards =
        await _initLoadPackageCards(searchResultModel.packageList);
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
        loyaltyProductList: loyaltyProductList,
        campaignsSortedBy: searchCampaignModel.groupedAll.values.toList(),
        campaignCount: searchCampaignModel.groupCount));
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

  void selectFilterCategory(List<SearchCategoryModel> model) {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      final category = currentState.selectedCategoryType;
      final oldFilterList = currentState.searchResultModel.filterList;

      if (oldFilterList != null) {
        final newFilterList = Map.of(oldFilterList);
        newFilterList[category] = model;
        emit(
          currentState.copyWith(
            filterCategory: model,
            searchResultModel: currentState.searchResultModel.copyWith(
              filterList: newFilterList,
            ),
          ),
        );
      }
    }
  }

  void selectSubCategory(SearchCategoryModel model) {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      if (model.type == CategoryType.privilege) {
        List<int> campaigns = [];
        int campaignCount = 0;
        if (model.value) {
          campaigns = _findSubCategoryCampaigns(
            currentState.searchCampaignModel.groupedAll,
            currentState
                    .searchCampaignModel.groupedBySubCategoryIds[model.id] ??
                [],
          );
          campaignCount = currentState
                  .searchCampaignModel.groupedBySubCategoryCount[model.id] ??
              0;
        } else {
          campaigns =
              currentState.searchCampaignModel.groupedAll.values.toList();
          campaignCount = currentState.searchCampaignModel.groupCount;
        }
        if (campaigns.isEmpty || campaignCount == 0) {
          return;
        }
        emit(currentState.copyWith(
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

  List<SearchCategoryModel> _selectSubCategoryByType(
      List<SearchCategoryModel> searchCampaignModel, CategoryType type) {
    return type == CategoryType.privilege ? searchCampaignModel : [];
  }

  List<SearchCategoryModel> _filterSearchCategoryByType(
      List<SearchCategoryModel>? searchCampaignModel, CategoryType type) {
    if (searchCampaignModel == null) return [];
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

  List<int> _findSubCategoryCampaigns(
      Map<String, int> groupedAll, List<String> campaignsIds) {
    final campaigns = <int>[];
    for (final campaignId in campaignsIds) {
      campaigns.add(groupedAll[campaignId] ?? 0);
    }
    return campaigns;
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
    final campaignIdToIndex = <String, int>{};

    final allCategoryIds = <String>{};
    for (var i = 0; i < data.length; i++) {
      final p = data[i];

      final category = await p.category;
      if (category.isEmpty) continue;

      final categoryId = category.first.TORO_syncCategoryId;
      final campaignId = p.id;

      if (categoryId == null || categoryId.isEmpty || campaignId.isEmpty) {
        continue;
      }

      allCategoryIds.add(categoryId);
      campaignIdToIndex[campaignId] = i;
      campaignsByCatId.putIfAbsent(categoryId, () => []).add(campaignId);
    }

    if (allCategoryIds.isEmpty) {
      return SearchCampaignModel.empty();
    }

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
    final groupCount = data.length;

    if (resultSubCategories.length == 1) {
      resultSubCategories.first.value == true;
    }

    return SearchCampaignModel(
      groupedBySubCategoryIds: campaignsBySubCatIds,
      subCategories: resultSubCategories,
      groupedBySubCategoryCount: groupedBySubCategoryCount,
      groupCount: groupCount,
      groupedAll: campaignIdToIndex,
    );
  }
}
