import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_search_micro_journey/src/journeys/search/bloc/bloc.dart';

import '../../utils/util.dart';

class SearchInputField extends StatefulWidget {
  const SearchInputField({
    super.key,
    required this.onSelected,
    required this.onEmpty,
  });

  final Function(String) onSelected;
  final VoidCallback onEmpty;

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myaColors = context.myaThemeColors;

    return BlocConsumer<SearchBloc, ODAState>(
      listener: (context, state) {
        if (state is SearchStartState) {
          searchTextController.text = state.searchText;
        }
        if (state is SearchLoadingState) {
          searchTextController.text = state.searchText;
        }
      },
      buildWhen: (previous, current) =>
          previous is SearchInitialState && current is SearchStartState,
      builder: (context, state) {
        if (state is! SearchStartState) return const SizedBox.shrink();
        return RawAutocomplete<String>(
            key: SearchKeyUtil.compose(
                pageKey: 'seach',
                section: 'searchInputField',
                components: ['rawAutocomplete']),
            focusNode: focusNode,
            textEditingController: searchTextController,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              } else {
                textEditingValue.text.replaceAll('', ''.trim());
                final getMatches = state.searchKeywordList
                    .where((element) => element
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase()))
                    .toList();
                return getMatches;
              }
            },
            onSelected: (String searchText) {
              widget.onSelected(searchText);
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController searchController,
              FocusNode focusNode2,
              VoidCallback onFieldSubmitted,
            ) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        kPadding7,
                        kPadding1,
                        kPadding1,
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
                          onTapOutside: (_) => focusNode2.unfocus(),
                          onFieldSubmitted: (String searchText) {
                            if (searchText.replaceAll(" ", "") != "") {
                              widget.onSelected(searchText);
                            } else {
                              widget.onEmpty();
                            }
                          }),
                    ),
                  ),
                  BlocBuilder<SearchBloc, ODAState>(
                    buildWhen: (previous, current) => current is! SearchLoadingState,
                    builder: (context, state) {
                      if(state is! SearchSuccessState){
                        return const SizedBox(width: kPadding7);
                      }
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
                            final List<MyaBottomSheetFilterContent>
                                filterContent = [];
                            myaShowBottomSheet(
                              context: context,
                              enableDrag: true,
                              isDismissible: true,
                              widget: StatefulBuilder(
                                builder: (ctx, setState) {
                                  return MyaBottomSheetFilter(
                                    key: const ValueKey(
                                        'myaisCommonSearch/aroundYouFilter/${MyaBottomSheetFilter.compType}'),
                                    onPressedIconClose: () =>
                                        Navigator.of(context).pop(),
                                    isShowCloseIcon: true,
                                    isDragHandle: true,
                                    showStickyButton: true,
                                    stateResetButton: true,
                                    showScrollBars: true,
                                    selectButtonText: context
                                        .lang('home_search_confirm_botton'),
                                    resetButtonText: context
                                        .lang('home_search_reset_button'),
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
                    },
                  )
                ],
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
      },
    );
  }
}
