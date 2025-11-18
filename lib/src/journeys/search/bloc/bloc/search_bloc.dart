import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_search_micro_journey/src/journeys/search/models/models.dart';
import 'package:core/utils/quick_menu_model.dart';
import 'package:core/utils/quick_menu_management.dart';

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
  final SearchFaqsUsecase searchFaqsUsecase;
  final CoreConfiguration coreConfiguration;
  final QuickMenuManagement quickMenuManagement;
  final CoreData coreData;
  final OdaCoreLanguage coreLanguage;
  final String routeName;
  FullConfig? fullConfig;

  SearchBloc({
    required super.context,
    required this.searchFaqsUsecase,
    required this.coreConfiguration,
    required this.quickMenuManagement,
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
          searchKeywordList: distinctWord,
          searchHistory: historySearch,
          suggestKeywords: suggestKeywords));
    });
    on<SearchLoadEvent>((event, emit) async {
      emit(SearchLoadingState());
      final result = await searchFaqsUsecase.call(
          input: event.searchText, language: coreLanguage.currentLanguage);
      await Future.delayed(const Duration(seconds: 2));
      if (result.isLeft()) {
        emit(SearchErrorState());
      } else {
        emit(SearchSuccessState(categories: const [
          SearchCategoryModel(id: '1', label: 'test', value: true),
        ], subCategories: const []));
      }
    });
    on<SearchPressedEvent>((event, emit) {});
    on<AddHistorySearchEvent>((event, emit)  {
       _addHistorySearch(event.searchText);
    });
    on<DeleteHistoryEvent>((event, emit) async {
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
}

class DateCoreNavigator {
  DateCoreNavigator({required this.startDate, required this.endDate});
  DateCoreNavigator.onlyEndDate({required this.endDate});

  DateTime? startDate;
  DateTime? endDate;
}
