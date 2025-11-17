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
  FullConfig? fullConfig;

  SearchBloc({
    required super.context,
    required this.searchFaqsUsecase,
    required this.coreConfiguration,
    required this.quickMenuManagement,
    required this.coreData,
  }) : super(initialState: SearchInitialState()) {
    on<SearchStartEvent>((event, emit) {
      fullConfig = _getFullConfig();
      if (fullConfig == null) {
        return emit(SearchStartState(
            searchKeywordList: const [], historySearchList: const []));
      }
      final distinctWord = _getDistinctWord(fullConfig: fullConfig!);
      final historySearch = _getHistorySearch();
      emit(SearchStartState(
          searchKeywordList: distinctWord,
          historySearchList: historySearch));
    });
    on<SearchLoadEvent>((event, emit) async {
      emit(SearchLoadingState());
      final result = await searchFaqsUsecase.call(
          input: event.searchText, language: event.language);
      await Future.delayed(const Duration(seconds: 2));
      if (result.isLeft()) {
        emit(SearchErrorState());
      } else {
        emit(SearchSuccessState(
            categories: const [
              SearchCategoryModel(
                id: '1',
                label: 'test',
                value: true
              ),
            ],
            subCategories: const []));
      }
    });
    on<SearchPressedEvent>((event, emit) {});
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

  List<String> _getSuggestionSearch() {
    
    return [];
  }
  //end start event handler
}
