import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage/report.dart';
import '../../tool/coverage/thresholds.dart';

const _package = PackageThreshold(
  name: 'commons',
  path: 'packages/commons',
  min: 85,
  exclude: [],
);

void main() {
  test('a missing lcov report scores zero and fails, it is not skipped', () {
    final result = buildResult(
      package: _package,
      exclude: const [],
      lcovContent: null,
    );

    expect(result.hasReport, isFalse);
    expect(result.percent, 0);
    expect(result.passes, isFalse);
  });

  test('generated files are stripped from the denominator', () {
    const lcov = '''
SF:lib/a.dart
DA:1,1
DA:2,0
end_of_record
SF:lib/a.g.dart
DA:1,0
DA:2,0
DA:3,0
DA:4,0
end_of_record
''';

    final result = buildResult(
      package: _package,
      exclude: const ['**/*.g.dart'],
      lcovContent: lcov,
    );

    expect(result.linesFound, 2);
    expect(result.linesHit, 1);
    expect(result.percent, 50);
  });

  test('package specific exclusions are applied', () {
    const lcov = '''
SF:lib/helpers/http/dio_http_helper.dart
DA:1,0
DA:2,0
end_of_record
SF:lib/utils/date_time_utils.dart
DA:1,1
DA:2,1
end_of_record
''';

    final result = buildResult(
      package: _package,
      exclude: const ['lib/helpers/http/dio_http_helper.dart'],
      lcovContent: lcov,
    );

    expect(result.linesFound, 2);
    expect(result.percent, 100);
  });

  test('passes when percent is at or above the floor', () {
    const lcov = '''
SF:lib/a.dart
DA:1,1
DA:2,1
DA:3,1
DA:4,1
DA:5,0
end_of_record
''';

    final result = buildResult(
      package: _package,
      exclude: const [],
      lcovContent: lcov,
    );

    expect(result.percent, 80);
    expect(result.passes, isFalse);

    final lower = buildResult(
      package: const PackageThreshold(
        name: 'commons',
        path: 'packages/commons',
        min: 80,
        exclude: [],
      ),
      exclude: const [],
      lcovContent: lcov,
    );
    expect(lower.passes, isTrue);
  });

  test('a report where everything is excluded scores zero rather than dividing by zero', () {
    const lcov = '''
SF:lib/a.g.dart
DA:1,1
end_of_record
''';

    final result = buildResult(
      package: _package,
      exclude: const ['**/*.g.dart'],
      lcovContent: lcov,
    );

    expect(result.linesFound, 0);
    expect(result.percent, 0);
  });
}
