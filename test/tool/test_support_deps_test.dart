import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lo unico que `test_support` puede tener en `dependencies`.
///
/// La regla del spec §4.3: `test_support` no depende de packages de features.
/// Antes dependia de `catalog`, pese a que de sus cinco consumidores cuatro no
/// usaban un solo builder. Separarla en un package aparte le da a la capa de
/// soporte un grafo de dependencias honesto y hace la regla verificable (no
/// vuelve mas liviano ningun binario de test: ver spec §4.3, bloque "Lo que
/// esto NO arregla").
///
/// Agregar algo a esta lista es una decision de diseno, no un tramite: si un
/// helper nuevo necesita una feature, va a un package `<feature>_test_builders`
/// aparte, no aca.
///
/// Lo que este guard NO cubre: solo lee `pubspec.yaml`, no
/// `packages/test_support/pubspec_overrides.yaml` (que Melos regenera con
/// `dependency_overrides` para cada package del workspace, asi que `catalog`
/// queda resoluble igual desde adentro de `test_support`). Un
/// `import 'package:catalog/...'` agregado a mano en `test_support/lib/`
/// compilaria sin que este test lo note; eso lo atrapa el lint
/// `depend_on_referenced_packages` (de `package:lints/core.yaml` via
/// `flutter_lints`), que corre en CI con `melos exec -- flutter analyze`.
const _allowed = {'flutter', 'flutter_test', 'commons', 'mocktail'};

/// Claves que aparecen anidadas bajo una dependencia (`commons:\n    path:
/// ../commons`) y que la regex de nombres podria confundir con otra
/// dependencia hermana una vez que el indent minimo dejo de ser exactamente
/// dos espacios. No son dependencias en si mismas.
const _nestedKeys = {
  'path',
  'sdk',
  'version',
  'git',
  'hosted',
  'ref',
  'url',
  'relative',
};

/// Devuelve los nombres declarados bajo `dependencies:` de un pubspec.
///
/// Parseo por lineas a proposito: el repo no tiene el package `yaml` como
/// dependencia y `tool/coverage/thresholds.dart` ya resuelve su YAML asi.
Set<String> _dependencyNames(String pubspec) {
  final names = <String>{};
  var inDependencies = false;

  for (final line in const LineSplitter().convert(pubspec)) {
    final trimmedRight = line.trimRight();
    final isTopLevelKey = !line.startsWith(' ') && !line.startsWith('\t');

    // Clave de nivel cero que abre el bloque. `startsWith` en vez de `==`
    // tolera un comentario pegado a la clave (`dependencies: # comentario`).
    // No es ambiguo con `dev_dependencies:` porque ese prefijo no coincide.
    if (isTopLevelKey && trimmedRight.startsWith('dependencies:')) {
      inDependencies = true;
      continue;
    }
    // Cualquier otra clave de nivel cero cierra el bloque.
    if (inDependencies &&
        line.isNotEmpty &&
        isTopLevelKey &&
        !line.startsWith('#')) {
      inDependencies = false;
    }
    if (!inDependencies) continue;

    final match = RegExp(r'^ {2,}"?([a-z0-9_]+)"?:').firstMatch(line);
    if (match == null) continue;

    final name = match.group(1)!;
    // `path:`, `sdk:`, etc. son claves anidadas bajo una dependencia
    // (ej. `commons:` seguido de `path: ../commons`), no dependencias.
    if (_nestedKeys.contains(name)) continue;

    names.add(name);
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

    expect(
      declared,
      contains('commons'),
      reason:
          'el parser no encontro ninguna dependencia conocida — probablemente '
          'cambio el formato de packages/test_support/pubspec.yaml y este guard '
          'quedo mirando al vacio',
    );

    final extra = declared.difference(_allowed);
    expect(
      extra,
      isEmpty,
      reason:
          'test_support no puede depender de packages de features (spec §4.3). '
          'Si el helper nuevo necesita una feature, va a <feature>_test_builders.',
    );
  });

  group('_dependencyNames', () {
    test('lee las dependencias y corta en la clave siguiente', () {
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

    test('tolera un comentario pegado a la clave "dependencies:"', () {
      const pubspec = '''
name: ejemplo

dependencies: # comentario
  commons:
    path: ../commons
  mocktail: ^1.0.4

dev_dependencies:
  flutter_lints: ^5.0.0
''';

      expect(_dependencyNames(pubspec), {'commons', 'mocktail'});
    });

    test('tolera indentacion de cuatro espacios', () {
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

    test('tolera claves entre comillas', () {
      const pubspec = '''
name: ejemplo

dependencies:
  "commons":
    path: ../commons
  "mocktail": ^1.0.4

dev_dependencies:
  flutter_lints: ^5.0.0
''';

      expect(_dependencyNames(pubspec), {'commons', 'mocktail'});
    });
  });
}
