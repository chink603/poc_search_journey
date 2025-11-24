import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
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
    searchBloc?.close();
    searchBloc = null;
    super.dispose();
  }

  @override
  Widget builder(BuildContext context, Map<String, dynamic>? arguments) {
    if (!scrollController.hasClients) {
      scrollController = ScrollController();
    }
    searchBloc ??= context.read<SearchBloc>();
    final myaColors = context.myaThemeColors;
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
            onTapLeading: () {},
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
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            BlocBuilder<SearchBloc, ODAState>(
                              buildWhen: (previous, current) =>
                                  previous is SearchInitialState &&
                                  current is SearchStartState,
                              builder: (context, state) {
                                if (state is SearchInitialState) {
                                  return const SizedBox.shrink();
                                }
                                return _buildSearchInputField(
                                    context,
                                    myaColors,
                                    state is SearchStartState
                                        ? state.searchKeywordList
                                        : []);
                              },
                            ),
                            BlocBuilder<SearchBloc, ODAState>(
                              builder: (context, state) {
                                if (state is SearchSuccessState) {
                                  return _buildFilter(context, state);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverStickyHeader.builder(
                        builder: (context, state) =>
                            BlocBuilder<SearchBloc, ODAState>(
                              builder: (context, state) {
                                if (state is! SearchSuccessState) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color:
                                            context.myaThemeColors.bgContainer,
                                        border: MyaDividerBorder(context,
                                            isShow: true)),
                                  );
                                }
                                return _buildCategory(
                                  context,
                                  state.categories,
                                  state.subCategories,
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
  }

  Widget _buildSearchInputField(BuildContext context, MyaThemeColors myaColors,
      List<String> searchKeywordList) {
    return SearchInputField(
        key: SearchKeyUtil.compose(
            pageKey: 'seach',
            section: 'searchInputField',
            components: ['rawAutocomplete']),
        searchKeywordList: searchKeywordList,
        onSelected: (String searchText) {
          _mangeSearch(context, searchText);
        });
  }

  Widget _buildFilter(BuildContext context, state) {
    return MyaBadgeNotification(
      key: const ValueKey(
          'myaisCommonSearch/headerNavigation/${MyaBadgeNotification.compType}/notificationFilter'),
      widget: MyaButtonIcon(
        key: const ValueKey(
            'myaisCommonSearch/headerNavigation/${MyaButtonIcon.compType}/filterButton'),
        style: MyaButtonIconStyle.iconOnly,
        iconKey: 'iconui_general_filter',
        isDisabled: state is! SearchSuccessState,
        onPressed: () {
          final List<MyaBottomSheetFilterContent> filterContent = [];
          myaShowBottomSheet(
            context: context,
            enableDrag: true,
            isDismissible: true,
            widget: StatefulBuilder(
              builder: (ctx, setState) {
                return MyaBottomSheetFilter(
                  key: const ValueKey(
                      'myaisCommonSearch/aroundYouFilter/${MyaBottomSheetFilter.compType}'),
                  onPressedIconClose: () => Navigator.of(context).pop(),
                  isShowCloseIcon: true,
                  isDragHandle: true,
                  showStickyButton: true,
                  stateResetButton: true,
                  showScrollBars: true,
                  selectButtonText: context.lang('home_search_confirm_botton'),
                  resetButtonText: context.lang('home_search_reset_button'),
                  resetButtonStyle: MyaButtonStyle.outlined,
                  onSelectButton: () {},
                  onResetButton: () {},
                  onClose: () {
                    Navigator.of(context).pop();
                  },
                  contents: filterContent,
                );
              },
            ),
          );
        },
      ),
      positionedRight: 8,
      positionedTop: 10,
      isShowBadge: false,
      badgeType: MyaBadgeType.dot,
      padding: const EdgeInsets.only(right: kPadding4),
    );
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
        searchBloc?.add(DeleteHistoryEvent());
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
            'type': 'tab',
            'routeName': checkRoute.tabName,
          }
        });
        break;
      case (CheckRouteEnum.route):
        if (checkRoute.routeName != null) {
          notifyCallBackAction(context: context, payload: {
            'onSearch': {
              'type': 'route',
              'routeName': checkRoute.routeName,
              'arguments': checkRoute.arguments,
            }
          });
        }
        break;
      case CheckRouteEnum.url:
        notifyCallBackAction(context: context, payload: {
          'onSearch': {
            'type': 'url',
            'urlName': checkRoute.urlName,
            'requestAuthen': checkRoute.requestAuthen,
          }
        });

        break;
      default:
        searchBloc?.add(SearchLoadEvent(searchText: searchText));
    }
  }

  @override
  OdaStepInfo info() {
    return const OdaStepInfo(path: path);
  }
}
