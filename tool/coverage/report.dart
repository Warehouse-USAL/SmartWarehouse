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
