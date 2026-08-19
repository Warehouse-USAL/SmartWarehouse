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

  if (config.packages.isEmpty) {
    stderr.writeln(
      'coverage_thresholds.yaml no declara ningun package. Un gate sin packages '
      'no verifica nada: se trata como error, no como exito.',
    );
    exit(1);
  }

  final results = <PackageResult>[];

  for (final package in config.packages) {
    if (!Directory(package.path).existsSync()) {
      stderr.writeln(
        'El package "${package.name}" declara path "${package.path}" en '
        '$_configPath, pero ese directorio no existe. Un package movido o '
        'renombrado no puede seguir contando 0% en silencio.',
      );
      exit(1);
    }

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
    final missing = results.where((r) => !r.hasReport).toList();
    if (missing.isNotEmpty) {
      stderr.writeln(
        '\n--update se nego a correr: ${missing.length} package(s) sin '
        'coverage/lcov.info:',
      );
      for (final r in missing) {
        stderr.writeln('  - ${r.name}');
      }
      stderr.writeln(
        '\nCorre "melos run test:coverage" primero para generar los reportes. '
        'Actualizar floors con reportes faltantes los pisaria a 0.',
      );
      exit(1);
    }

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
  final minKey = RegExp(r'^(\s*min:\s*)(\d+)(\s*(?:#.*)?)$');

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
        final existingMin = int.parse(minMatch.group(2)!);
        final measuredFloor = result.percent.floor();
        final newMin = existingMin > measuredFloor ? existingMin : measuredFloor;
        output.add(
          '${minMatch.group(1)}$newMin${minMatch.group(3)}',
        );
        continue;
      }
    }

    output.add(line);
  }

  configFile.writeAsStringSync('${output.join('\n')}\n');
}
