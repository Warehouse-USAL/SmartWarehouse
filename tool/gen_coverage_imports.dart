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
