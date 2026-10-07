import 'dart:convert';
import 'dart:io';

/// Lee un fixture JSON desde el directorio `test/fixtures/` del package que
/// está corriendo el test.
///
/// `flutter test` corre con el cwd en la raíz del package, así que la ruta es
/// relativa a ahí. Tirar un error claro cuando falta el archivo evita el
/// clásico "Unexpected end of input" de intentar parsear un string vacío.
Map<String, dynamic> loadJsonFixture(String path) {
  final file = File('test/fixtures/$path');
  if (!file.existsSync()) {
    throw StateError(
      'No se encontró el fixture test/fixtures/$path '
      '(cwd: ${Directory.current.path})',
    );
  }
  final decoded = json.decode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw StateError('El fixture test/fixtures/$path no es un objeto JSON');
  }
  return decoded;
}
