import 'package:cart/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_support/test_support.dart';

/// Monta [child] dentro de un `MaterialApp` listo para testear componentes de
/// este package.
///
/// `SwBottomNav` tipografía con `SwText`, que se construye sobre `google_fonts`.
/// Sin apagar `allowRuntimeFetching` el widget intenta bajar la fuente por red
/// durante el test.
Future<void> pumpNav(WidgetTester tester, Widget child) async {
  await pumpBare(tester, Scaffold(body: child));
}

/// Igual que [pumpNav] pero sin envolver en un `Scaffold`.
///
/// Lo usa `BottomNavigationScaffold`, que construye el suyo: anidarlos haría
/// que `find.byType(AppBar)` y compañía encuentren el del harness y no el del
/// widget bajo test.
Future<void> pumpBare(WidgetTester tester, Widget child) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
}

/// Avanza los frames necesarios para que un `emit` del cubit se vea renderizado.
///
/// Hacen falta **dos** pumps, no uno. El primero corre el `emit` y drena las
/// microtasks, pero la notificación viaja por el stream del bloc y el
/// `setState` del `BlocBuilder` queda para después de ese frame; el segundo
/// pump es el que construye el widget con el estado nuevo. Con un solo pump el
/// test lee el valor viejo y parece que el componente no reacciona.
Future<void> pumpBloc(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

/// Registra las dependencias reales del carrito para los tests.
///
/// Se usa el `CartCubit` real sobre `InMemoryCartRepository` en lugar de un
/// mock: `BottomNavigationComponent` lee `cart.itemCount`, que suma cantidades
/// en vez de contar items. Con un mock habría que stubbear ese valor a mano y
/// el test dejaría de distinguir `itemCount` de `items.length` — justo lo que
/// se quiere proteger.
void injectCart() => CartFeatureBuilder.injectDependencies();

/// Limpia el [Injector] global entre tests. Llamar desde `tearDown`.
///
/// Delega en [resetInjector] de `test_support`, que hace el pump de la cola de
/// microtasks necesario porque `clear()` descarta el Future de `GetIt.reset()`.
Future<void> disposeCart() => resetInjector();
