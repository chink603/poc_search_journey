import 'package:core/utils/ntype_management/ntype_management.dart';
import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart'
    show SearchFaqsUsecase;
import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_presentation_universal/domain/customer_domain/usecase/get_assets_list_realm_usecase.dart';

import 'bloc/bloc.dart';

import 'steps/step.dart';
import 'package:core/utils/quick_menu_management.dart';

class JourneySearch extends OdaJourney {
  static const String path = '/j_search';

  @override
  List<BlocProvider<OdaBloc<ODAEvent, ODAState>>> createBlocProviders(
      BuildContext context, Map<String, dynamic>? arguments) {
    return [
      BlocProvider<SearchBloc>(
        create: (context) => SearchBloc(
          context: context,
          useCaseSearchFaq: GetIt.I.get<SearchFaqsUsecase>(),
          useCaseAssetListRealm: GetIt.I.get<GetAssetsListRealmUsecase>(),
          coreConfiguration: CoreConfiguration(),
          quickMenuManagement: QuickMenuManagement(),
          ntypeManagement: NTypeManagement(),
          coreData: CoreData(), 
          coreLanguage: context.odaCore.coreLanguage,
          routeName: arguments?['routeName'] ?? '',
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
