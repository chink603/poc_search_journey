import 'package:oda_fe_framework/oda_framework.dart';

import 'pages/pages.dart';

class JeSearch extends OdaJourneyExp {
  static const String path = '/je_search';
  @override
  OdaJourneyExpInfo info() {
    return OdaJourneyExpInfo(
        initialPage: SearchPage.path,
        pages: [SearchPage()],
        path: path,
        routeStyle: RouteStyle.material);
  }
}
