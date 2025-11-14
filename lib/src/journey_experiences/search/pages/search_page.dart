import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';

class SearchPage extends OdaPage {
  static const String path = 'search_page';
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final ValueNotifier<bool> _isButtonVisible = ValueNotifier<bool>(false);
  final ScrollController _scrollControllerList = ScrollController();

  // @override
  // void dispose() {
  //   _isButtonVisible.dispose();
  //   _scrollControllerList.dispose();
  //   super.dispose();
  // }

  @override
  Widget builder(BuildContext context, Map<String, dynamic>? arguments) {
    final myaColors = context.myaThemeColors;
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
                    onTapLeading: () {
                      context.odaCore.coreNavigator.exitJourneyExp();
                    },
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
              physics: const ClampingScrollPhysics(),
              children: [
                context.odaCore.coreUI.createJourney(
                  '/j_search',
                  callbackAction: (payload) {
                    // message delete history
                    // go to search route everything
                    // emit event test
                    context.odaCore.coreEvent.dispatchEvent(eventName: 'test');
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
    return OdaPageInfo(
      path: path,
      eventListeners: [
        EventListenerInfo(
            eventName: 'test',
            eventListener: (context, data) {
              context.odaCore.coreLog.debug('message $data');
              return false;
            })
      ],
    );
  }
}
