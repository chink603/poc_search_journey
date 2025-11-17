import 'package:flutter/foundation.dart';

class SearchKeyUtil {
  static ValueKey compose({
    required String pageKey,
    required String section,
    List<String>? components,
  }) {
    final result = <String>[pageKey, section, ...?components];
    return ValueKey(result.join('/'));
  }
}