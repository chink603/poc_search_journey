class ConfigLang {
 static final Map<String, String> _values = {};
 
 static Map<String, String> get values => _values;

 static set values(Map<String, String> value) {
  _values.clear();
  _values.addAll(value);
 }

 static void clear() {
  _values.clear();
 }

 static String get searchTitle => _values['search_title'] ?? 'search_title_search';

 static String get buttonGoToTop => _values['button_go_to_top'] ?? 'search_button_go_to_top';

}
