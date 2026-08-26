import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lo unico que `test_support` puede tener en `dependencies`.
///
/// La regla del spec §4.3: `test_support` no depende de packages de features.
/// Cuando lo hacia (dependia de `catalog`), el binario de tests de `commons`
/// compilaba catalog, design_system y bottom_navigation_bar por un archivo que
/// solo queria MockHttpHelper.
///
/// Agregar algo a esta lista es una decision de diseno, no un tramite: si un
/// helper nuevo necesita una feature, va a un package `<feature>_test_builders`
/// aparte, no aca.
const _allowed = {'flutter', 'flutter_test', 'commons', 'mocktail'};

/// Devuelve los nombres declarados bajo `dependencies:` de un pubspec.
///
/// Parseo por lineas a proposito: el repo no tiene el package `yaml` como
/// dependencia y `tool/coverage/thresholds.dart` ya resuelve su YAML asi.
/// Un pubspec tiene sangria fija, con lo cual alcanza con mirar la columna.
Set<String> _dependencyNames(String pubspec) {
  final names = <String>{};
  var inDependencies = false;

  for (final line in const LineSplitter().convert(pubspec)) {
    if (line.trimRight() == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    // Cualquier clave de nivel cero cierra el bloque.
    if (inDependencies &&
        line.isNotEmpty &&
        !line.startsWith(' ') &&
        !line.startsWith('#')) {
      inDependencies = false;
    }
    if (!inDependencies) continue;

    final match = RegExp(r'^  ([a-z0-9_]+):').firstMatch(line);
    if (match != null) names.add(match.group(1)!);
  }

  return names;
}

void main() {
  test('test_support solo depende de commons y mocktail', () {
    final pubspec = File('packages/test_support/pubspec.yaml');
    expect(
      pubspec.existsSync(),
      isTrue,
      reason: 'correr desde la raiz del repo (cwd: ${Directory.current.path})',
    );

    final declared = _dependencyNames(pubspec.readAsStringSync());
    final extra = declared.difference(_allowed);

    expect(
      extra,
      isEmpty,
      reason:
          'test_support no puede depender de packages de features (spec §4.3). '
          'Si el helper nuevo necesita una feature, va a <feature>_test_builders.',
    );
  });

  test('el parser lee las dependencias y corta en la clave siguiente', () {
    const pubspec = '''
name: ejemplo

dependencies:
  commons:
    path: ../commons
  mocktail: ^1.0.4

dev_dependencies:
  flutter_lints: ^5.0.0
''';

    expect(_dependencyNames(pubspec), {'commons', 'mocktail'});
  });
}
