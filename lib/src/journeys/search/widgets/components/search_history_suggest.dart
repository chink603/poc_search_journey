import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_search_micro_journey/src/journeys/search/utils/util.dart';

import '../../models/models.dart';
import '../widgets.dart';

class SearchHistorySuggest extends StatelessWidget {
  const SearchHistorySuggest({
    super.key,
    required this.searchHistory,
    required this.suggestKeywords,
    required this.onPressed,
    required this.onClear,
    required this.onCancel,
  });

  final List<String> searchHistory;
  final List<String> suggestKeywords;
  final Function(String) onPressed;
  final Function() onClear;
  final Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final MyaTextStyle myaTextStyle = context.myaTextStyle;
    final MyaThemeColors myaColors = context.myaThemeColors;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: myaColors.bgBorderContainer)),
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(kPadding7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchHistory.isNotEmpty)
              Row(
                children: [
                  Text(context.lang('search_header_recent_searches'),
                      style: myaTextStyle.titleSmall
                          .copyWith(color: myaColors.textIconText)),
                  const Spacer(),
                  MyaButtonIcon(
                    iconKey: 'iconui_general_trash',
                    size: MyaButtonIconSize.small,
                    onPressed: () {
                      // final searchBloc = context.read<SearchBloc>();
                      showDialog(
                          barrierColor: myaColors.mainOverlay,
                          context: context,
                          builder: (context) {
                            return MyaModalGeneral(
                                key: const ValueKey(
                                    'myaisCommonSearch/clearRecentSearches/${MyaModalGeneral.compType}'),
                                iconKey: 'iconillus_trash',
                                titleText: CoreLanguage().getLanguageByKey(
                                    "search_popup_clear_resent"),
                                buttonText1: CoreLanguage()
                                    .getLanguageByKey("clear_all"),
                                onPressedButton1: () {
                                  // searchBloc.add(SearchClearHistoryEvent());
                                  Navigator.pop(context);
                                  onClear();
                                  // Show SnackBar with Toast

                                  // notify callback to page
                                  // rootScaffoldMessengerKey.currentState
                                  //     ?.showSnackBar(
                                  //   SnackBar(
                                  //     backgroundColor: Colors.transparent,
                                  //     elevation: 0,
                                  //     content: MyaToast(
                                  //       key: const ValueKey(
                                  //           'myaisCommonSearch/alertRecentSearchAreCleared/${MyaToast.compType}'),
                                  //       toastStyle: MyaToastStyle.success,
                                  //       prefixIcon: "iconui_general_success",
                                  //       descriptionText: CoreLanguage()
                                  //           .getLanguageByKey(
                                  //               "search_alert_recent_cleared"),
                                  //     ),
                                  //   ),
                                  // );
                                },
                                buttonText2:
                                    CoreLanguage().getLanguageByKey("cancel"),
                                onPressedButton2: () {
                                  // eventLog Cancle Delete
                                  // eventLogModalCancleDeleteRecentSearches();
                                  Navigator.pop(context);
                                  onCancel();
                                });
                          });
                      // eventLog Buttom Icon Delete
                      // eventLogButtomDeleteRecentSearches();
                    },
                  ),
                ],
              ),
            if (searchHistory.isNotEmpty) const SizedBox(height: kPadding4),
            if (searchHistory.isNotEmpty)
              ListChipFilter(
                  list: searchHistory
                      .map((e) =>
                          SearchCategoryModel(label: e, id: e, value: false))
                      .toList(),
                  onTap: (String label) {
                    onPressed(label);
                  }),
            if (searchHistory.isNotEmpty) const SizedBox(height: kPadding7),
            if (suggestKeywords.isNotEmpty)
              Text(context.lang('home_search_suggestion_title'),
                  style: myaTextStyle.titleSmall
                      .copyWith(color: myaColors.textIconText)),
            const SizedBox(height: kPadding4),
            if (suggestKeywords.isNotEmpty)
              Wrap(
                spacing: kPadding4,
                runSpacing: kPadding7,
                children: suggestKeywords
                    .map((keyword) => MyaChipFilter(
                          labelText: keyword,
                          size: MyaChipFilterSize.medium,
                          isSelected: false,
                          onPressed: () {
                            onPressed(keyword);
                          },
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
