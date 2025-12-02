import 'package:oda_fe_framework/oda_framework.dart';


import 'steps/step.dart';

class JourneySearch extends OdaJourney {
  static const String path = '/j_search';

  @override
  OdaJourneyInfo info() {
    return OdaJourneyInfo(
      initialStep: SearchStep0.path,
      path: path,
      steps: [SearchStep0()],
    );
  }
}
