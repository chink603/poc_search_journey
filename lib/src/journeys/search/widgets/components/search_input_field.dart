import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';

import '../../bloc/bloc.dart';
import '../../utils/util.dart';

class SearchInputField extends StatefulWidget {
  const SearchInputField({
    super.key,
    required this.searchKeywordList,
    required this.onSelected,
  });

  final List<String> searchKeywordList;
  final Function(String) onSelected;

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  List<String> _searchKeywordList = [];
  @override
  void initState() {
    super.initState();
    _searchKeywordList = widget.searchKeywordList;
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
            final getMatches = _searchKeywordList
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
                    onTapOutside: (_) => focusNode2.unfocus(),
                    onFieldSubmitted: (String searchText) {
                      if (searchText.replaceAll(" ", "") != "") {
                        widget.onSelected(searchText);
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
}
