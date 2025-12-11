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
import 'package:oda_search_micro_journey/src/journeys/search/cubit/search_result_cubit.dart';
import 'package:oda_search_micro_journey/src/journeys/search/widgets/components/search_success_section.dart';
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
  SearchResultCubit? searchResultCubit;
  @override
  void dispose() {
    scrollController.dispose();
    searchBloc = null;
    searchResultCubit = null;
    _isButtonVisible.value = false;
    super.dispose();
  }

  @override
  List<BlocProvider<OdaCubit<ODACubitState>>> createCubitProviders(
      BuildContext context, Map<String, dynamic>? arguments) {
    return [
      BlocProvider<SearchResultCubit>(
        create: (context) => SearchResultCubit(context: context),
      ),
    ];
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
    searchResultCubit ??= context.read<SearchResultCubit>();
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
                        if (notification.metrics.axis == Axis.vertical) {
                          _isButtonVisible.value =
                              notification.metrics.pixels > 1;
                          if (notification.metrics.atEdge &&
                              notification is ScrollEndNotification) {
                            if (notification.metrics.pixels ==
                                notification.metrics.maxScrollExtent) {
                              searchResultCubit?.loadMore();
                            }
                          }
                        }
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
                                SearchInputSection(
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
                                  onFilterSelected: (List<SearchCategoryModel> model) {
                                    searchResultCubit?.selectFilterCategory(model);
                                  },
                                ),
                              ]),
                            ),
                          ),
                          SliverStickyHeader(
                              header: BlocBuilder<SearchBloc, ODAState>(
                                builder: (context, state) {
                                  if (state is SearchSuccessState) {
                                    return SearchCategorySection(
                                        categories: state.result.categoryList,
                                        onTapCategory:
                                            (SearchCategoryModel model) {
                                          searchResultCubit?.selectCategory(
                                              model.value
                                                  ? model.type
                                                  : CategoryType.none);
                                        },
                                        onTapSubCategory:
                                            (SearchCategoryModel model) {
                                          searchResultCubit
                                              ?.selectSubCategory(model);
                                        });
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                        color:
                                            context.myaThemeColors.bgContainer,
                                        border: MyaDividerBorder(context,
                                            isShow: true)),
                                  );
                                },
                              ),
                              sliver: BlocConsumer<SearchBloc, ODAState>(
                                  listener: (context, state) {
                                if (state is SearchStartState ||
                                    state is SearchErrorState) {
                                  searchResultCubit?.reset();
                                }
                              }, builder: (context, state) {
                                if (state is SearchStartState) {
                                  return SliverToBoxAdapter(
                                    child: SearchStartSection(
                                      searchHistory: state.searchHistory,
                                      suggestKeywords: state.suggestKeywords,
                                      onPressed: (String searchText) {
                                        _mangeSearch(context, searchText);
                                      },
                                      onClear: () {
                                        searchBloc
                                            ?.add(HistoryDeleteSearchEvent());
                                        scaffoldMessengerKey.currentState
                                            ?.showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            content: MyaToast(
                                              key: SearchKeyUtil.compose(
                                                  pageKey: pageKey,
                                                  section:
                                                      'alertRecentSearchAreCleared',
                                                  components: [
                                                    MyaToast.compType
                                                  ]),
                                              toastStyle: MyaToastStyle.success,
                                              prefixIcon:
                                                  'iconui_general_success',
                                              descriptionText: context
                                                  .lang(
                                                      'search_alert_recent_cleared')
                                                  .langEmpty,
                                            ),
                                          ),
                                        );
                                      },
                                      onCancel: () {
                                        // add event log
                                      },
                                    ),
                                  );
                                }
                                if (state is SearchLoadingState) {
                                  return const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: kPadding9),
                                      child: MyaLoadingSpinner(),
                                    ),
                                  );
                                }
                                if (state is SearchSuccessState) {
                                  return SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                        kPadding1,
                                        kPadding7,
                                        kPadding1,
                                        kPadding4),
                                    sliver: SearchSuccessSection(
                                      searchResultModel: state.result,
                                      searchText: state.searchText,
                                    ),
                                  );
                                }
                                if (state is SearchErrorState) {
                                  return SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 90),
                                      child: MyaEmptyStates(
                                        key: SearchKeyUtil.compose(
                                            pageKey: 'myaisCommonSearch',
                                            section: 'searchNotFound',
                                            components: [
                                              MyaEmptyStates.compType
                                            ]),
                                        imageKey: "image_illus_not_found",
                                        titleText: context.lang(
                                            'myasset_keyword_not_matches'),
                                      ),
                                    ),
                                  );
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

  void _mangeSearch(BuildContext context, String searchText) {
    FocusScope.of(context).unfocus();
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
