/// Line coverage for a single source file, as reported by an lcov tracefile.
class FileCoverage {
  const FileCoverage({
    required this.path,
    required this.linesFound,
    required this.linesHit,
  });

  /// Path from the `SF:` line — relative to the package root, con separadores
  /// normalizados a `/`.
  final String path;
  final int linesFound;
  final int linesHit;
}

/// Parses an lcov tracefile.
///
/// Only `SF:` and `DA:` lines are read. `LF:`/`LH:` summary lines are ignored
/// on purpose: after exclusions are applied the totals have to be recomputed
/// from the surviving `DA:` lines anyway.
///
/// Los separadores de `SF:` se normalizan a `/`. En Windows `flutter test
/// --coverage` los emite como `lib\theme\...`, y los globs de
/// `coverage_thresholds.yaml` estan escritos con `/`: sin normalizar, **ninguna
/// exclusion matchea** y el gate mide contra un denominador inflado. En Linux
/// no cambia nada, que es donde corre CI — por eso el bug sobrevivio hasta
/// #169.
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
      path = line.substring(3).trim().replaceAll(r'\', '/');
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
