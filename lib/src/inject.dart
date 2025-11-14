import 'package:get_it/get_it.dart';
import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart';

final _locator = GetIt.I;

void searchInject() {
  if (!_locator.isRegistered<SearchFaqsUsecase>()) {
    _locator.registerFactory(() => SearchFaqsUsecase(repository: _locator()));
  }
}
