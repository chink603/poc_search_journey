import 'package:get_it/get_it.dart';
import 'package:oda_data_tmf658_loyalty_management/domain/domain.dart';
import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart';
import 'package:oda_presentation_universal/domain/customer_domain/usecase/get_assets_list_realm_usecase.dart';
import 'package:oda_presentation_universal/utils/smart_search.dart';

final _locator = GetIt.I;

void searchInject() {
  if (!_locator.isRegistered<SearchFaqsUsecase>()) {
    _locator.registerFactory(() => SearchFaqsUsecase(repository: _locator()));
  }
  if (!_locator.isRegistered<SmartSearch>()) {
    _locator.registerFactory(() => SmartSearch());
  }
  if (!_locator.isRegistered<SearchLoyaltyUsecase>()) {
    _locator.registerFactory(() => SearchLoyaltyUsecase(searchLoyaltyRepository: _locator()));
  }
  if (!_locator.isRegistered<GetLoyaltyCategoryConfigUseCase>()) {
    _locator.registerFactory(() => GetLoyaltyCategoryConfigUseCase());
  }
  if (!_locator.isRegistered<GetAssetsListRealmUsecase>()) {
    _locator.registerFactory(() => GetAssetsListRealmUsecase(repository: _locator()));
  }
  
}
