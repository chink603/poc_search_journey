import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';

import '../config/je_search_config_lang.dart';
import '../utils/util.dart';

class SearchPage extends OdaPage {
  static const String path = 'search_page';
  final String pageKey = 'myaisCommonSearch';
  final String section = 'headerNavigation';
  final String jPath = '/j_search';
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final ValueNotifier<bool> _isButtonVisible = ValueNotifier<bool>(false);

  @override
  void dispose() {
    ConfigLang.clear();
    super.dispose();
  }

  @override
  Widget builder(BuildContext context, Map<String, dynamic>? arguments) {
    final myaColors = context.myaThemeColors;
    ConfigLang.values = arguments?['configLang'] ?? {};
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
              context.odaCore.coreNavigator.exitJourneyExp();
            },
            headerText: context.lang(ConfigLang.searchTitle),
            trailingActions: [
              // if (value)
              ValueListenableBuilder<bool>(
                  valueListenable: _isButtonVisible,
                  builder: (context, value, child) {
                    if (!value) return const SizedBox.shrink();
                    return MyaButton(
                      key: SearchKeyUtil.compose(
                          pageKey: pageKey,
                          section: section,
                          components: [MyaButton.compType, 'goToTop']),
                      label: context.lang(ConfigLang.buttonGoToTop),
                      theme: MyaButtonTheme.primary,
                      style: MyaButtonStyle.text,
                      size: MyaButtonSize.large,
                      suffixIconKey: 'iconui_general_arrow_up',
                      onPressed: () async {
                        context.odaCore.coreEvent
                            .dispatchEvent(eventName: 'goToTop');
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
                child: context.odaCore.coreUI.createJourney(
                  jPath,
                  arguments: {
                    'routeName': 'PRIVILEGE',
                  },
                )),
          ),
        ));
  }

  @override
  OdaPageInfo info() {
    return OdaPageInfo(path: path, eventListeners: [
      EventListenerInfo(
        eventName: 'SearchShowSuccessSnackbar',
        eventListener: (context, data) {
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
                prefixIcon: data['iconKey'],
                descriptionText: context.lang(data['messageKey'] ?? '').langEmpty,
              ),
            ),
          );
          return false;
        },
      ),
    ]);
  }
}
