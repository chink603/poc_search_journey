import 'package:core/core.dart';
import 'package:core/utils/quick_menu_management.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_data_tmf658_loyalty_management/domain/domain.dart';
import 'package:oda_data_tmf667_document_management/domain/domain.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_presentation_universal/domain/customer_domain/usecase/get_assets_list_realm_usecase.dart';
import 'package:oda_presentation_universal/oda_presentation_universal.dart';
import 'package:oda_presentation_universal/utils/smart_search.dart';
import '../bloc/bloc/search_bloc.dart';
import '../config/j_search_config.dart';
import '../models/models.dart';
import '../utils/util.dart';
import '../widgets/widgets.dart';

class SearchStep0 extends OdaStep {
  static const String path = '1';
  final String pageKey = 'myaisCommonSearch';
  final String section = 'headerNavigation';
  final String jPath = '/j_search';
  ScrollController scrollController = ScrollController();
  final ValueNotifier<bool> _isButtonVisible = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  SearchBloc? searchBloc;
  @override
  void dispose() {
    scrollController.dispose();
    searchBloc = null;
    super.dispose();
  }

  @override
  List<BlocProvider<OdaBloc<ODAEvent, ODAState>>> createBlocProviders(
      BuildContext context, Map<String, dynamic>? arguments) {
    return [
      BlocProvider<SearchBloc>(
        create: (context) => SearchBloc(
          context: context,
          useCaseSearchFaq: GetIt.I.get<SearchFaqsUsecase>(),
          useCaseAssetListRealm: GetIt.I.get<GetAssetsListRealmUsecase>(),
          useCaseLoyaltyCategoryConfig:
              GetIt.I.get<GetLoyaltyCategoryConfigUseCase>(),
          useCaseSmartSearch: GetIt.I.get<SmartSearch>(),
          coreConfiguration: CoreConfiguration(),
          quickMenuManagement: QuickMenuManagement(),
          ntypeManagement: NTypeManagement(),
          coreData: CoreData(),
          coreLanguage: context.odaCore.coreLanguage,
          routeName: arguments?['routeName'] ?? '',
          suggestedKeyword: arguments?['suggestedKeyword'] ?? [],
        )..add(SearchStartEvent()),
      ),
    ];
  }

  @override
  Widget builder(BuildContext context, Map<String, dynamic>? arguments) {
    if (!scrollController.hasClients) {
      scrollController = ScrollController();
    }
    searchBloc ??= context.read<SearchBloc>();
    final myaColors = context.myaThemeColors;
    return StreamBuilder(
        stream: context.read<LanguageCubit>().stream,
        builder: (context, asyncSnapshot) {
          if (searchBloc?.state is SearchStartState) {
            final currentState = searchBloc?.state as SearchStartState;
            if (asyncSnapshot.data != null &&
                currentState.searchKeywordList.isNotEmpty) {
              final suggestedKeyword = CoreNavigator().suggestedKeyword(context,
                  forceRouteName: arguments?['routeName'] ?? '');
              searchBloc?.add(ChangeLanguageEvent(
                  language: asyncSnapshot.data!,
                  suggestedKeyword: suggestedKeyword));
            }
          }
          return ScaffoldMessenger(
              key: scaffoldMessengerKey,
              child: Scaffold(
                backgroundColor: myaColors.bgBg,
                resizeToAvoidBottomInset: false,
                appBar: MyaHeaderNav(
                  key: SearchKeyUtil.compose(
                      pageKey: pageKey,
                      section: section,
                      components: [MyaHeaderNav.compType]),
                  isLeading: true,
                  isDivider: false,
                  onTapLeading: () {
                    notifyCallBackAction(context: context, payload: {
                      'exit': true,
                    });
                  },
                  headerText: context.lang(JSearchConfig.titleSearch),
                  trailingActions: [
                    ValueListenableBuilder<bool>(
                        valueListenable: _isButtonVisible,
                        builder: (context, value, child) {
                          if (!value) return const SizedBox.shrink();
                          return MyaButton(
                            key: SearchKeyUtil.compose(
                                pageKey: pageKey,
                                section: section,
                                components: [MyaButton.compType, 'goToTop']),
                            label: context.lang(JSearchConfig.buttonGoToTop),
                            theme: MyaButtonTheme.primary,
                            style: MyaButtonStyle.text,
                            size: MyaButtonSize.large,
                            suffixIconKey: 'iconui_general_arrow_up',
                            onPressed: () async {
                              scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          );
                        })
                  ],
                ),
                body: Container(
                  color: myaColors.bgBg,
                  child: NotificationListener(
                      onNotification: (ScrollNotification notification) {
                        _isButtonVisible.value = notification.metrics.atEdge &&
                            notification.metrics.pixels > 0;
                        return false;
                      },
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              color: myaColors.bgContainer,
                              padding: const EdgeInsets.only(bottom: kPadding6),
                              child: Stack(children: [
                                SearchInputField(
                                  key: SearchKeyUtil.compose(
                                      pageKey: 'seach',
                                      section: 'searchInputField',
                                      components: ['rawAutocomplete']),
                                  onSelected: (String searchText) {
                                    _mangeSearch(context, searchText);
                                  },
                                  onEmpty: () {
                                    searchBloc?.add(SearchStartEvent());
                                  },
                                ),
                              ]),
                            ),
                          ),
                          SliverStickyHeader.builder(
                              builder: (context, state) =>
                                  BlocBuilder<SearchBloc, ODAState>(
                                    builder: (context, state) {
                                      if (state is SearchSuccessState) {
                                        return Container();
                                        // return _buildCategory(
                                        //   context,
                                        //   state.categories,
                                        //   state.subCategories,
                                        // );
                                      }
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: context
                                                .myaThemeColors.bgContainer,
                                            border: MyaDividerBorder(context,
                                                isShow: true)),
                                      );
                                    },
                                  ),
                              sliver: BlocBuilder<SearchBloc, ODAState>(
                                  builder: (context, state) {
                                if (state is SearchStartState) {
                                  // history and suggesttion
                                  return _buildHistoryAndSuggestion(
                                    context,
                                    state.searchHistory,
                                    state.suggestKeywords,
                                  );
                                }
                                if (state is SearchLoadingState) {
                                  // loading
                                  return _buildLoading();
                                }
                                if (state is SearchSuccessState) {
                                  // result
                                  return _buildResult(context);
                                }
                                if (state is SearchErrorState) {
                                  // error
                                  return _buildError(context);
                                }
                                return const SliverToBoxAdapter(
                                    child: SizedBox.shrink());
                              })),
                        ],
                      )),
                ),
              ));
        });
  }

  Widget _buildHistoryAndSuggestion(
    BuildContext context,
    List<String> searchHistory,
    List<String> suggestKeywords,
  ) {
    return SliverToBoxAdapter(
        child: SearchHistorySuggest(
      searchHistory: searchHistory,
      suggestKeywords: suggestKeywords,
      onPressed: (String searchText) {
        _mangeSearch(context, searchText);
      },
      onClear: () {
        searchBloc?.add(HistoryDeleteSearchEvent());
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: MyaToast(
              key: SearchKeyUtil.compose(
                  pageKey: pageKey,
                  section: 'alertRecentSearchAreCleared',
                  components: [MyaToast.compType]),
              toastStyle: MyaToastStyle.success,
              prefixIcon: 'iconui_general_success',
              descriptionText:
                  context.lang('search_alert_recent_cleared').langEmpty,
            ),
          ),
        );
      },
      onCancel: () {
        // add event log
      },
    ));
  }

  Widget _buildCategory(
      BuildContext context,
      List<SearchCategoryModel> categories,
      List<SearchCategoryModel> subCategories) {
    return Container(
      decoration: BoxDecoration(
          color: context.myaThemeColors.bgContainer,
          border: MyaDividerBorder(context, isShow: true)),
      padding: EdgeInsets.fromLTRB(kPadding7, kPadding1, kPadding7,
          categories.isNotEmpty ? kPadding4 : kPadding1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categories.isNotEmpty)
            ListChipFilter(
                list: categories,
                onTap: (String label) {
                  // if (state.categories.length > 1) {
                  //   context
                  //       .read<NewSearchMainBloc>()
                  //       .add(SearchSelectedChipEvent(label));
                  // }
                }),
          if (subCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: kPadding4),
              child:
                  ListChipFilter(list: subCategories, onTap: (String label) {}),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return SliverToBoxAdapter(child: Container());
  }

  Widget _buildError(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
      padding: const EdgeInsets.only(top: 90),
      child: MyaEmptyStates(
        key: SearchKeyUtil.compose(
            pageKey: 'myaisCommonSearch',
            section: 'searchNotFound',
            components: [MyaEmptyStates.compType]),
        imageKey: "image_illus_not_found",
        titleText: context.lang('myasset_keyword_not_matches'),
      ),
    ));
  }

  Widget _buildLoading() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: kPadding9),
        child: MyaLoadingSpinner(),
      ),
    );
  }

  void _mangeSearch(BuildContext context, String searchText) {
    final getFullConfig = searchBloc?.fullConfig;
    final checkRoute =
        CheckRouteHelper(searchText: searchText, fullConfig: getFullConfig!)
            .getRouteModel;
    switch (checkRoute.type) {
      case CheckRouteEnum.tab:
        notifyCallBackAction(context: context, payload: {
          'onSearch': {
            'type': CheckRouteEnum.tab.name,
            'routeName': checkRoute.tabName,
          }
        });
        break;
      case (CheckRouteEnum.route):
        if (checkRoute.routeName != null) {
          notifyCallBackAction(context: context, payload: {
            'onSearch': {
              'type': CheckRouteEnum.route.name,
              'routeName': checkRoute.routeName,
              'arguments': checkRoute.arguments,
            }
          });
        }
        break;
      case CheckRouteEnum.url:
        notifyCallBackAction(context: context, payload: {
          'onSearch': {
            'type': CheckRouteEnum.url.name,
            'urlName': checkRoute.urlName,
            'requestAuthen': checkRoute.requestAuthen,
          }
        });

        break;
      default:
        // Handle unknown route type if needed
        break;
    }
    searchBloc?.add(
        SearchLoadEvent(searchText: searchText, checkRouteModel: checkRoute));
  }

  @override
  OdaStepInfo info() {
    return const OdaStepInfo(path: path);
  }
}
