import 'package:core/utils/ntype_management/ntype_management.dart';
import 'package:oda_data_schema/main.core.export.dart'
    hide LoyaltyProgramProductSpec;
import 'package:oda_data_tmf658_loyalty_management/domain/domain.dart';
import 'package:oda_data_tmf658_loyalty_management/enum/loyalty_category_config_key_enum.dart';
import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart';
import 'package:oda_data_tmf672_user_roles_permissions/utils/utils.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_presentation_universal/domain/customer_domain/usecase/get_assets_list_realm_usecase.dart';
import 'package:oda_presentation_universal/utils/home/home_universal_utils.dart';
import 'package:oda_presentation_universal/utils/smart_search.dart';
import 'package:oda_search_micro_journey/src/journeys/search/models/models.dart';
import 'package:core/utils/quick_menu_model.dart';
import 'package:core/utils/quick_menu_management.dart';
import 'package:oda_search_micro_journey/src/journeys/search/utils/util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dartz/dartz.dart';
part 'search_event.dart';
part 'search_state.dart';

typedef FullConfig = ({
  List<SearchKeywordConfig> route,
  List<SearchKeywordConfig> quickMenu,
  List<SearchKeywordConfig> subRoute,
  List<SearchKeywordConfig> keywordCoupon,
  List<SearchQuickMenuMaster> quickMenuMaster,
});

class SearchBloc extends OdaBloc<ODAEvent, ODAState> {
  SearchBloc({
    required super.context,
    required this.useCaseSearchFaq,
    required this.useCaseSmartSearch,
    required this.coreConfiguration,
    required this.quickMenuManagement,
    required this.ntypeManagement,
    required this.useCaseAssetListRealm,
    required this.useCaseLoyaltyCategoryConfig,
    required this.coreData,
    required this.coreLanguage,
    required this.routeName,
    required this.suggestedKeyword,
  }) : super(initialState: SearchInitialState()) {
    on<SearchStartEvent>((event, emit) {
      fullConfig ??= _getFullConfig();
      final distinctWord = _getDistinctWord(fullConfig: fullConfig!);
      final historySearch = _getHistorySearch();
      emit(SearchStartState(
          searchText: '',
          searchKeywordList: distinctWord,
          searchHistory: historySearch,
          suggestKeywords: suggestedKeyword));
    });
    on<SearchLoadEvent>((event, emit) async {
      add(HistoryAddSearchEvent(searchText: event.searchText));

      if (event.checkRouteModel.type == CheckRouteEnum.none) {
        emit(SearchLoadingState(searchText: event.searchText));
        final assetModel = await _getAsset();
        final dataResult =
            await _getData(assetModel, event.searchText.toLowerCase());
        dataResult.fold(
          (l) => emit(SearchErrorState()),
          (r) => emit(SearchSuccessState(result: r)),
        );
      }
    });
    on<SearchPressedEvent>((event, emit) {});
    on<HistoryAddSearchEvent>((event, emit) async {
      await _addHistorySearch(event.searchText);
      if (state is SearchStartState) {
        final currentState = state as SearchStartState;
        final historySearch = _getHistorySearch();
        emit(currentState.copyWith(
          searchText: event.searchText,
          searchHistory: historySearch,
        ));
      }
    });
    on<HistoryDeleteSearchEvent>((event, emit) async {
      await _deleteHistorySearch();
      add(SearchStartEvent());
    });
    on<ChangeLanguageEvent>((event, emit) async {
      if (state is SearchStartState) {
        final currentState = state as SearchStartState;
        if (currentState.searchKeywordList.isEmpty) return;
        suggestedKeyword = event.suggestedKeyword;
        emit(currentState.copyWith(
          suggestKeywords: suggestedKeyword,
        ));
      }
    });
  }

  final CoreConfiguration coreConfiguration;
  final CoreData coreData;
  final OdaCoreLanguage coreLanguage;
  FullConfig? fullConfig;
  final String historySearchKey = 'searchHistoryKey';
  final NTypeManagement ntypeManagement;
  final QuickMenuManagement quickMenuManagement;
  final String routeName;
  List<String> suggestedKeyword;
  final GetAssetsListRealmUsecase useCaseAssetListRealm;
  final GetLoyaltyCategoryConfigUseCase useCaseLoyaltyCategoryConfig;
  final SearchFaqsUsecase useCaseSearchFaq;
  final SmartSearch useCaseSmartSearch;

  Future<bool> conditionGetPackage(
      {required String? rawNtype, required NType? groupNType}) async {
    final noCCI = rawNtype != 'CCI';
    final isAisMainGroup = switch (groupNType) {
      NType.nonAis || NType.fibre || NType.iot => false,
      _ => true,
    };
    return isAisMainGroup && noCCI;
  }

  //start event handler

  FullConfig _getFullConfig() {
    const String configKeyword = 'searchKeywordConfig';
    final Map<dynamic, dynamic> config =
        coreConfiguration.getFullConfig(configKeyword);
    final Map<String, dynamic> convertedConfig = config.map(
      (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    );
    final listRoute = List.from(convertedConfig['menu'] ?? [])
        .map((e) => SearchKeywordConfig.fromJson(e))
        .toList();
    final listQuickMenu = List.from(convertedConfig['quickMenu'] ?? [])
        .map((e) => SearchKeywordConfig.fromJson(e))
        .toList();
    final listSubRoute = List.from(convertedConfig['routePage'] ?? [])
        .map((e) => SearchKeywordConfig.fromJson(e))
        .toList();
    final listKeywordCoupon = List.from(convertedConfig['keyCoupon'] ?? [])
        .map((e) => SearchKeywordConfig.fromJson(e))
        .toList();
    final listQuickMenuMaster = _getQuickMenuMaster();
    return (
      route: listRoute,
      quickMenu: listQuickMenu,
      subRoute: listSubRoute,
      keywordCoupon: listKeywordCoupon,
      quickMenuMaster: listQuickMenuMaster,
    );
  }

  List<SearchQuickMenuMaster> _getQuickMenuMaster() {
    final List<QuickMenuCustom>? result =
        quickMenuManagement.getQuickMenuCurrentMyId(myID: '');
    if (result == null) {
      return [];
    }
    final newItems =
        result.where((element) => element.quickMenu != null).map((element) {
      final quickMenu = element.quickMenu!;
      final url = quickMenu.urls;
      return SearchQuickMenuMaster(
        id: quickMenu.id,
        name: quickMenu.name ?? '',
        isOpen: quickMenu.isOpen ?? false,
        urlScheme: quickMenu.urlScheme ?? '',
        requireLogin: quickMenu.requireLogin ?? false,
        urlTH: url.isNotEmpty ? url.first.th ?? '' : '',
        urlEN: url.isNotEmpty ? url.first.en ?? '' : '',
        img: quickMenu.img ?? '',
        menuVersion: quickMenu.appVersion ?? '',
        isNew: quickMenu.isNew ?? false,
      );
    }).toList();
    return newItems;
  }

  List<String> _getDistinctWord({
    required FullConfig fullConfig,
  }) {
    final distinctWord = [
      ...fullConfig.route,
      ...fullConfig.quickMenu,
      ...fullConfig.subRoute,
      ...fullConfig.keywordCoupon,
    ].map((element) => element.keyword.toString()).toSet().toList();
    distinctWord.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return distinctWord;
  }

  //history search

  List<String> _getHistorySearch() {
    return coreData
            .variableStorage()
            .getKeyValueList(historySearchKey)
            ?.cast<String>() ??
        [];
  }

  Future<void> _addHistorySearch(String value) async {
    final historySearchList = _getHistorySearch();
    if (historySearchList.contains(value)) {
      historySearchList.remove(value);
    }
    historySearchList.insert(0, value);
    return await coreData
        .variableStorage()
        .setKeyValueList(historySearchKey, historySearchList.take(5).toList());
  }

  Future<void> _deleteHistorySearch() async {
    return await coreData.variableStorage().removeKeyValue(historySearchKey);
  }

  //get asset for call data
  Future<SearchAssetModel> _getAsset() async {
    final isLogin = ntypeManagement.isLogin();
    if (!isLogin) {
      return SearchAssetModel();
    }
    final currentAsset = await _getCurrentAsset();
    final rawNtype =
        await ntypeManagement.getRawNType(currentAsset: currentAsset);
    final groupNType =
        await ntypeManagement.getGroupNType(currentAsset: currentAsset);
    final mobileNumber = await currentAsset.mobileNumber;
    final mobileNumberInternal = _convertToInternationalFormat(mobileNumber);
    final isGetPackage =
        await conditionGetPackage(rawNtype: rawNtype, groupNType: groupNType);

    return SearchAssetModel(
        currentAsset: currentAsset,
        isLogin: isLogin,
        mobileNumber: mobileNumber,
        rawNtype: rawNtype,
        isGetPackage: isGetPackage,
        mobileNumberInternal: mobileNumberInternal);
  }

  Future<EntityRef?> _getCurrentAsset() async {
    final assetListResult = await useCaseAssetListRealm.execute();
    if (assetListResult.isRight()) {
      final right = assetListResult.asRight();
      if (right.isEmpty) {
        return null;
      }
      return await right.firstOrNull?.currentAsset();
    }
    return null;
  }

  String _convertToInternationalFormat(String mobileNumber) {
    final numberWithoutLeadingZero =
        mobileNumber.startsWith('0') ? mobileNumber.substring(1) : mobileNumber;

    return '66$numberWithoutLeadingZero';
  }

  // end asset

  // get data
  Future<Either<SearchResultModel?, SearchResultModel>> _getData(
      SearchAssetModel assetModel, String searchText) async {
    try {
      final dataResult = await Future.wait<dynamic>([
        assetModel.isGetPackage
            ? useCaseSmartSearch.searchPackage(searchText,
                assetModel.mobileNumber, assetModel.mobileNumberInternal,
                currentAsset: assetModel.currentAsset)
            : Future.value(),
        _getPrivilege(searchText),
        useCaseSearchFaq.call(
            input: searchText, language: coreLanguage.currentLanguage),
      ]);
      final packageResult = dataResult[0] is List<ProductOffering>
          ? dataResult[0] as List<ProductOffering>
          : <ProductOffering>[];
      final privilegeResult =
          dataResult[1] is CoreDataResult ? dataResult[1] : null;
      final eitherFaq =
          dataResult[2] as Either<DocumentFailure, List<DocumentEntity>>;
      final List<DocumentEntity> faqResult = eitherFaq.getOrElse(() => []);
      final quickMenuResult = _getQuickMenu(searchText);
      final result = SearchResultModel(
        quickMenuList: quickMenuResult.isNotEmpty ? quickMenuResult : null,
        packageList: packageResult.isNotEmpty ? packageResult : null,
        privilegeList: privilegeResult,
        faqList: faqResult.isNotEmpty ? faqResult : null,
      );
      if (result.isEmpty()) {
        return const Left(null);
      }
      final category = _getCategory(result);
      final subCategory = _getSubCategory(result);
      final filter = _getFilter(result);
      return Right(result.copyWith(
          categoryList: category,
          subCategoryList: subCategory,
          filterList: filter));
    } catch (e) {
      return const Left(null);
    }
  }

  List<SearchCategoryModel> _getCategory(SearchResultModel result) {
    final List<SearchCategoryModel> categoryList = [];
    if (result.quickMenuList != null) {
      categoryList.add(_getCategoryModel(
        id: CategoryType.quickMenu.name,
        label: CategoryType.quickMenu.label,
        icon: CategoryType.quickMenu.icon,
      ));
    }
    if (result.packageList != null) {
      categoryList.add(_getCategoryModel(
        id: CategoryType.package.name,
        label: CategoryType.package.label,
        icon: CategoryType.package.icon,
      ));
    }
    if (result.privilegeList != null) {
      categoryList.add(_getCategoryModel(
          id: CategoryType.privilege.name,
          label: CategoryType.privilege.label,
          icon: CategoryType.privilege.icon));
    }
    if (result.faqList != null) {
      categoryList.add(_getCategoryModel(
        id: CategoryType.faq.name,
        label: CategoryType.faq.label,
        icon: CategoryType.faq.icon,
      ));
    }
    return categoryList;
  }

  SearchCategoryModel _getCategoryModel(
      {required String id,
      required String icon,
      required String label,
      bool? value}) {
    return SearchCategoryModel(
      id: id,
      label: label,
      icon: icon,
      value: value ?? false,
    );
  }

  Map<CategoryType, List<SearchCategoryModel>>? _getSubCategory(
      SearchResultModel result) {
    final Map<CategoryType, List<SearchCategoryModel>> subCategoryMap = {};
    if (result.privilegeList != null) {
      final subCategoryResult = useCaseLoyaltyCategoryConfig.call(
          domainUsecase: DomainUsecase.homeSearch);
      final subCategoryList = subCategoryResult
          .map((e) => SearchCategoryModel.fromEntityPrivilegeSubCategory(e))
          .toList();
      subCategoryMap[CategoryType.privilege] = subCategoryList;
    }
    return subCategoryMap.isNotEmpty ? subCategoryMap : null;
  }

  Map<CategoryType, List<SearchCategoryModel>>? _getFilter(
      SearchResultModel result) {
    final Map<CategoryType, List<SearchCategoryModel>> filterMap = {};
    if (result.privilegeList != null) {
      final filterPrivilege =
          useCaseLoyaltyCategoryConfig.getLoyaltyFilterButton();
      final filterPrivilegeList = filterPrivilege
          .map((e) => SearchCategoryModel.fromEntityPrivilegeFilter(e))
          .toList();
      filterMap[CategoryType.privilege] = filterPrivilegeList;
    }

    return filterMap.isNotEmpty ? filterMap : null;
  }

  List<SearchQuickMenuMaster> _getQuickMenu(String searchText) {
    final config = fullConfig;
    if (config == null) return [];

    final categoryIds = <String>{};
    for (final item in config.quickMenu) {
      if (item.keyword.toLowerCase() == searchText) {
        categoryIds.add(item.navigation.toString());
      }
    }

    if (categoryIds.isEmpty) return [];

    final selectedMenus = <SearchQuickMenuMaster>[];
    for (final master in config.quickMenuMaster) {
      if (categoryIds.contains(master.id)) {
        selectedMenus.add(master);
      }
    }

    return selectedMenus;
  }

  Future<CoreDataResult?> _getPrivilege(String searchText) async {
    final SearchLoyaltyUsecase useCaseSearchLoyalty =
        GetIt.I.get<SearchLoyaltyUsecase>();
    useCaseSearchLoyalty.initCampaignState();
    await Future.delayed(const Duration(milliseconds: 300));
    useCaseSearchLoyalty.onTextChanged(searchText: searchText);
    try {
      final privilege = await useCaseSearchLoyalty.stream
          .debounceTime(const Duration(milliseconds: 500))
          .timeout(const Duration(seconds: 5))
          .first;
      useCaseSearchLoyalty.disposeStreamController();
      return privilege.isNotEmpty ? privilege : null;
    } catch (e) {
      useCaseSearchLoyalty.disposeStreamController();
      return null;
    }
  }
}
