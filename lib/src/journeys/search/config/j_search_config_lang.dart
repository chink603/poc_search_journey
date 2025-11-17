class JSearchConfigLang {
 static final Map<String, String> _values = {};
 
 static Map<String, String> get values => _values;

 static set values(Map<String, String> value) {
  _values.clear();
  _values.addAll(value);
 }

 static void clear() {
  _values.clear();
 }

 static String get titleSearch => _values['title_search'] ?? '';

 static String get placeholderSearch => _values['placeholder_search'] ?? '';

 static String get buttonSearch => _values['button_search'] ?? '';
}
