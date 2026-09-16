import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_tracking/src/presentation/widgets/notification_bell.dart';
import 'package:test_support/test_support.dart';

import '../../support/fake_order_tracking_repository.dart';

OrderStatusChange _change(String orderId) => OrderStatusChange(
      orderId: orderId,
      oldStatus: OrderStatus.pending,
      newStatus: OrderStatus.inProgress,
    );

void main() {
  late FakeOrderTrackingRepository repo;
  late OrderNotificationCubit cubit;
  late MockNavigationHelper nav;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    // `SwText.body` (el numero del badge) se construye sobre `google_fonts`;
    // sin apagar `allowRuntimeFetching` el widget intenta bajar la tipografia
    // por red durante el test (mismo patron que
    // `design_system/test/support/harness.dart` y
    // `bottom_navigation_bar/test/support/harness.dart`). `order_tracking` no
    // declara `google_fonts` en su propio pubspec (es transitivo via
    // `design_system`), de ahi el `ignore` en el import de arriba.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    await resetInjector();
    repo = FakeOrderTrackingRepository();
    cubit = OrderNotificationCubit(repo)..start();
    registerMock<OrderNotificationCubit>(cubit);
    nav = registerMock<NavigationHelper>(MockNavigationHelper()) as MockNavigationHelper;
    when(() => nav.pushNamed(
          any(),
          routeName: any(named: 'routeName'),
          disableAnimation: any(named: 'disableAnimation'),
        )).thenReturn(null);
  });

  tearDown(() async {
    await cubit.close();
    await repo.dispose();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationBell())),
      );

  /// Empuja [count] cambios de estado por el stream fake del repositorio.
  ///
  /// El `StreamController.broadcast()` de [FakeOrderTrackingRepository] entrega
  /// sus eventos a los listeners via una tarea real (no solo microtasks), y
  /// `tester.pump()` no la drena por si solo dentro de `testWidgets` -> el
  /// `BlocBuilder` se queda mostrando el estado viejo aunque `cubit.state` ya
  /// haya cambiado. `tester.runAsync` sale del reloj falso del test el tiempo
  /// justo para que esa entrega real ocurra antes del siguiente pump.
  Future<void> push(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      repo.statusChangeController.add(_change('o-$i'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
  }

  testWidgets('sin no-leidas no dibuja el badge', (tester) async {
    await pump(tester);

    expect(find.text('0'), findsNothing);
  });

  testWidgets('con una no-leida muestra el numero', (tester) async {
    await pump(tester);
    await push(tester, 1);

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('con nueve no-leidas todavia muestra el numero exacto',
      (tester) async {
    await pump(tester);
    await push(tester, 9);

    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('a partir de diez muestra 9+', (tester) async {
    await pump(tester);
    await push(tester, 10);

    expect(find.text('9+'), findsOneWidget);
    expect(find.text('10'), findsNothing);
  });

  testWidgets('marcar todas como leidas esconde el badge', (tester) async {
    await pump(tester);
    await push(tester, 3);
    expect(find.text('3'), findsOneWidget);

    cubit.markAllAsRead();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    // `find.text('3')` por si sola pasaria igual si quedara, por ejemplo, 1
    // no-leida de las 3 (mostraria '1', no '3'). `Positioned` es el badge
    // completo -- solo existe en el arbol cuando `unreadCount > 0` -- asi que
    // su ausencia es la prueba real de que no quedo ningun digito.
    expect(find.text('3'), findsNothing);
    expect(find.byType(Positioned), findsNothing);
  });

  testWidgets('el tap navega a notificaciones', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(SwIconButton));
    await tester.pump();

    verify(() => nav.pushNamed(
          any(),
          routeName: Routes.notifications,
          disableAnimation: false,
        )).called(1);
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
