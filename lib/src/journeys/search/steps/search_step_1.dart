import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';

import '../bloc/bloc/search_bloc.dart';
import '../models/models.dart';
import '../utils/util.dart';
import '../widgets/widgets.dart';

class SearchStep0 extends OdaStep {
  static const String path = '1';
  ScrollController scrollController = ScrollController();
  SearchBloc? searchBloc;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
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
              builder: (context, state) => BlocBuilder<SearchBloc, ODAState>(
                    builder: (context, state) {
                      if (state is! SearchSuccessState) {
                        return Container(
                          decoration: BoxDecoration(
                              color: context.myaThemeColors.bgContainer,
                              border: MyaDividerBorder(context, isShow: true)),
                        );
                      }
                      return _buildCategory(
                        context,
                        state.categories,
                        state.subCategories,
                      );
                    },
                  ),
              sliver:
                  BlocBuilder<SearchBloc, ODAState>(builder: (context, state) {
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
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              })),
        ],
      ),
    );
  }

  Widget _buildSearchInputField(BuildContext context, MyaThemeColors myaColors,
      List<String> searchKeywordList) {
    return RawAutocomplete<String>(
        key: SearchKeyUtil.compose(
            pageKey: 'seach',
            section: 'searchInputField',
            components: ['rawAutocomplete']),
        focusNode: FocusNode(),
        textEditingController: TextEditingController(),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          } else {
            textEditingValue.text.replaceAll('', ''.trim());
            final getMatches = searchKeywordList
                .where((element) => element
                    .toLowerCase()
                    .startsWith(textEditingValue.text.toLowerCase()))
                .toList();
            return getMatches;
          }
        },
        onSelected: (String keyword) {
          searchBloc?.add(AddHistorySearchEvent(searchText: keyword));
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController searchController,
          FocusNode focusNode2,
          VoidCallback onFieldSubmitted,
        ) {
          return BlocBuilder<SearchBloc, ODAState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  kPadding7,
                  kPadding1,
                  state is SearchSuccessState ? 52 : kPadding7,
                  kPadding6,
                ),
                child: MyaInputFieldSearch(
                    key: const ValueKey(
                        'myaisCommonSearch/headerNavigation/${MyaInputFieldSearch.compType}/inputSearch'),
                    hintText: context.lang('search_hint_text'),
                    borderRadius: kRadius8,
                    isSuccess: false,
                    controller: searchController,
                    focusNode: focusNode2,
                    autoFocus: true,
                    onTapOutside: (_) => focusNode2.unfocus(),
                    onFieldSubmitted: (String value) {
                      if (value.replaceAll(" ", "") != "") {
                        context
                            .read<SearchBloc>()
                            .add(SearchLoadEvent(searchText: value));
                        searchBloc?.add(AddHistorySearchEvent(searchText: value));
                      }
                    }),
              );
            },
          );
        },
        // Function Search Suggestion
        optionsViewBuilder: (
          BuildContext context,
          void Function(String) onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: myaColors.bgContainer,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 280,
                ),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return MyaListItemGeneral(
                          key: ValueKey(
                              'myaisCommonSearch/searchSuggestion/${MyaListItemGeneral.compType}/$index'),
                          type: MyaListItemGeneralType.secondary,
                          isDisabled: false,
                          isAlignTop: true,
                          titleText: options.toList()[index],
                          onTap: () {
                            onSelected(options.toList()[index]);
                          });
                    }),
              ),
            ),
          );
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
      onPressed: (String keyword) {
        searchBloc?.add(AddHistorySearchEvent(searchText: keyword));
      },
      onClear: () {
        searchBloc?.add(DeleteHistoryEvent());
        context.odaCore.coreEvent.dispatchEvent(
          eventName: 'SearchShowSuccessSnackbar',
          data: {
            'messageKey': 'search_alert_recent_cleared',
            'iconKey': 'iconui_general_success',
          },
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

  @override
  OdaStepInfo info() {
    return OdaStepInfo(path: path, eventListeners: [
      EventListenerInfo(
        eventName: 'goToTop',
        eventListener: (context, data) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          return false;
        },
      ),
    ]);
  }
}
