class JSearchConfig {
 static final Map<String, String> _values = {};
 
 static Map<String, String> get values => _values;

 static set values(Map<String, String> value) {
  _values.clear();
  _values.addAll(value);
 }

 static void clear() {
  _values.clear();
 }

 static String get titleSearch => _values['search_title'] ?? 'search_title_search';
 static String get buttonGoToTop => _values['search_button_go_to_top'] ?? 'search_button_go_to_top';

 static String get placeholderSearch => _values['search_placeholder'] ?? 'search_hint_text';

 static String get buttonSearch => _values['search_button_search'] ?? 'search_button_search';
}
