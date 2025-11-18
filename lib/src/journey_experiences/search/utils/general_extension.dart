import 'package:oda_fe_framework/oda_framework.dart';

extension ContextLangExtension on BuildContext {
  String lang(String key) => odaCore.coreLanguage.getLanguageByKey(key);
}

extension StringNullExtension on String {
  String? get langEmpty => isEmpty ? null : this;
}
