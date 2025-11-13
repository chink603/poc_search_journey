import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_search_micro_journey/src/journey_experience/search/search_experience.dart';

class SearchPage extends OdaPage {
  static const String path = '${SearchExperience.path}/search_page';
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final ValueNotifier<bool> _isButtonVisible = ValueNotifier<bool>(false);
  final ScrollController _scrollControllerList = ScrollController();

  @override
  Widget builder(BuildContext context, Map<String, dynamic>? arguments) {
    final MyaThemeColors myaColors = context.myaThemeColors;
    final coreLanguage = context.odaCore.coreLanguage;

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: NotificationListener(
        onNotification: (ScrollNotification notification) {
          _isButtonVisible.value =
              notification.metrics.atEdge && notification.metrics.pixels <= 0;
          return false;
        },
        child: Scaffold(
          backgroundColor: myaColors.bgContainer,
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(69),
            child: ValueListenableBuilder<bool>(
                valueListenable: _isButtonVisible,
                builder: (context, value, child) {
                  return MyaHeaderNav(
                    key: const ValueKey(
                        'myaisCommonSearch/headerNavigation/${MyaHeaderNav.compType}'),
                    isLeading: true,
                    isBackground: _isButtonVisible.value,
                    onTapLeading: () {},
                    headerText:
                        coreLanguage.getLanguageByKey('search_title_search'),
                    trailingActions: [
                      if (value)
                        MyaButton(
                          key: const ValueKey(
                              'myaisCommonSearch/headerNavigation/${MyaButton.compType}/goToTop'),
                          label: coreLanguage
                              .getLanguageByKey("search_button_go_to_top"),
                          theme: MyaButtonTheme.primary,
                          style: MyaButtonStyle.text,
                          size: MyaButtonSize.large,
                          suffixIconKey: 'iconui_general_arrow_up',
                          onPressed: () async {
                            await _scrollControllerList.animateTo(
                              0.0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                        )
                    ],
                    isDivider: false,
                  );
                }),
          ),
          body: Container(
            color: myaColors.bgBg,
            child: SafeArea(
                child: ListView(
              controller: _scrollControllerList,
              children: [
                context.odaCore.coreUI.createJourney(
                  'j_search_everything',
                  callbackAction: (payload) {
                    // message delete history
                    // go to search route everything
                  },
                )
              ],
            )),
          ),
        ),
      ),
    );
  }

  @override
  OdaPageInfo info() {
    return const OdaPageInfo(
      path: path,
    );
  }
}
