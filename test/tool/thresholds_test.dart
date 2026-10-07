import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage/thresholds.dart';

const _yaml = '''
defaults:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

packages:
  core:
    path: packages/core
    min: 85
  commons:
    path: packages/commons
    min: 85
    exclude:
      - "lib/helpers/http/dio_http_helper.dart"
''';

void main() {
  test('parses default exclusions', () {
    final config = ThresholdConfig.parse(_yaml);

    expect(config.defaultExclude, ['**/*.g.dart', '**/*.freezed.dart']);
  });

  test('parses each package with name, path and min', () {
    final config = ThresholdConfig.parse(_yaml);

    expect(config.packages.map((p) => p.name), ['core', 'commons']);
    final core = config.packages.firstWhere((p) => p.name == 'core');
    expect(core.path, 'packages/core');
    expect(core.min, 85);
  });

  test('a package without exclude gets an empty list, not null', () {
    final config = ThresholdConfig.parse(_yaml);

    final core = config.packages.firstWhere((p) => p.name == 'core');
    expect(core.exclude, isEmpty);
  });

  test('package specific exclusions are parsed', () {
    final config = ThresholdConfig.parse(_yaml);

    final commons = config.packages.firstWhere((p) => p.name == 'commons');
    expect(commons.exclude, ['lib/helpers/http/dio_http_helper.dart']);
  });

  test('effectiveExclude merges defaults with package specific patterns', () {
    final config = ThresholdConfig.parse(_yaml);

    final commons = config.packages.firstWhere((p) => p.name == 'commons');
    expect(
      config.effectiveExclude(commons),
      containsAll(<String>[
        '**/*.g.dart',
        '**/*.freezed.dart',
        'lib/helpers/http/dio_http_helper.dart',
      ]),
    );
  });

  test('missing packages section yields an empty package list', () {
    final config = ThresholdConfig.parse('defaults:\n  exclude: []\n');

    expect(config.packages, isEmpty);
  });
}
