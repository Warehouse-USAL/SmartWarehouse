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
