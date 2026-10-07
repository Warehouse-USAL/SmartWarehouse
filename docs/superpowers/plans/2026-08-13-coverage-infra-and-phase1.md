# Coverage Infrastructure + Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a per-package coverage gate enforced in CI, then bring `commons`, `token_repository` and `core` up to their thresholds.

**Architecture:** A Dart CLI (`tool/check_coverage.dart`) parses each package's `lcov.info`, strips generated and excluded files, and compares the result against per-package floors declared in `coverage_thresholds.yaml`. A companion generator (`tool/gen_coverage_imports.dart`) writes a throwaway test into every package that imports all of `lib/`, so files with no tests land in the denominator at 0% instead of vanishing from the report. Melos runs both; CI runs melos.

**Tech Stack:** Dart 3.11.5, Flutter 3.41.9, melos 6.2.0, `mocktail`, `bloc_test`, `yaml`, lcov tracefiles, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-08-12-test-strategy-design.md`

**Scope:** This plan covers Phase 0 (infrastructure) and Phase 1 (`commons`, `token_repository`, `core`) from §7.3 of the spec. Phases 2–3 get their own plans, written once `test_support`'s API exists rather than guessed at.

**Not in this plan:** spec §9 (rewriting epic #129, filling in #130, creating the E8.2.x sub-issues, populating the wh-mobile board). That is GitHub bookkeeping done with `gh`, not code, and it is tracked separately. Task 20 only opens the PR that closes #130.

## Global Constraints

- Dart SDK constraint for all packages: `'>=3.8.0 <4.0.0'`
- Branch names must match `^(feature|fix|enhancement|refactor|hotfix|beta|backport|dependabot)/` — CI rejects anything else
- Use this branch: `feature/e8.2-phase0-coverage-infra`
- Coverage denominator **always** excludes `**/*.g.dart` and `**/*.freezed.dart`
- A missing `lcov.info` counts as **0%**, never as skip
- Thresholds ratchet: floors only ever increase
- Commit messages follow the repo convention: `type(scope): subject`, lowercase, Spanish subject
- `melos bootstrap` must have been run before any `flutter test` invocation
- Package thresholds (spec §5): `commons` 85, `token_repository` 85, `core` 85, features 80, `bottom_navigation_bar` 60, `design_system` 40, app shell and `test_support` excluded

---

## File Structure

**Created:**
- `tool/coverage/lcov_parser.dart` — parse an lcov tracefile into per-file line counts. No I/O.
- `tool/coverage/patterns.dart` — glob matching for exclusion patterns. No I/O.
- `tool/coverage/thresholds.dart` — parse `coverage_thresholds.yaml` into typed config. No I/O.
- `tool/coverage/report.dart` — combine parser + patterns + config into per-package results. No I/O.
- `tool/check_coverage.dart` — CLI entrypoint; the only file that touches the filesystem.
- `tool/gen_coverage_imports.dart` — generator for the all-imports test file.
- `coverage_thresholds.yaml` — the floors, at repo root.
- `packages/test_support/` — shared test helpers.
- `test/tool/*_test.dart` — tests for the tooling itself.

**Modified:**
- `melos.yaml` — fix the `test` script, add `test:coverage`.
- `.github/workflows/ci.yml` — add the `coverage` job.
- `pubspec.yaml` (root) — add `yaml` and `args` to dev_dependencies.
- `.gitignore` — ignore generated coverage artifacts.
- Every package's `pubspec.yaml` — add `mocktail` and `bloc_test`.
- `docs/ARCHITECTURE.md` §18 — rewrite to match this strategy.

The four files under `tool/coverage/` are pure functions with no I/O, which is what makes the tooling testable. `check_coverage.dart` is the only place that reads files.

---

## Task 1: lcov parser

**Files:**
- Create: `tool/coverage/lcov_parser.dart`
- Test: `test/tool/lcov_parser_test.dart`

**Interfaces:**
- Consumes: nothing
- Produces: `class FileCoverage { final String path; final int linesFound; final int linesHit; }` and `List<FileCoverage> parseLcov(String content)`

- [ ] **Step 1: Write the failing test**

Create `test/tool/lcov_parser_test.dart`:

```dart
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/tool/lcov_parser_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package` / file not found for `lcov_parser.dart`

- [ ] **Step 3: Write minimal implementation**

Create `tool/coverage/lcov_parser.dart`:

```dart
/// Line coverage for a single source file, as reported by an lcov tracefile.
class FileCoverage {
  const FileCoverage({
    required this.path,
    required this.linesFound,
    required this.linesHit,
  });

  /// Path as it appears in the `SF:` line — relative to the package root.
  final String path;
  final int linesFound;
  final int linesHit;
}

/// Parses an lcov tracefile.
///
/// Only `SF:` and `DA:` lines are read. `LF:`/`LH:` summary lines are ignored
/// on purpose: after exclusions are applied the totals have to be recomputed
/// from the surviving `DA:` lines anyway.
List<FileCoverage> parseLcov(String content) {
  final files = <FileCoverage>[];
  String? path;
  var found = 0;
  var hit = 0;

  void flush() {
    if (path != null) {
      files.add(FileCoverage(path: path!, linesFound: found, linesHit: hit));
    }
    path = null;
    found = 0;
    hit = 0;
  }

  for (final line in content.split('\n')) {
    if (line.startsWith('SF:')) {
      flush();
      path = line.substring(3).trim();
    } else if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length < 2) continue;
      final hits = int.tryParse(parts[1].trim());
      if (hits == null) continue;
      found++;
      if (hits > 0) hit++;
    } else if (line.startsWith('end_of_record')) {
      flush();
    }
  }
  flush();

  return files;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/tool/lcov_parser_test.dart`
Expected: PASS — 4 tests

- [ ] **Step 5: Commit**

```bash
git add tool/coverage/lcov_parser.dart test/tool/lcov_parser_test.dart
git commit -m "test(tool): parser de lcov con tests"
```

---

## Task 2: Exclusion pattern matching

**Files:**
- Create: `tool/coverage/patterns.dart`
- Test: `test/tool/patterns_test.dart`

**Interfaces:**
- Consumes: nothing
- Produces: `bool matchesPattern(String path, String pattern)` and `bool matchesAny(String path, List<String> patterns)`

- [ ] **Step 1: Write the failing test**

Create `test/tool/patterns_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage/patterns.dart';

void main() {
  group('matchesPattern', () {
    test('matches generated files at any depth', () {
      expect(matchesPattern('lib/a.g.dart', '**/*.g.dart'), isTrue);
      expect(matchesPattern('lib/src/data/dtos/product_dto.g.dart', '**/*.g.dart'), isTrue);
      expect(matchesPattern('lib/src/product.freezed.dart', '**/*.freezed.dart'), isTrue);
    });

    test('does not match non-generated files', () {
      expect(matchesPattern('lib/src/product.dart', '**/*.g.dart'), isFalse);
      expect(matchesPattern('lib/src/gadget.dart', '**/*.g.dart'), isFalse);
    });

    test('matches an exact path', () {
      const p = 'lib/helpers/http/dio_http_helper.dart';
      expect(matchesPattern(p, p), isTrue);
      expect(matchesPattern('lib/helpers/http/http_helper.dart', p), isFalse);
    });

    test('single star does not cross directory separators', () {
      expect(matchesPattern('lib/a.dart', 'lib/*.dart'), isTrue);
      expect(matchesPattern('lib/src/a.dart', 'lib/*.dart'), isFalse);
    });

    test('dots are literal, not wildcards', () {
      expect(matchesPattern('lib/axg.dart', '**/*.g.dart'), isFalse);
    });
  });

  group('matchesAny', () {
    test('is true when any pattern matches', () {
      expect(matchesAny('lib/a.g.dart', ['**/*.freezed.dart', '**/*.g.dart']), isTrue);
    });

    test('is false when none match', () {
      expect(matchesAny('lib/a.dart', ['**/*.freezed.dart', '**/*.g.dart']), isFalse);
    });

    test('is false for an empty pattern list', () {
      expect(matchesAny('lib/a.dart', const []), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/tool/patterns_test.dart`
Expected: FAIL — `patterns.dart` does not exist

- [ ] **Step 3: Write minimal implementation**

Create `tool/coverage/patterns.dart`:

```dart
/// Matches a path against a glob pattern.
///
/// Supported syntax:
/// - `**/` — zero or more leading directories
/// - `**`  — anything, including separators
/// - `*`   — anything except a separator
///
/// Every other character is literal, so `.` in `*.g.dart` matches only a dot.
bool matchesPattern(String path, String pattern) {
  final escaped = RegExp.escape(pattern);
  final source = escaped
      .replaceAll(r'\*\*/', '(?:.*/)?')
      .replaceAll(r'\*\*', '.*')
      .replaceAll(r'\*', '[^/]*');
  return RegExp('^$source\$').hasMatch(path);
}

bool matchesAny(String path, List<String> patterns) =>
    patterns.any((p) => matchesPattern(path, p));
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/tool/patterns_test.dart`
Expected: PASS — 8 tests

- [ ] **Step 5: Commit**

```bash
git add tool/coverage/patterns.dart test/tool/patterns_test.dart
git commit -m "test(tool): matcher de patrones de exclusion"
```

---

## Task 3: Threshold config

**Files:**
- Create: `tool/coverage/thresholds.dart`
- Modify: `pubspec.yaml` (root) — add `yaml` and `args` to dev_dependencies
- Test: `test/tool/thresholds_test.dart`

**Interfaces:**
- Consumes: nothing
- Produces:
  - `class PackageThreshold { final String name; final String path; final int min; final List<String> exclude; }`
  - `class ThresholdConfig { final List<String> defaultExclude; final List<PackageThreshold> packages; factory ThresholdConfig.parse(String yamlSource); }`

- [ ] **Step 1: Add the yaml and args dependencies**

In root `pubspec.yaml`, under `dev_dependencies:`, after the `melos: ^6.2.0` line, add:

```yaml
  yaml: ^3.1.2
  args: ^2.6.0
```

Run: `flutter pub get`

- [ ] **Step 2: Write the failing test**

Create `test/tool/thresholds_test.dart`:

```dart
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
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/tool/thresholds_test.dart`
Expected: FAIL — `thresholds.dart` does not exist

- [ ] **Step 4: Write minimal implementation**

Create `tool/coverage/thresholds.dart`:

```dart
import 'package:yaml/yaml.dart';

/// Coverage floor for one package.
class PackageThreshold {
  const PackageThreshold({
    required this.name,
    required this.path,
    required this.min,
    required this.exclude,
  });

  /// Key used in `coverage_thresholds.yaml`.
  final String name;

  /// Path to the package, relative to the repo root.
  final String path;

  /// Minimum line coverage percentage, as a whole number.
  final int min;

  /// Exclusion patterns specific to this package.
  final List<String> exclude;
}

/// Typed view over `coverage_thresholds.yaml`.
class ThresholdConfig {
  const ThresholdConfig({
    required this.defaultExclude,
    required this.packages,
  });

  factory ThresholdConfig.parse(String yamlSource) {
    final doc = loadYaml(yamlSource);
    if (doc is! YamlMap) {
      return const ThresholdConfig(defaultExclude: [], packages: []);
    }

    final defaults = doc['defaults'];
    final defaultExclude = <String>[
      if (defaults is YamlMap && defaults['exclude'] is YamlList)
        ...(defaults['exclude'] as YamlList).map((e) => e.toString()),
    ];

    final packages = <PackageThreshold>[];
    final rawPackages = doc['packages'];
    if (rawPackages is YamlMap) {
      rawPackages.forEach((key, value) {
        if (value is! YamlMap) return;
        packages.add(
          PackageThreshold(
            name: key.toString(),
            path: value['path'].toString(),
            min: int.parse(value['min'].toString()),
            exclude: <String>[
              if (value['exclude'] is YamlList)
                ...(value['exclude'] as YamlList).map((e) => e.toString()),
            ],
          ),
        );
      });
    }

    return ThresholdConfig(
      defaultExclude: defaultExclude,
      packages: packages,
    );
  }

  final List<String> defaultExclude;
  final List<PackageThreshold> packages;

  /// Every pattern that applies to [package]: the global defaults plus its own.
  List<String> effectiveExclude(PackageThreshold package) =>
      [...defaultExclude, ...package.exclude];
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/tool/thresholds_test.dart`
Expected: PASS — 6 tests

- [ ] **Step 6: Commit**

```bash
git add tool/coverage/thresholds.dart test/tool/thresholds_test.dart pubspec.yaml pubspec.lock
git commit -m "test(tool): config tipada de umbrales de cobertura"
```

---

## Task 4: Coverage report aggregation

This is the task that encodes the two bugs from spec §1: generated files must not count, and a package with no report scores 0 rather than being skipped.

**Files:**
- Create: `tool/coverage/report.dart`
- Test: `test/tool/report_test.dart`

**Interfaces:**
- Consumes: `FileCoverage`/`parseLcov` (Task 1), `matchesAny` (Task 2), `PackageThreshold`/`ThresholdConfig` (Task 3)
- Produces:
  - `class PackageResult { final String name; final int linesFound; final int linesHit; final int min; final bool hasReport; double get percent; bool get passes; }`
  - `PackageResult buildResult({required PackageThreshold package, required List<String> exclude, required String? lcovContent})`

- [ ] **Step 1: Write the failing test**

Create `test/tool/report_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/tool/report_test.dart`
Expected: FAIL — `report.dart` does not exist

- [ ] **Step 3: Write minimal implementation**

Create `tool/coverage/report.dart`:

```dart
import 'lcov_parser.dart';
import 'patterns.dart';
import 'thresholds.dart';

/// Coverage outcome for one package, after exclusions.
class PackageResult {
  const PackageResult({
    required this.name,
    required this.linesFound,
    required this.linesHit,
    required this.min,
    required this.hasReport,
  });

  final String name;
  final int linesFound;
  final int linesHit;
  final int min;

  /// False when the package produced no `lcov.info` at all — which scores 0,
  /// never a skip. A package with no tests must not pass silently.
  final bool hasReport;

  double get percent {
    if (linesFound == 0) return 0;
    return linesHit * 100 / linesFound;
  }

  bool get passes => percent >= min;
}

/// Computes the coverage result for one package.
///
/// [lcovContent] is null when the package produced no report.
PackageResult buildResult({
  required PackageThreshold package,
  required List<String> exclude,
  required String? lcovContent,
}) {
  if (lcovContent == null) {
    return PackageResult(
      name: package.name,
      linesFound: 0,
      linesHit: 0,
      min: package.min,
      hasReport: false,
    );
  }

  var found = 0;
  var hit = 0;
  for (final file in parseLcov(lcovContent)) {
    if (matchesAny(file.path, exclude)) continue;
    found += file.linesFound;
    hit += file.linesHit;
  }

  return PackageResult(
    name: package.name,
    linesFound: found,
    linesHit: hit,
    min: package.min,
    hasReport: true,
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/tool/report_test.dart`
Expected: PASS — 5 tests

- [ ] **Step 5: Commit**

```bash
git add tool/coverage/report.dart test/tool/report_test.dart
git commit -m "test(tool): agregacion de cobertura con exclusiones y reporte faltante"
```

---

## Task 5: CLI entrypoint

**Files:**
- Create: `tool/check_coverage.dart`

**Interfaces:**
- Consumes: `ThresholdConfig` (Task 3), `buildResult`/`PackageResult` (Task 4)
- Produces: an executable run as `dart run tool/check_coverage.dart [--update]`. Exit code 0 when every package passes, 1 otherwise.

- [ ] **Step 1: Write the CLI**

Create `tool/check_coverage.dart`:

```dart
import 'dart:io';

import 'package:args/args.dart';

import 'coverage/report.dart';
import 'coverage/thresholds.dart';

const _configPath = 'coverage_thresholds.yaml';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag(
      'update',
      negatable: false,
      help: 'Rewrite each floor in coverage_thresholds.yaml to the measured '
          'value. Raising a floor should be a reviewable diff.',
    );
  final options = parser.parse(args);

  final configFile = File(_configPath);
  if (!configFile.existsSync()) {
    stderr.writeln('No se encontro $_configPath en ${Directory.current.path}');
    exit(1);
  }

  final config = ThresholdConfig.parse(configFile.readAsStringSync());
  final results = <PackageResult>[];

  for (final package in config.packages) {
    final lcov = File('${package.path}/coverage/lcov.info');
    results.add(
      buildResult(
        package: package,
        exclude: config.effectiveExclude(package),
        lcovContent: lcov.existsSync() ? lcov.readAsStringSync() : null,
      ),
    );
  }

  _printTable(results);

  if (options['update'] as bool) {
    _updateFloors(configFile, results);
    stdout.writeln('\nFloors actualizados en $_configPath.');
    exit(0);
  }

  final failed = results.where((r) => !r.passes).toList();
  if (failed.isEmpty) {
    stdout.writeln('\nTodos los packages estan en o por encima de su floor.');
    exit(0);
  }

  stderr.writeln('\n${failed.length} package(s) por debajo del floor:');
  for (final r in failed) {
    final detail = r.hasReport
        ? '${r.percent.toStringAsFixed(1)}% < ${r.min}%'
        : 'sin coverage/lcov.info (cuenta como 0%)';
    stderr.writeln('  - ${r.name}: $detail');
  }
  exit(1);
}

void _printTable(List<PackageResult> results) {
  final nameWidth = results
      .map((r) => r.name.length)
      .fold<int>('PACKAGE'.length, (a, b) => a > b ? a : b);

  stdout.writeln(
    '${'PACKAGE'.padRight(nameWidth)}  ${'COV'.padLeft(7)}  '
    '${'FLOOR'.padLeft(5)}  ${'LINES'.padLeft(11)}  STATUS',
  );

  for (final r in results) {
    final cov = '${r.percent.toStringAsFixed(1)}%'.padLeft(7);
    final floor = '${r.min}%'.padLeft(5);
    final lines = '${r.linesHit}/${r.linesFound}'.padLeft(11);
    final status = r.passes ? 'OK' : (r.hasReport ? 'FAIL' : 'SIN REPORTE');
    stdout.writeln('${r.name.padRight(nameWidth)}  $cov  $floor  $lines  $status');
  }
}

/// Rewrites the `min:` value of each package in place.
///
/// Only the numeric literal on a `min:` line is touched, so comments and
/// exclusion lists in the file survive untouched.
void _updateFloors(File configFile, List<PackageResult> results) {
  final byName = {for (final r in results) r.name: r};
  final lines = configFile.readAsLinesSync();
  final output = <String>[];

  String? currentPackage;
  final packageKey = RegExp(r'^  ([A-Za-z0-9_]+):\s*$');
  final minKey = RegExp(r'^(\s*min:\s*)(\d+)\s*$');

  for (final line in lines) {
    final packageMatch = packageKey.firstMatch(line);
    if (packageMatch != null) {
      currentPackage = packageMatch.group(1);
      output.add(line);
      continue;
    }

    final minMatch = minKey.firstMatch(line);
    if (minMatch != null && currentPackage != null) {
      final result = byName[currentPackage];
      if (result != null) {
        output.add('${minMatch.group(1)}${result.percent.floor()}');
        continue;
      }
    }

    output.add(line);
  }

  configFile.writeAsStringSync('${output.join('\n')}\n');
}
```

- [ ] **Step 2: Verify it fails cleanly with no config present**

Run: `dart run tool/check_coverage.dart`
Expected: exits 1 with `No se encontro coverage_thresholds.yaml` — the config arrives in Task 8.

- [ ] **Step 3: Commit**

```bash
git add tool/check_coverage.dart
git commit -m "feat(tool): CLI de chequeo de cobertura con flag --update"
```

---

## Task 6: All-imports generator

Without this, a file that no test imports never appears in `lcov.info` and therefore never lowers the percentage. This is what makes the denominator honest.

**Files:**
- Create: `tool/gen_coverage_imports.dart`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: nothing
- Produces: writes `test/_coverage_imports_test.dart` into every package listed in `coverage_thresholds.yaml`. Side effect: every package ends up with a `test/` directory, so `melos exec -- flutter test` no longer skips any package.

- [ ] **Step 1: Write the generator**

Create `tool/gen_coverage_imports.dart`:

```dart
import 'dart:io';

import 'coverage/patterns.dart';
import 'coverage/thresholds.dart';

const _configPath = 'coverage_thresholds.yaml';
const _generatedName = '_coverage_imports_test.dart';

void main() {
  final configFile = File(_configPath);
  if (!configFile.existsSync()) {
    stderr.writeln('No se encontro $_configPath');
    exit(1);
  }

  final config = ThresholdConfig.parse(configFile.readAsStringSync());

  for (final package in config.packages) {
    final libDir = Directory('${package.path}/lib');
    if (!libDir.existsSync()) continue;

    final packageName = _packageNameOf(package.path);
    if (packageName == null) {
      stderr.writeln('No se pudo leer el name de ${package.path}/pubspec.yaml');
      exit(1);
    }

    final exclude = config.effectiveExclude(package);
    final imports = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final relative = entity.path
          .substring(package.path.length + 1)
          .replaceAll(r'\', '/');
      if (matchesAny(relative, exclude)) continue;
      if (_isPartFile(entity)) continue;

      // lib/foo/bar.dart -> package:<name>/foo/bar.dart
      imports.add("import 'package:$packageName/${relative.substring(4)}';");
    }

    imports.sort();

    final testDir = Directory('${package.path}/test');
    if (!testDir.existsSync()) testDir.createSync(recursive: true);

    File('${testDir.path}/$_generatedName').writeAsStringSync('''
// GENERADO por tool/gen_coverage_imports.dart — no editar a mano.
//
// Importa todos los archivos de lib/ para que aparezcan en lcov.info aunque
// ningun test los toque. Sin esto, un archivo sin tests no baja el porcentaje.
// ignore_for_file: unused_import, directives_ordering

${imports.join('\n')}

void main() {}
''');

    stdout.writeln('${package.name}: ${imports.length} imports');
  }
}

/// Reads `name:` out of a package's pubspec without a YAML dependency,
/// so this generator stays runnable before `flutter pub get`.
String? _packageNameOf(String packagePath) {
  final pubspec = File('$packagePath/pubspec.yaml');
  if (!pubspec.existsSync()) return null;
  for (final line in pubspec.readAsLinesSync()) {
    if (line.startsWith('name:')) {
      return line.substring(5).trim();
    }
  }
  return null;
}

/// A `part of` file cannot be imported directly.
bool _isPartFile(File file) {
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('//')) continue;
    return trimmed.startsWith('part of');
  }
  return false;
}
```

- [ ] **Step 2: Ignore the generated files**

Append to `.gitignore`:

```
# Generado por tool/gen_coverage_imports.dart
**/test/_coverage_imports_test.dart
coverage/
**/coverage/
```

- [ ] **Step 3: Commit**

```bash
git add tool/gen_coverage_imports.dart .gitignore
git commit -m "feat(tool): generador de imports para denominador de cobertura honesto"
```

---

## Task 7: Melos scripts

**Files:**
- Modify: `melos.yaml`

**Interfaces:**
- Consumes: `tool/gen_coverage_imports.dart` (Task 6), `tool/check_coverage.dart` (Task 5)
- Produces: `melos run test` (no longer silently skips) and `melos run test:coverage`

- [ ] **Step 1: Replace the scripts block**

In `melos.yaml`, replace the entire `test:` script with:

```yaml
  test:
    exec: flutter test --no-pub
    packageFilters:
      dirExists:
        - test
  test:coverage:
    run: |
      dart run tool/gen_coverage_imports.dart
      melos exec --dir-exists=test -- flutter test --coverage --no-pub
      dart run tool/check_coverage.dart
```

The old `if [ -d "test" ]` shell guard is gone: it returned exit 0 for packages without tests, which is how 8 packages passed CI without running anything. `packageFilters: dirExists: test` does the same selection at the melos level, where a skipped package is visibly skipped rather than silently green. After Task 6 runs, every package has a `test/` directory anyway.

- [ ] **Step 2: Verify melos parses the file**

Run: `melos list --json > /dev/null && echo "melos.yaml OK"`
Expected: `melos.yaml OK`

- [ ] **Step 3: Commit**

```bash
git add melos.yaml
git commit -m "fix(melos): el script test ya no pasa en silencio sin tests"
```

---

## Task 8: Seed the thresholds file

Floors are seeded from a real measurement, not from the indicative table in spec §1 — those numbers were taken before exclusions and before the all-imports generator, so they read higher than the truth.

**Files:**
- Create: `coverage_thresholds.yaml`

**Interfaces:**
- Consumes: every tool from Tasks 1–7
- Produces: `coverage_thresholds.yaml` with real measured floors. Later tasks raise individual `min:` values.

- [ ] **Step 1: Write the config with target values**

Create `coverage_thresholds.yaml`:

```yaml
# Floors de cobertura por package.
#
# Reglas:
# - Los floors solo suben. Bajar uno requiere justificacion en el PR.
# - `dart run tool/check_coverage.dart --update` reescribe los floors a lo
#   medido, para que subir un umbral sea un diff revisable.
# - Un package sin coverage/lcov.info cuenta 0%, nunca se saltea.
#
# Targets finales (spec §5): commons/core/token_repository 85,
# features 80, bottom_navigation_bar 60, design_system 40.

defaults:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

packages:
  core:
    path: packages/core
    min: 0
  commons:
    path: packages/commons
    min: 0
    exclude:
      # Adaptadores finos: delegan en un plugin y nada mas. Testearlos
      # equivale a afirmar "se llamo a Hive". Ver spec §5.1.
      - "lib/helpers/persistence_helper/hive_persistence_helper.dart"
      - "lib/helpers/persistence_helper/shared_preferences_persistence_helper.dart"
      - "lib/helpers/image_picker_helper/image_picker_helper_implementation.dart"
      - "lib/helpers/permissions/permissions_handler_package/permissions_handler_helper.dart"
      - "lib/helpers/navigation_helper/beamer_navigation_helper.dart"
      - "lib/helpers/http/dio_http_helper.dart"
  token_repository:
    path: packages/features/repositories/token_repository
    min: 0
  auth:
    path: packages/features/auth
    min: 0
  cart:
    path: packages/features/cart
    min: 0
  catalog:
    path: packages/features/catalog
    min: 0
  login:
    path: packages/features/login
    min: 0
  orders:
    path: packages/features/orders
    min: 0
  order_tracking:
    path: packages/features/order_tracking
    min: 0
  profile:
    path: packages/features/profile
    min: 0
  bottom_navigation_bar:
    path: packages/features/bottom_navigation_bar
    min: 0
  design_system:
    path: packages/design_system
    min: 0

# Fuera del gate:
# - app shell (lib/ en la raiz): composition root, se cubre por E2E
# - packages/test_support: es codigo de test
```

- [ ] **Step 2: Bootstrap and take the real measurement**

```bash
melos bootstrap
melos run test:coverage
```

Expected: the table prints for all 12 packages. `check_coverage.dart` exits 0 because every floor is still 0.

- [ ] **Step 3: Seed the floors from the measurement**

```bash
dart run tool/check_coverage.dart --update
```

Expected: `Floors actualizados en coverage_thresholds.yaml.` Every `min:` now holds the measured value, floored to an integer.

- [ ] **Step 4: Verify the gate is green and is actually reading the new floors**

```bash
dart run tool/check_coverage.dart
```
Expected: exit 0, `Todos los packages estan en o por encima de su floor.`

Then confirm the gate can actually fail — temporarily raise one floor:

```bash
sed -i '0,/min: /s//min: 100 # TEMP/' coverage_thresholds.yaml
dart run tool/check_coverage.dart; echo "exit=$?"
git checkout coverage_thresholds.yaml
```
Expected: `exit=1` with that package listed as below floor. A gate that cannot fail is worse than no gate — this step proves it fails.

Re-run `dart run tool/check_coverage.dart --update` after the `git checkout` to restore the seeded floors.

- [ ] **Step 5: Commit**

```bash
git add coverage_thresholds.yaml
git commit -m "feat(coverage): sembrar floors con la medicion real"
```

---

## Task 9: CI coverage job

**Files:**
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: `melos run test:coverage` (Task 7)
- Produces: a `coverage` job. The `build-web` and `build-android` jobs keep depending on `[analyze, test]` only, so a coverage regression does not block the build sanity checks.

- [ ] **Step 1: Add the job**

In `.github/workflows/ci.yml`, insert this after the `test:` job and before `build-web:`:

```yaml
  coverage:
    name: Coverage gate
    needs: [skip-drafts, validate-branch]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Activate melos
        run: dart pub global activate melos

      - name: Bootstrap packages
        run: melos bootstrap

      - name: Run tests with coverage and check thresholds
        run: melos run test:coverage

      - name: Upload lcov reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-lcov
          path: packages/**/coverage/lcov.info
          if-no-files-found: warn
```

- [ ] **Step 2: Verify the workflow is valid YAML**

Run: `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml')); print('ci.yml OK')"`
Expected: `ci.yml OK`

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: agregar job de gate de cobertura"
```

---

## Task 10: test_support package

Scoped to what Phase 1 actually needs. Entity builders (`aProduct()`, `anOrder()`) are deliberately **not** here — they belong to the Phase 2 plan, where the entities they build are actually used. YAGNI.

**Files:**
- Create: `packages/test_support/pubspec.yaml`
- Create: `packages/test_support/lib/test_support.dart`
- Create: `packages/test_support/lib/src/injector_harness.dart`
- Create: `packages/test_support/lib/src/mocks.dart`

**Interfaces:**
- Consumes: `Injector` from `package:commons`
- Produces:
  - `class MockHttpHelper extends Mock implements HttpHelper {}`
  - `class MockNavigationHelper extends Mock implements NavigationHelper {}`
  - `class MockPersistenceHelper extends Mock implements PersistenceHelper {}`
  - `void resetInjector()` — clears the global `Injector.i` between tests
  - `T registerMock<T extends Object>(T mock)` — registers `mock` as a singleton and returns it

- [ ] **Step 1: Create the pubspec**

Create `packages/test_support/pubspec.yaml`:

```yaml
name: test_support
description: Helpers compartidos para tests unitarios. No se publica ni entra en el bundle.
version: 0.0.1
publish_to: none

environment:
  sdk: '>=3.8.0 <4.0.0'

dependencies:
  commons:
    path: ../commons
  flutter:
    sdk: flutter
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4

dev_dependencies:
  flutter_lints: ^5.0.0
```

- [ ] **Step 2: Create the mocks**

Create `packages/test_support/lib/src/mocks.dart`:

```dart
import 'package:commons/commons.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpHelper extends Mock implements HttpHelper {}

class MockNavigationHelper extends Mock implements NavigationHelper {}

class MockPersistenceHelper extends Mock implements PersistenceHelper {}
```

- [ ] **Step 3: Create the injector harness**

Create `packages/test_support/lib/src/injector_harness.dart`:

```dart
import 'package:commons/commons.dart';

/// Clears the global [Injector] singleton.
///
/// `Injector.i` is process-wide state, so without this a registration made by
/// one test leaks into the next and tests pass or fail depending on order.
/// Call from `setUp`, not `setUpAll`.
void resetInjector() {
  Injector.i.clear();
}

/// Registers [mock] as a singleton of type [T] and returns it.
///
/// ```dart
/// final http = registerMock<HttpHelper>(MockHttpHelper());
/// ```
T registerMock<T extends Object>(T mock) {
  Injector.i.registerSingleton<T>(mock);
  return mock;
}
```

- [ ] **Step 4: Create the barrel**

Create `packages/test_support/lib/test_support.dart`:

```dart
library test_support;

export 'src/injector_harness.dart';
export 'src/mocks.dart';
```

- [ ] **Step 5: Bootstrap and verify it analyzes**

```bash
melos bootstrap
cd packages/test_support && flutter analyze && cd -
```
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add packages/test_support
git commit -m "feat(test_support): package de helpers compartidos para tests"
```

---

## Task 11: Add mocktail and bloc_test everywhere

**Files:**
- Modify: `pubspec.yaml` in all 12 packages plus root

**Interfaces:**
- Consumes: nothing
- Produces: `mocktail` and `bloc_test` importable from any package's tests; `test_support` importable from the three Phase 1 packages

- [ ] **Step 1: Add the dev dependencies**

For each of these packages, add to the `dev_dependencies:` block:

```yaml
  mocktail: ^1.0.4
  bloc_test: ^10.0.0
```

Packages: `packages/commons`, `packages/core`, `packages/design_system`, `packages/features/auth`, `packages/features/bottom_navigation_bar`, `packages/features/cart`, `packages/features/catalog`, `packages/features/login`, `packages/features/order_tracking`, `packages/features/orders`, `packages/features/profile`, `packages/features/repositories/token_repository`.

`bloc_test` is only needed where cubits live, but adding it uniformly keeps the 12 pubspecs consistent and avoids a second pass in Phase 2.

- [ ] **Step 2: Add test_support to the Phase 1 packages**

Additionally add to `dev_dependencies:` of `packages/commons`, `packages/core`, and `packages/features/repositories/token_repository`:

```yaml
  test_support:
    path: ../test_support
```

For `packages/features/repositories/token_repository` the relative path is `../../../test_support` instead. For `packages/commons` and `packages/core` it is `../test_support`.

- [ ] **Step 3: Bootstrap and verify**

```bash
melos bootstrap
melos exec -- flutter analyze
```
Expected: no issues across all packages.

- [ ] **Step 4: Commit**

```bash
git add packages/*/pubspec.yaml packages/features/*/pubspec.yaml packages/features/repositories/*/pubspec.yaml packages/*/pubspec.lock packages/features/*/pubspec.lock packages/features/repositories/*/pubspec.lock
git commit -m "chore(test): agregar mocktail y bloc_test a todos los packages"
```

---

## Task 12: Rewrite ARCHITECTURE.md §18

Section 18 currently mandates the opposite of this strategy: "No usamos `mockito` por default — escribimos **fakes** manuales". Leaving it contradicts every test written from here on.

**Files:**
- Modify: `docs/ARCHITECTURE.md` §18 (starts at the `## 18. Tests` heading)

**Interfaces:**
- Consumes: nothing
- Produces: documentation only

- [ ] **Step 1: Replace the "Fakes vs mocks" subsection**

Replace the paragraph beginning "No usamos `mockito` por default" and its code block with:

```markdown
### Mocks y fakes

Usamos **`mocktail`** para mocks y **`bloc_test`** para cubits. `mocktail` no
necesita codegen y es null-safe; `bloc_test` maneja el ciclo de vida del stream,
que a mano es fragil por timing.

Los fakes escritos a mano se reservan para cuando un fake **con estado** es mas
claro que un mock: por ejemplo un repo in-memory que simula un store.

Los helpers compartidos viven en `packages/test_support`: mocks comunes,
`resetInjector()` y `registerMock<T>()`.

```dart
blocTest<CatalogCubit, CatalogState>(
  'emits [Loading, Ready] on load',
  setUp: () => when(() => repo.getProducts(page: 1))
      .thenAnswer((_) async => Right(page1)),
  build: () => CatalogCubit(repo),
  act: (cubit) => cubit.load(),
  expect: () => [isA<CatalogLoading>(), isA<CatalogReady>()],
  verify: (_) => verify(() => repo.getProducts(page: 1)).called(1),
);
```
```

- [ ] **Step 2: Replace the "Antes de pushear" subsection**

Replace that subsection with:

```markdown
### Cobertura

Cada package tiene un floor en `coverage_thresholds.yaml`, y CI falla si baja.
Los floors solo suben.

```bash
melos bootstrap                              # obligatorio antes de testear
melos run test:coverage                      # corre todo y chequea los floors
dart run tool/check_coverage.dart --update   # sube los floors a lo medido
```

Que **no** se testea, a proposito:
- Entities de Freezed: `==`/`copyWith` son responsabilidad de Freezed.
- Adaptadores finos de plataforma: delegan en un plugin (ver exclusiones en
  `coverage_thresholds.yaml`).
- Pages: las cubre Patrol (E8.3.x), no los unit tests.
```

- [ ] **Step 3: Commit**

```bash
git add docs/ARCHITECTURE.md
git commit -m "docs(arch): reescribir seccion 18 con mocktail, bloc_test y cobertura"
```

---

## Task 13: commons — DateTimeUtils

`DateTimeUtils.isDayPartiallyFull` contains `period.start.isBefore(fullDay.start) && period.start.isAfter(fullDay.start)`, which is unsatisfiable — an instant cannot be both before and after the same instant. Write the test that pins the intended behaviour first, watch it fail, then fix the condition.

**Files:**
- Create: `packages/commons/test/utils/date_time_utils_test.dart`
- Modify: `packages/commons/lib/utils/date_time_utils.dart`

**Interfaces:**
- Consumes: nothing
- Produces: no new public API; fixes `isDayPartiallyFull`

- [ ] **Step 1: Write the failing test**

Create `packages/commons/test/utils/date_time_utils_test.dart`:

```dart
import 'package:commons/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('utcToPST / pstToUTC', () {
    test('utcToPST subtracts seven hours', () {
      final utc = DateTime.utc(2026, 8, 13, 12);

      expect(DateTimeUtils.utcToPST(utc), DateTime.utc(2026, 8, 13, 5));
    });

    test('pstToUTC adds seven hours', () {
      final pst = DateTime(2026, 8, 13, 5);

      expect(DateTimeUtils.pstToUTC(pst), DateTime.utc(2026, 8, 13, 12));
    });

    test('pstToUTC then utcToPST round trips', () {
      final pst = DateTime(2026, 8, 13, 9, 30);

      expect(DateTimeUtils.utcToPST(DateTimeUtils.pstToUTC(pst)),
          DateTime.utc(2026, 8, 13, 9, 30));
    });
  });

  group('fullDayOverlap', () {
    test('is true when the period strictly contains the whole day', () {
      final day = DateTime(2026, 8, 13);
      final range = DateTimeRange(
        start: DateTime(2026, 8, 12),
        end: DateTime(2026, 8, 14),
      );

      expect(DateTimeUtils.fullDayOverlap(day, range), isTrue);
    });

    test('is false when the period only covers part of the day', () {
      final day = DateTime(2026, 8, 13);
      final range = DateTimeRange(
        start: DateTime(2026, 8, 13, 9),
        end: DateTime(2026, 8, 13, 11),
      );

      expect(DateTimeUtils.fullDayOverlap(day, range), isFalse);
    });
  });

  group('isDayCompletelyFull', () {
    test('is true when some period covers the whole day', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayCompletelyFull(day, [
          DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 2)),
          DateTimeRange(start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 14)),
        ]),
        isTrue,
      );
    });

    test('is false for an empty period list', () {
      expect(DateTimeUtils.isDayCompletelyFull(DateTime(2026, 8, 13), const []),
          isFalse);
    });
  });

  group('isDayPartiallyFull', () {
    test('is true when a period falls entirely inside the day', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(
            start: DateTime(2026, 8, 13, 9),
            end: DateTime(2026, 8, 13, 11),
          ),
        ]),
        isTrue,
      );
    });

    test('is true when a period starts inside the day and runs past its end', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(
            start: DateTime(2026, 8, 13, 22),
            end: DateTime(2026, 8, 14, 3),
          ),
        ]),
        isTrue,
      );
    });

    test('is true when a period starts before the day and ends inside it', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(
            start: DateTime(2026, 8, 12, 22),
            end: DateTime(2026, 8, 13, 3),
          ),
        ]),
        isTrue,
      );
    });

    test('is false when a period covers the whole day, that is completely full', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 14)),
        ]),
        isFalse,
      );
    });

    test('is false when the period does not touch the day at all', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 2)),
        ]),
        isFalse,
      );
    });

    test('is false for an empty period list', () {
      expect(DateTimeUtils.isDayPartiallyFull(DateTime(2026, 8, 13), const []),
          isFalse);
    });
  });
}
```

- [ ] **Step 2: Run the test to see which cases fail**

Run: `cd packages/commons && flutter test test/utils/date_time_utils_test.dart`
Expected: FAIL on `is true when a period starts before the day and ends inside it` — the unsatisfiable clause is what was supposed to cover that case.

- [ ] **Step 3: Fix the condition**

In `packages/commons/lib/utils/date_time_utils.dart`, replace the body of `isDayPartiallyFull` with:

```dart
  static bool isDayPartiallyFull(DateTime day, List<DateTimeRange> unavailablePeriods) {
    final fullDay = _dateToRange(day);
    return unavailablePeriods.any((period) {
      if (fullDayOverlap(day, period)) return false;
      // Se solapan sin cubrir el dia entero.
      return period.start.isBefore(fullDay.end) &&
          period.end.isAfter(fullDay.start);
    });
  }
```

The old first clause (`start.isBefore(x) && start.isAfter(x)`) was dead code; the third clause bound `!fullDayOverlap` only to itself because `&&` binds tighter than `||`, so a fully-covering period could still report partial. Both are fixed by testing the overlap once, up front.

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd packages/commons && flutter test test/utils/date_time_utils_test.dart`
Expected: PASS — 12 tests

- [ ] **Step 5: Commit**

```bash
git add packages/commons/test/utils/date_time_utils_test.dart packages/commons/lib/utils/date_time_utils.dart
git commit -m "fix(commons): condicion insatisfacible en isDayPartiallyFull"
```

---

## Task 14: commons — ImageUrlResolver

**Files:**
- Create: `packages/commons/test/utils/image_url_resolver_test.dart`

**Interfaces:**
- Consumes: `resetInjector`, `registerMock`, `MockHttpHelper` from `package:test_support` (Task 10)
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/commons/test/utils/image_url_resolver_test.dart`:

```dart
import 'package:commons/commons.dart';
import 'package:commons/utils/image_url_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

void main() {
  setUp(resetInjector);

  group('without an injected HttpHelper', () {
    test('returns null for null input', () {
      expect(ImageUrlResolver.resolve(null), isNull);
    });

    test('returns null for empty input', () {
      expect(ImageUrlResolver.resolve(''), isNull);
    });

    test('passes through absolute http and https urls', () {
      expect(
        ImageUrlResolver.resolve('https://picsum.photos/200'),
        'https://picsum.photos/200',
      );
      expect(
        ImageUrlResolver.resolve('http://example.com/a.png'),
        'http://example.com/a.png',
      );
    });

    test('passes through data uris', () {
      expect(
        ImageUrlResolver.resolve('data:image/png;base64,AAA'),
        'data:image/png;base64,AAA',
      );
    });

    test('passes through values with no recognised shape', () {
      expect(ImageUrlResolver.resolve('weird-value'), 'weird-value');
    });

    test('returns the raw relative path when no baseUrl can be resolved', () {
      expect(
        ImageUrlResolver.resolve('/api/v1/files/images/a.png'),
        '/api/v1/files/images/a.png',
      );
    });
  });

  group('with an explicit baseUrl', () {
    test('prepends it to a relative path', () {
      expect(
        ImageUrlResolver.resolve(
          '/api/v1/files/images/a.png',
          baseUrl: 'https://api.example.com',
        ),
        'https://api.example.com/api/v1/files/images/a.png',
      );
    });

    test('does not produce a double slash when baseUrl has a trailing slash', () {
      expect(
        ImageUrlResolver.resolve(
          '/api/v1/files/images/a.png',
          baseUrl: 'https://api.example.com/',
        ),
        'https://api.example.com/api/v1/files/images/a.png',
      );
    });

    test('is ignored for an absolute url', () {
      expect(
        ImageUrlResolver.resolve(
          'https://picsum.photos/200',
          baseUrl: 'https://api.example.com',
        ),
        'https://picsum.photos/200',
      );
    });
  });

  group('with an injected HttpHelper', () {
    test('falls back to the registered helper baseUrl', () {
      final http = registerMock<HttpHelper>(MockHttpHelper());
      when(() => http.baseUrl).thenReturn('https://injected.example.com');

      expect(
        ImageUrlResolver.resolve('/api/v1/files/images/a.png'),
        'https://injected.example.com/api/v1/files/images/a.png',
      );
    });

    test('an explicit baseUrl wins over the injected one', () {
      final http = registerMock<HttpHelper>(MockHttpHelper());
      when(() => http.baseUrl).thenReturn('https://injected.example.com');

      expect(
        ImageUrlResolver.resolve(
          '/a.png',
          baseUrl: 'https://explicit.example.com',
        ),
        'https://explicit.example.com/a.png',
      );
      verifyNever(() => http.baseUrl);
    });
  });
}
```

- [ ] **Step 2: Run the test**

Run: `cd packages/commons && flutter test test/utils/image_url_resolver_test.dart`
Expected: PASS — 11 tests

These are **characterization tests**: `ImageUrlResolver` is already written and its doc comment
states the intended contract, so the tests pin existing behaviour rather than driving new code.
There is no red phase to observe.

A failure here means one of two real problems, and neither is fixed by editing the test:
- the implementation disagrees with its own doc comment → fix `image_url_resolver.dart`
- `test_support` does not resolve → Task 11 Step 2 was skipped

- [ ] **Step 3: Commit**

```bash
git add packages/commons/test/utils/image_url_resolver_test.dart
git commit -m "test(commons): cobertura de ImageUrlResolver"
```

---

## Task 15: commons — HTTP entities, interceptor and permission mapper

**Files:**
- Create: `packages/commons/test/helpers/http/entities/http_response_test.dart`
- Create: `packages/commons/test/helpers/http/entities/http_response_error_test.dart`
- Create: `packages/commons/test/helpers/http/interceptors/auth_interceptor_test.dart`
- Create: `packages/commons/test/helpers/permissions/permission_type_mapper_test.dart`

**Interfaces:**
- Consumes: `HttpResponse`, `HttpResponseError`, `AuthInterceptor`, `PermissionTypeMapper`, `PermissionType`
- Produces: nothing new

- [ ] **Step 1: Write the HttpResponse test**

Create `packages/commons/test/helpers/http/entities/http_response_test.dart`:

```dart
import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults status to 999 when none is given', () {
    final response = HttpResponse<String>(data: 'x');

    expect(response.status, '999');
    expect(response.statusCode, 999);
  });

  test('keeps the provided status and parses it', () {
    final response = HttpResponse<String>(data: 'x', status: '200');

    expect(response.status, '200');
    expect(response.statusCode, 200);
  });

  test('statusCode is null when the status is not numeric', () {
    final response = HttpResponse<String>(status: 'boom');

    expect(response.statusCode, isNull);
  });

  test('data is null when not provided', () {
    expect(HttpResponse<String>().data, isNull);
  });
}
```

- [ ] **Step 2: Write the HttpResponseError test**

Create `packages/commons/test/helpers/http/entities/http_response_error_test.dart`:

```dart
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults statusCode to 999 when none is given', () {
    final error = HttpResponseError(errorType: 'network', message: 'offline');

    expect(error.statusCode, 999);
  });

  test('keeps the provided statusCode', () {
    final error = HttpResponseError(
      errorType: 'http',
      message: 'not found',
      statusCode: 404,
    );

    expect(error.statusCode, 404);
    expect(error.errorType, 'http');
    expect(error.message, 'not found');
  });

  test('optional fields default to null', () {
    final error = HttpResponseError(errorType: null, message: null);

    expect(error.reason, isNull);
    expect(error.stackTrace, isNull);
  });
}
```

- [ ] **Step 3: Write the AuthInterceptor test**

Create `packages/commons/test/helpers/http/interceptors/auth_interceptor_test.dart`:

```dart
import 'package:commons/helpers/http/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replaces request headers with the interceptor result', () {
    final interceptor = AuthInterceptor(
      requestInterceptionData: (headers) => {
        ...headers,
        'Authorization': 'Bearer token-123',
      },
    );
    final options = RequestOptions(path: '/products', headers: {'Accept': 'json'});

    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(options.headers['Authorization'], 'Bearer token-123');
    expect(options.headers['Accept'], 'json');
  });

  test('passes the existing headers into the callback', () {
    Map<String, dynamic>? seen;
    final interceptor = AuthInterceptor(
      requestInterceptionData: (headers) {
        seen = headers;
        return headers;
      },
    );
    final options = RequestOptions(path: '/x', headers: {'A': '1'});

    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(seen, containsPair('A', '1'));
  });
}
```

- [ ] **Step 4: Write the PermissionTypeMapper test**

Create `packages/commons/test/helpers/permissions/permission_type_mapper_test.dart`:

```dart
import 'package:commons/helpers/permissions/permission_type.dart';
import 'package:commons/helpers/permissions/permissions_handler_package/data/mappers/permission_type_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  test('maps camera to Permission.camera', () {
    final mapper = PermissionTypeMapper(
      permissionType: const PermissionType.camera(),
    );

    expect(mapper.toPermission, Permission.camera);
  });
}
```

- [ ] **Step 5: Run all four**

Run: `cd packages/commons && flutter test test/helpers/`
Expected: PASS — 10 tests

- [ ] **Step 6: Commit**

```bash
git add packages/commons/test/helpers
git commit -m "test(commons): cobertura de entities http, interceptor y mapper de permisos"
```

---

## Task 16: Raise the commons floor

**Files:**
- Modify: `coverage_thresholds.yaml`

**Interfaces:**
- Consumes: Tasks 13–15
- Produces: an enforced floor for `commons`

- [ ] **Step 1: Measure**

```bash
melos run test:coverage
```
Note the `commons` percentage from the table.

- [ ] **Step 2: Raise the floor**

If `commons` reached 85% or more, set `min: 85` in `coverage_thresholds.yaml`.

If it landed below 85%, do **not** invent a number. Pick one and say which in the PR:
- **a)** The gap is more thin platform adapters (for example `build_data_helper` / `package_info_build_data_helper`, which only wrap `package_info_plus`). Add them to the `commons` `exclude:` list with a one-line reason, re-measure, then set `min: 85`.
- **b)** The gap is genuinely untested logic that is out of scope for this task. Set `min:` to the measured value floored to an integer and open a follow-up issue naming the uncovered files.

Never lower a floor below what is already measured, and never raise a floor above what is measured — the gate must be green on merge.

- [ ] **Step 3: Verify the gate passes**

```bash
dart run tool/check_coverage.dart
```
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add coverage_thresholds.yaml
git commit -m "feat(coverage): subir floor de commons"
```

---

## Task 17: token_repository — LocalTokenRepository

`_decodeToken` splits a JWT, base64url-decodes the payload and reads `map['user']`. Every failure path funnels into `Left(TokenFailure())`.

**Files:**
- Create: `packages/features/repositories/token_repository/test/data/repositories/local_token_repository_test.dart`

**Interfaces:**
- Consumes: `LocalTokenRepository`, `TokenModel`, `TokenFailure`
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/features/repositories/token_repository/test/data/repositories/local_token_repository_test.dart`:

```dart
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:token_repository/token_repository.dart';
import 'package:token_repository/src/data/repositories/local_token_repository.dart';

/// Builds a JWT-shaped string whose payload is [payload].
///
/// The signature is not verified by the repository, so any third segment works.
String _jwt(Map<String, dynamic> payload) {
  final encoded = base64Url.encode(utf8.encode(json.encode(payload)));
  return 'header.$encoded.signature';
}

void main() {
  test('returns Right(null) when there is no token', () async {
    final repo = LocalTokenRepository(onGetTokenUseCase: () => null);

    final result = await repo.fetch();

    expect(result, const Right<TokenFailure, TokenModel?>(null));
  });

  test('decodes the user object out of the payload', () async {
    final token = _jwt({
      'user': {
        'email': 'admin@smartwarehouse.local',
        'isRegistered': true,
        'agentId': 'agent-7',
      },
    });
    final repo = LocalTokenRepository(onGetTokenUseCase: () => token);

    final result = await repo.fetch();

    final model = result.getOrElse(() => null);
    expect(model?.email, 'admin@smartwarehouse.local');
    expect(model?.isRegistered, isTrue);
    expect(model?.agentId, 'agent-7');
  });

  test('agentId is optional', () async {
    final token = _jwt({
      'user': {'email': 'a@b.c', 'isRegistered': false},
    });
    final repo = LocalTokenRepository(onGetTokenUseCase: () => token);

    final result = await repo.fetch();

    expect(result.getOrElse(() => null)?.agentId, isNull);
  });

  test('returns a failure when the token does not have three segments', () async {
    final repo = LocalTokenRepository(onGetTokenUseCase: () => 'not-a-jwt');

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the payload is not valid base64', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => 'header.!!!not-base64!!!.signature',
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the payload has no user key', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => _jwt({'sub': '123'}),
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the user object is missing required fields', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => _jwt({
        'user': {'email': 'a@b.c'},
      }),
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the callback throws', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => throw Exception('boom'),
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });
}
```

- [ ] **Step 2: Run the test**

Run: `cd packages/features/repositories/token_repository && flutter test`
Expected: PASS — 8 tests

Characterization tests again: `LocalTokenRepository` already exists, so these pin its behaviour
rather than driving it. No red phase.

Pay attention to the four failure-path tests. They all assert `isLeft()`, which passes as long as
*something* throws inside the `try`. If one of them fails, the repository is swallowing a case it
should reject — fix `local_token_repository.dart`, not the test.

- [ ] **Step 3: Raise the floor**

```bash
cd - && melos run test:coverage
```
Set `token_repository` `min:` in `coverage_thresholds.yaml` to 85 if reached, otherwise apply the same rule as Task 16 Step 2.

- [ ] **Step 4: Commit**

```bash
git add packages/features/repositories/token_repository/test coverage_thresholds.yaml
git commit -m "test(token_repository): cobertura de decode de JWT y subir floor"
```

---

## Task 18: core — entities and routes

**Files:**
- Create: `packages/core/test/domain/entities/app_data_source_test.dart`
- Create: `packages/core/test/domain/entities/app_environment_test.dart`
- Create: `packages/core/test/navigation/routes_test.dart`

**Interfaces:**
- Consumes: `AppDataSource`, `AppEnvironment`, `Routes`
- Produces: nothing new

- [ ] **Step 1: Write the AppDataSource test**

Create `packages/core/test/domain/entities/app_data_source_test.dart`:

```dart
import 'package:core/src/domain/entities/app_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromString maps mock', () {
    final source = AppDataSource.fromString('mock');

    expect(source.isMock, isTrue);
    expect(source.isRemote, isFalse);
  });

  test('fromString maps remote', () {
    final source = AppDataSource.fromString('remote');

    expect(source.isRemote, isTrue);
    expect(source.isMock, isFalse);
  });

  test('fromString falls back to mock for an unknown value', () {
    expect(AppDataSource.fromString('nonsense').isMock, isTrue);
    expect(AppDataSource.fromString('').isMock, isTrue);
  });
}
```

- [ ] **Step 2: Write the AppEnvironment test**

Create `packages/core/test/domain/entities/app_environment_test.dart`:

```dart
import 'package:core/src/domain/entities/app_data_source.dart';
import 'package:core/src/domain/entities/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment.fromString', () {
    test('maps each known flavor', () {
      expect(AppEnvironment.fromString('dev'), const AppEnvironment.dev());
      expect(AppEnvironment.fromString('qa'), const AppEnvironment.qa());
      expect(AppEnvironment.fromString('prod'), const AppEnvironment.prod());
    });

    test('falls back to dev for unknown and null', () {
      expect(AppEnvironment.fromString('staging'), const AppEnvironment.dev());
      expect(AppEnvironment.fromString(null), const AppEnvironment.dev());
    });
  });

  group('EnvironmentConfig', () {
    test('holds the environment and data source it was built with', () {
      final config = EnvironmentConfig(
        environment: const AppEnvironment.qa(),
        dataSource: const AppDataSource.mock(),
      );

      expect(config.environment, const AppEnvironment.qa());
      expect(config.dataSource.isMock, isTrue);
    });

    test('fromEnvVariables defaults to remote when no dart-define is set', () {
      // No --dart-define is passed by `flutter test`, so both env lookups are
      // empty and the remote default applies.
      final config = EnvironmentConfig.fromEnvVariables();

      expect(config.dataSource.isRemote, isTrue);
    });
  });
}
```

- [ ] **Step 3: Write the Routes test**

Create `packages/core/test/navigation/routes_test.dart`:

```dart
import 'package:core/src/navigation/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a catalog detail path from a product id', () {
    expect(Routes.catalogDetail('p-1'), '/catalog/p-1');
  });

  test('builds an order success path from an order id', () {
    expect(Routes.orderSuccess('o-9'), '/order/o-9/success');
  });

  test('builds an order detail path from an order id', () {
    expect(Routes.orderDetail('o-9'), '/orders/o-9');
  });

  test('builders line up with their patterns', () {
    expect(Routes.catalogDetailPattern, '/catalog/:id');
    expect(Routes.orderDetailPattern, '/orders/:id');
    expect(Routes.orderSuccessPattern, '/order/:id/success');
  });

  test('static routes are stable', () {
    expect(Routes.login, '/login');
    expect(Routes.catalog, '/catalog');
    expect(Routes.cart, '/cart');
    expect(Routes.orders, '/orders');
    expect(Routes.profile, '/profile');
    expect(Routes.profileEditAddress, '/profile/address');
    expect(Routes.notifications, '/notifications');
  });
}
```

- [ ] **Step 4: Run the tests**

Run: `cd packages/core && flutter test`
Expected: PASS — 12 tests

- [ ] **Step 5: Commit**

```bash
git add packages/core/test
git commit -m "test(core): cobertura de entities de entorno y rutas"
```

---

## Task 19: core — use cases through the Injector

`OnUserAuthenticatedUseCase` resolves a `NavigationHelper` from the global `Injector`, which is exactly the seam that makes it testable. It takes a `BuildContext`, so the test needs a pumped widget to obtain one.

**Files:**
- Create: `packages/core/test/use_cases/on_user_authenticated_use_case_test.dart`
- Create: `packages/core/test/use_cases/on_intercept_http_request_use_case_test.dart`

**Interfaces:**
- Consumes: `resetInjector`, `registerMock`, `MockNavigationHelper` from `package:test_support` (Task 10); `OnUserAuthenticatedUseCase`, `OnInterceptHttpRequestUseCase`, `Routes`
- Produces: nothing new

- [ ] **Step 1: Write the OnUserAuthenticatedUseCase test**

Create `packages/core/test/use_cases/on_user_authenticated_use_case_test.dart`:

```dart
import 'package:commons/commons.dart';
import 'package:core/src/navigation/routes.dart';
import 'package:core/src/use_cases/session/on_user_authenticated_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

void main() {
  setUp(resetInjector);

  testWidgets('navigates to the catalog replacing the current route',
      (tester) async {
    // `pushNamed` returns void, so it needs no `when(...)` stub — mocktail
    // records the call and returns null on its own.
    final navigation = registerMock<NavigationHelper>(MockNavigationHelper());

    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    OnUserAuthenticatedUseCase.call(capturedContext);

    verify(
      () => navigation.pushNamed(
        capturedContext,
        routeName: Routes.catalog,
        replace: true,
      ),
    ).called(1);
  });
}
```

- [ ] **Step 2: Write the OnInterceptHttpRequestUseCase test**

This use case calls `AuthFeatureBuilder.getAuthData()`, which resolves an `AuthCubit` from the Injector. With no `AuthCubit` registered, `Injector.i.resolve` throws — so the test registers a real `AuthCubit` in its empty state rather than mocking a static.

Create `packages/core/test/use_cases/on_intercept_http_request_use_case_test.dart`:

```dart
import 'package:auth/auth.dart';
import 'package:commons/commons.dart';
import 'package:core/src/use_cases/interceptor/on_intercept_http_request_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

class _MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  setUp(resetInjector);

  test('returns the headers untouched when there is no session', () {
    final cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(const AuthState.empty());
    registerMock<AuthCubit>(cubit);

    final headers = OnInterceptHttpRequestUseCase.call({'Accept': 'json'});

    expect(headers, {'Accept': 'json'});
    expect(headers.containsKey('Authorization'), isFalse);
  });
}
```

`AuthState.empty()` is the real constructor — verified in
`packages/features/auth/lib/src/presentation/bloc/auth_state.dart`, which declares
`const factory AuthState.empty() = EmptyAuthState;` and
`const factory AuthState.data(AuthData authData, {required bool hasUpdated}) = SuccessAuthState;`.

- [ ] **Step 3: Run the tests**

Run: `cd packages/core && flutter test test/use_cases/`
Expected: PASS — 2 tests

- [ ] **Step 4: Raise the core floor**

```bash
cd - && melos run test:coverage
```
Set `core` `min:` to 85 if reached, otherwise apply the Task 16 Step 2 rule.

- [ ] **Step 5: Commit**

```bash
git add packages/core/test coverage_thresholds.yaml
git commit -m "test(core): cobertura de use cases via el Injector y subir floor"
```

---

## Task 20: Full verification

**Files:** none

- [ ] **Step 1: Clean run from scratch**

```bash
melos bootstrap
melos run test:coverage
```
Expected: every package's tests pass, the coverage table prints, exit code 0.

- [ ] **Step 2: Confirm the gate still fails when it should**

```bash
sed -i 's/^\(  core:\)/\1/' coverage_thresholds.yaml
python3 - <<'PY'
import re
p='coverage_thresholds.yaml'
s=open(p).read()
s=re.sub(r'(  core:\n    path: packages/core\n    min: )\d+', r'\g<1>100', s)
open(p,'w').write(s)
PY
dart run tool/check_coverage.dart; echo "exit=$?"
git checkout coverage_thresholds.yaml
```
Expected: `exit=1`, with `core` reported below floor.

- [ ] **Step 3: Confirm analyze is clean**

```bash
melos exec -- flutter analyze
```
Expected: no issues in any package.

- [ ] **Step 4: Push and open the PR**

```bash
git push -u origin feature/e8.2-phase0-coverage-infra
gh pr create --base develop \
  --title "feat(test): infra de cobertura y Fase 1 (commons, token_repository, core)" \
  --body "Implementa Fase 0 y Fase 1 del spec docs/superpowers/specs/2026-08-12-test-strategy-design.md

Closes #130"
```

---

## Verification Checklist

- [ ] `melos run test:coverage` exits 0 on a clean checkout after `melos bootstrap`
- [ ] The gate demonstrably fails when a floor is raised above the measured value
- [ ] A package with no `lcov.info` reports `SIN REPORTE` and fails, rather than being skipped
- [ ] `.g.dart` and `.freezed.dart` files do not appear in any package's numerator or denominator
- [ ] The six `commons` platform adapters from spec §5.1 are excluded, each with a reason comment
- [ ] `melos exec -- flutter analyze` is clean
- [ ] `docs/ARCHITECTURE.md` §18 no longer tells the reader to avoid mockito-style mocks
- [ ] `coverage_thresholds.yaml` floors for `commons`, `token_repository` and `core` reflect real measurements
