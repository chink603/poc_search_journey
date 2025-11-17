import 'package:oda_fe_framework/oda_framework.dart';

extension ContextLangExtension on BuildContext {
  String lang(String key) => odaCore.coreLanguage.getLanguageByKey(key);
}

extension SearchKeyExtension on Key {
  ValueKey composeKey(
      {required String pageKey,
      required String section,
      List<String>? components}) {
    List<String> result = [pageKey, section];
    result.addAll(components ?? []);
    return ValueKey(result.join('/'));
  }
}
