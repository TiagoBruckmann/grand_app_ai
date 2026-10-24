import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/core/i18n/app_i18n.dart';

void main() {
  Set<String> flattenKeys(Map<String, Object?> map, [String prefix = '']) => {
    for (final MapEntry(:key, :value) in map.entries)
      ...switch (value) {
        final Map<String, Object?> nested => flattenKeys(
          nested,
          '$prefix$key.',
        ),
        _ => {'$prefix$key'},
      },
  };

  Set<String> keysOf(String languageCode) {
    final file = File('${AppI18n.basePath}/$languageCode.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    return flattenKeys(json);
  }

  test('every supported locale has the same translation keys', () {
    final english = keysOf('en');

    for (final locale in AppI18n.supportedLocales) {
      expect(keysOf(locale.languageCode), english, reason: '$locale.json');
    }
  });
}
