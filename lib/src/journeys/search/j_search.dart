import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart'
    show SearchFaqsUsecase;
import 'package:oda_fe_framework/oda_framework.dart';

import 'bloc/bloc.dart';

import 'steps/step.dart';
import 'package:core/utils/quick_menu_management.dart';

class JSearch extends OdaJourney {
  static const String path = '/j_search';

  @override
  List<BlocProvider<OdaBloc<ODAEvent, ODAState>>> createBlocProviders(
      BuildContext context, Map<String, dynamic>? arguments) {
    return [
      BlocProvider<SearchBloc>(
        create: (context) => SearchBloc(
          context: context,
          searchFaqsUsecase: GetIt.I.get<SearchFaqsUsecase>(),
          coreConfiguration: CoreConfiguration(),
          quickMenuManagement: QuickMenuManagement(),
          coreData: CoreData(), 
        )..add(SearchStartEvent()),
      ),
    ];
  }

  @override
  OdaJourneyInfo info() {
    return OdaJourneyInfo(
      initialStep: SearchStep0.path,
      path: path,
      steps: [SearchStep0()],
    );
  }
}
