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
    final selectedCategoryType =
        _autoSelectCategoryType(searchResultModel.categoryList);
    final packageCards =
        await _initLoadPackageCards(searchResultModel.packageList);
    emit(SearchResultSuccess(
        packageCards: packageCards,
        searchResultModel: searchResultModel,
        selectedCategoryType: selectedCategoryType));
  }

  void selectedCategoryType(CategoryType categoryType) {
    if (state is SearchResultSuccess) {
      final currentState = state as SearchResultSuccess;
      emit(currentState.copyWith(selectedCategoryType: categoryType));
    }
  }

  void loadMore() async {
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
        emit(currentState.copyWith(packageCards: [...currentState.packageCards, ...cards]));
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
}
