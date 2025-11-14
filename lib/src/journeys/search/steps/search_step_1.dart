import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../bloc/bloc/search_bloc.dart';

class SearchStep0 extends OdaStep {
  static const String path = '1';
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode1 = FocusNode();

  @override
  Widget builder(BuildContext context, Map<String, dynamic>? arguments) {
    final myaColors = context.myaThemeColors;
    final coreLanguage = context.odaCore.coreLanguage;
    return Column(
      children: [
        Container(
          color: myaColors.bgContainer,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: 
                    // Container()
                    BlocConsumer<SearchBloc, ODAState>(
                        listener: (context, state) {},
                        buildWhen: (previous, current) {
                          if (current is ODALoadingState) {
                            return false;
                          }
                          return true;
                        },
                        builder: (context, state) {
                          return _buildSearchInputField(
                              myaColors, coreLanguage);
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInputField(
      MyaThemeColors myaColors, OdaCoreLanguage coreLanguage) {
    return RawAutocomplete<String>(
        textEditingController: searchController,
        focusNode: focusNode1,
        optionsBuilder: (TextEditingValue textEditingValue) {
          final value = textEditingValue.text;
          if (value == '') {
            return const Iterable<String>.empty();
          } else {
            return const <String>[];
          }
        },
        onSelected: (String selection) {},
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController searchController,
          FocusNode focusNode2,
          VoidCallback onFieldSubmitted,
        ) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              kPadding7,
              kPadding1,
              kPadding7,
              kPadding6,
            ),
            child: MyaInputFieldSearch(
                key: const ValueKey(
                    'myaisCommonSearch/headerNavigation/${MyaInputFieldSearch.compType}/inputSearch'),
                hintText: coreLanguage.getLanguageByKey('search_hint_text'),
                borderRadius: kRadius8,
                isSuccess: false,
                controller: searchController,
                focusNode: focusNode2,
                onTapOutside: (_) => focusNode2.unfocus(),
                onFieldSubmitted: (String value) {
                  if (value.replaceAll(" ", "") != "") {
                    context
                        .read<SearchBloc>()
                        .add(SearchLoadEvent(searchText: value, language: coreLanguage.currentLanguage));
                  }
                }),
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

  @override
  OdaStepInfo info() {
    return const OdaStepInfo(
      path: path,
    );
  }
}
