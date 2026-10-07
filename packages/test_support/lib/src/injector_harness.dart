import 'package:commons/commons.dart';

/// Limpia el singleton global [Injector].
///
/// `Injector.i` es estado de proceso: sin esto, un registro hecho por un test
/// se filtra al siguiente y los tests pasan o fallan segun el orden.
/// Llamar desde `setUp`, no `setUpAll`.
///
/// Es `async` a proposito: `GetItInjector.clear()` delega en `GetIt.reset()`,
/// que es asincronico, y descarta su Future. Sin este pump, `isRegistered()`
/// puede leer `true` viejo justo despues de limpiar. El delay de duracion cero
/// corre despues de que la cola de microtasks drena por completo, asi que
/// vacia el reset pendiente sin importar cuantos saltos encadene.
Future<void> resetInjector() async {
  Injector.i.clear();
  await Future<void>.delayed(Duration.zero);
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
