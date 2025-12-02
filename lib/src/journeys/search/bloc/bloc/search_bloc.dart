import 'package:core/utils/ntype_management/ntype_management.dart';
import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart';
import 'package:oda_data_tmf672_user_roles_permissions/utils/utils.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_presentation_universal/domain/customer_domain/usecase/get_assets_list_realm_usecase.dart';
import 'package:oda_presentation_universal/utils/home/home_universal_utils.dart';
import 'package:oda_search_micro_journey/src/journeys/search/models/models.dart';
import 'package:core/utils/quick_menu_model.dart';
import 'package:core/utils/quick_menu_management.dart';
import 'package:oda_search_micro_journey/src/journeys/search/utils/util.dart';

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
  final String historySearchKey = 'searchHistoryKey';
  final SearchFaqsUsecase useCaseSearchFaq;
  final GetAssetsListRealmUsecase useCaseAssetListRealm;

  final CoreConfiguration coreConfiguration;
  final QuickMenuManagement quickMenuManagement;
  final NTypeManagement ntypeManagement;

  final CoreData coreData;
  final OdaCoreLanguage coreLanguage;
  final String routeName;
  FullConfig? fullConfig;

  SearchBloc({
    required super.context,
    required this.useCaseSearchFaq,
    required this.coreConfiguration,
    required this.quickMenuManagement,
    required this.ntypeManagement,
    required this.useCaseAssetListRealm,
    required this.coreData,
    required this.coreLanguage,
    required this.routeName,
  }) : super(initialState: SearchInitialState()) {
    on<SearchStartEvent>((event, emit) {
      fullConfig ??= _getFullConfig();
      final distinctWord = _getDistinctWord(fullConfig: fullConfig!);
      final historySearch = _getHistorySearch();
      final suggestKeywords = _getSuggestionSearch();
      emit(SearchStartState(
          searchText: '',
          searchKeywordList: distinctWord,
          searchHistory: historySearch,
          suggestKeywords: suggestKeywords));
    });
    on<SearchLoadEvent>((event, emit) async {
      add(HistoryAddSearchEvent(searchText: event.searchText));
      final asset = await _getAsset();
      if (event.checkRouteModel.type == CheckRouteEnum.none) {
        emit(SearchLoadingState(searchText: event.searchText));
        final result = await useCaseSearchFaq.call(
            input: event.searchText, language: coreLanguage.currentLanguage);
        await Future.delayed(const Duration(seconds: 2));
        if (result.isLeft()) {
          emit(SearchErrorState());
        }
        if (result.isRight()) {
          emit(SearchSuccessState(categories: const [
            SearchCategoryModel(id: '1', label: 'test', value: true),
          ], subCategories: const []));
        }
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

  // suggestion keyword
  List<String> _getSuggestionSearch() {
    try {
      return _getActiveForRoute(routeName) ?? [];
    } catch (e) {
      return [];
    }
  }

  List<String>? _getActiveForRoute(String currentRoute) {
    int index = 0;

    while (true) {
      final String basePath = 'suggestionKeywordConfig.$currentRoute.$index';
      final String periodPath = '$basePath.period';
      final String? resultPeriod =
          coreConfiguration.getConfigByPath(periodPath);
      if (resultPeriod == null) return null;

      final isPeriodInRange = _isExpiredPeriod(resultPeriod);
      if (isPeriodInRange) {
        final String keywordAndLanguage =
            '$basePath.keyword.${coreLanguage.currentLanguage}';
        final List<dynamic>? resultSuggestion =
            coreConfiguration.getConfigByPath(keywordAndLanguage);
        if (resultSuggestion == null || resultSuggestion.isEmpty) {
          CoreLog()
              .info('CoreNavigator().suggestedKeyword(.) keywordValue is null');
          return null;
        }

        final List<String> result = [];
        result.addAll(
          resultSuggestion
              .map((e) => e is String ? e : e.toString())
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
        return result;
      }
      index++;
    }
  }

  bool _isExpiredPeriod(String periodValue) {
    final bool isPeriodInRange = _dateInRangeKeyword(periodValue);
    return isPeriodInRange;
  }

  bool _dateInRangeKeyword(String period) {
    final DateCoreNavigator date = _dateConfigToLocal(period);
    final DateTime startDate = date.startDate!;
    final DateTime endDate = date.endDate!;
    final DateTime now = DateTime.now();
    if (!(now.isAfter(startDate) && now.isBefore(endDate))) return false;
    return true;
  }

  DateCoreNavigator _dateConfigToLocal(String dateConfig,
      [bool onlyEndDate = false]) {
    final List<String> preDate = dateConfig.split(" ");
    if (onlyEndDate) {
      final DateTime endDate = DateTime.parse("${preDate[1]}Z").toLocal();
      return DateCoreNavigator.onlyEndDate(endDate: endDate);
    }
    final DateTime startDate = DateTime.parse("${preDate[0]}Z").toLocal();
    final DateTime endDate = DateTime.parse("${preDate[1]}Z").toLocal();
    return DateCoreNavigator(startDate: startDate, endDate: endDate);
  }
  //end start event handler

  //get asset for call data
  Future<SearchAssetModel> _getAsset() async {
    final currentAsset = await _getCurrentAsset();
    final isLogin = ntypeManagement.isLogin();
    final rawNtype = await ntypeManagement.getRawNType() ?? '';
    final mobileNumber = await currentAsset.mobileNumber;
    final mobileNumberInternal = _convertToInternationalFormat(mobileNumber);
    final isGetPackage =
        await conditionGetPackage(rawNtype: rawNtype, isLogin: isLogin);

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

  Future<bool> conditionGetPackage(
      {required String rawNtype, required bool isLogin}) async {
    if (isLogin && rawNtype.isNotEmpty) {
      final noCCI = rawNtype != 'CCI';
      final groupNType = await ntypeManagement.getGroupNType();
      final isAisMainGroup = switch (groupNType) {
        NType.nonAis || NType.fibre || NType.iot => false,
        _ => true,
      };
      return isAisMainGroup && noCCI;
    }
    return false;
  }
  // end asset
}

class DateCoreNavigator {
  DateCoreNavigator({required this.startDate, required this.endDate});
  DateCoreNavigator.onlyEndDate({required this.endDate});

  DateTime? startDate;
  DateTime? endDate;
}
