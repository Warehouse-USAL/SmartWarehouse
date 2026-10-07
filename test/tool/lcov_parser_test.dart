import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage/lcov_parser.dart';

void main() {
  test('parses a single record counting hit and unhit lines', () {
    const lcov = '''
SF:lib/a.dart
DA:1,2
DA:2,0
DA:3,5
end_of_record
''';

    final result = parseLcov(lcov);

    expect(result, hasLength(1));
    expect(result.single.path, 'lib/a.dart');
    expect(result.single.linesFound, 3);
    expect(result.single.linesHit, 2);
  });

  test('parses multiple records', () {
    const lcov = '''
SF:lib/a.dart
DA:1,1
end_of_record
SF:lib/b.dart
DA:1,0
DA:2,0
end_of_record
''';

    final result = parseLcov(lcov);

    expect(result.map((f) => f.path), ['lib/a.dart', 'lib/b.dart']);
    expect(result[0].linesHit, 1);
    expect(result[1].linesFound, 2);
    expect(result[1].linesHit, 0);
  });

  test('ignores LF and LH summary lines rather than double counting', () {
    const lcov = '''
SF:lib/a.dart
DA:1,1
LF:1
LH:1
end_of_record
''';

    final result = parseLcov(lcov);

    expect(result.single.linesFound, 1);
    expect(result.single.linesHit, 1);
  });

  test('returns empty list for empty input', () {
    expect(parseLcov(''), isEmpty);
  });

  test('normalises Windows separators so exclude globs can match', () {
    // `flutter test --coverage` en Windows emite `SF:lib\a\b.dart`, y los
    // globs de `coverage_thresholds.yaml` estan escritos con `/`. Sin
    // normalizar acá ninguna exclusion matchea y el gate mide contra un
    // denominador inflado — en silencio, porque CI corre en Linux y ahi los
    // separadores ya vienen bien.
    const lcov = r'''
SF:lib\presentation\pages\home_page.dart
DA:1,1
end_of_record
''';

    expect(parseLcov(lcov).single.path, 'lib/presentation/pages/home_page.dart');
  });
}
