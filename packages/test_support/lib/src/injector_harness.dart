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
