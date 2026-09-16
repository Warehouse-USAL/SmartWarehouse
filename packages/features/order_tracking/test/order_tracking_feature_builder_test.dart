import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/pages/notifications_page.dart';
import 'package:order_tracking/src/presentation/pages/order_detail_page.dart';
import 'package:order_tracking/src/presentation/pages/order_list_page.dart';
import 'package:order_tracking/src/presentation/widgets/notification_bell.dart';
import 'package:test_support/test_support.dart';

import 'support/fake_order_tracking_repository.dart';

/// `pushNamed` recibe un `BuildContext` posicional; mocktail necesita un valor
/// de fallback para poder matchearlo con `any()`.
class _FakeBuildContext extends Fake implements BuildContext {}

class _FakeHistoryStore implements OrderHistoryStore {
  List<String> ids = const [];

  @override
  Future<List<String>> getOrderIds() async => ids;

  @override
  Future<void> addOrderId(String id) async => ids = [id, ...ids];

  @override
  Future<void> clear() async => ids = const [];
}

/// Registra todo lo que `injectDependencies` resuelve, menos el AppDataSource,
/// que cada test elige para ejercitar la rama mock o la remota.
void _registerCollaborators() {
  registerMock<HttpHelper>(MockHttpHelper());
  registerMock<OrderHistoryStore>(_FakeHistoryStore());
  registerMock<CatalogRepository>(FakeCatalogRepository());
  registerMock<NavigationHelper>(MockNavigationHelper());
}

/// Inyecta la feature con la rama mock y devuelve el repositorio concreto que
/// quedo registrado.
///
/// Es el mismo objeto al que escucha el `OrderNotificationCubit`: el builder
/// lo registra como lazy singleton y lo resuelve al construir el cubit, asi
/// que empujar por `emitStatusChange` dispara el callback `onEvent` real —
/// que es justamente el `_showOrderSnackBar` privado que queremos cubrir.
MockOrderTrackingRepository _injectWithMockSource() {
  _registerCollaborators();
  registerMock<AppDataSource>(const AppDataSource.mock());
  OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');
  return Injector.i.resolve<OrderTrackingRepository>()
      as MockOrderTrackingRepository;
}

Widget _appWithMessenger() => MaterialApp(
      scaffoldMessengerKey: OrderTrackingFeatureBuilder.scaffoldMessengerKey,
      home: const Scaffold(body: SizedBox()),
    );

/// Cierra el cubit global y el repo para no dejar suscripciones ni timers
/// colgando entre tests.
Future<void> _tearDownFeature(MockOrderTrackingRepository repo) async {
  await Injector.i.resolve<OrderNotificationCubit>().close();
  repo.dispose();
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeBuildContext()));

  setUp(resetInjector);

  group('injectDependencies', () {
    test('con AppDataSource.mock registra el repositorio en memoria', () {
      _registerCollaborators();
      registerMock<AppDataSource>(const AppDataSource.mock());

      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      expect(
        Injector.i.resolve<OrderTrackingRepository>(),
        isA<MockOrderTrackingRepository>(),
      );
    });

    test('con AppDataSource.remote registra el repositorio remoto', () {
      _registerCollaborators();
      registerMock<AppDataSource>(const AppDataSource.remote());

      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      final repo = Injector.i.resolve<OrderTrackingRepository>();
      expect(repo, isA<RemoteOrderTrackingRepository>());
      expect((repo as RemoteOrderTrackingRepository).baseUrl, 'http://x');
    });

    test('registra tambien los dos cubits', () {
      _registerCollaborators();
      registerMock<AppDataSource>(const AppDataSource.mock());

      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      expect(Injector.i.resolve<OrderListCubit>(), isA<OrderListCubit>());
      expect(
        Injector.i.resolve<OrderNotificationCubit>(),
        isA<OrderNotificationCubit>(),
      );
    });
  });

  group('factories de widgets', () {
    test('buildNotificationBell devuelve una NotificationBell', () {
      expect(
        OrderTrackingFeatureBuilder.buildNotificationBell(),
        isA<NotificationBell>(),
      );
    });

    test('buildNotificationsPage devuelve la NotificationsPage', () {
      expect(
        OrderTrackingFeatureBuilder.buildNotificationsPage(),
        isA<NotificationsPage>(),
      );
    });

    test('buildOrderListPage usa el OrderListCubit registrado', () async {
      final repo = _injectWithMockSource();

      final page = OrderTrackingFeatureBuilder.buildOrderListPage();

      expect(page, isA<OrderListPage>());
      expect(
        (page as OrderListPage).cubit,
        same(Injector.i.resolve<OrderListCubit>()),
      );

      await _tearDownFeature(repo);
    });

    test('buildOrderDetailPage propaga el id de la orden', () async {
      final repo = _injectWithMockSource();

      final page = OrderTrackingFeatureBuilder.buildOrderDetailPage('WH-49202');

      expect(page, isA<OrderDetailPage>());
      expect((page as OrderDetailPage).orderId, 'WH-49202');

      await _tearDownFeature(repo);
    });
  });

  group('startNotifications', () {
    test('arranca el listener del cubit registrado', () async {
      final repo = FakeOrderTrackingRepository();
      final cubit = OrderNotificationCubit(repo);
      registerMock<OrderNotificationCubit>(cubit);

      OrderTrackingFeatureBuilder.startNotifications();
      repo.statusChangeController.add(const OrderStatusChange(
        orderId: 'o-1',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.inProgress,
      ));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.notifications, hasLength(1));

      await cubit.close();
      await repo.dispose();
    });
  });

  group('SnackBar de cambio de estado', () {
    test('ignora el evento cuando todavia no hay messenger montado', () async {
      final repo = _injectWithMockSource();
      // El guard `if (messenger == null) return;` es el camino que corre
      // cuando llega un evento del WS antes de que el arbol este montado.
      expect(
        OrderTrackingFeatureBuilder.scaffoldMessengerKey.currentState,
        isNull,
      );

      OrderTrackingFeatureBuilder.startNotifications();
      repo.emitStatusChange(const OrderStatusChange(
        orderId: 'WH-49281',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.completed,
      ));
      await Future<void>.delayed(Duration.zero);

      // La notificacion llego al cubit igual: solo se salteo la SnackBar.
      expect(
        Injector.i.resolve<OrderNotificationCubit>().state.notifications,
        hasLength(1),
      );

      await _tearDownFeature(repo);
    });

    testWidgets('muestra el id y el estado nuevo cuando hay messenger',
        (tester) async {
      final repo = _injectWithMockSource();

      await tester.pumpWidget(_appWithMessenger());

      OrderTrackingFeatureBuilder.startNotifications();
      repo.emitStatusChange(const OrderStatusChange(
        orderId: 'WH-49281',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.completed,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('WH-49281'), findsOneWidget);
      expect(find.text('Completado'), findsOneWidget);
      expect(find.text('Ver'), findsOneWidget);

      await _tearDownFeature(repo);
    });

    testWidgets('traduce cada estado nuevo a su etiqueta en castellano',
        (tester) async {
      final repo = _injectWithMockSource();

      await tester.pumpWidget(_appWithMessenger());
      OrderTrackingFeatureBuilder.startNotifications();

      const labels = <OrderStatus, String>{
        OrderStatus.pending: 'Pendiente',
        OrderStatus.inProgress: 'En progreso',
        OrderStatus.completed: 'Completado',
        OrderStatus.cancelled: 'Cancelado',
      };

      for (final entry in labels.entries) {
        repo.emitStatusChange(OrderStatusChange(
          orderId: 'WH-1',
          oldStatus: OrderStatus.pending,
          newStatus: entry.key,
        ));
        await tester.pump();
        await tester.pump();

        expect(
          find.text(entry.value),
          findsOneWidget,
          reason: 'faltaba la etiqueta de ${entry.key}',
        );
      }

      await _tearDownFeature(repo);
    });

    testWidgets('el boton Ver navega al detalle de esa orden', (tester) async {
      final repo = _injectWithMockSource();

      await tester.pumpWidget(_appWithMessenger());

      OrderTrackingFeatureBuilder.startNotifications();
      repo.emitStatusChange(const OrderStatusChange(
        orderId: 'WH-49281',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.completed,
      ));
      await tester.pump();
      await tester.pump();
      // La SnackBar entra con un IgnorePointer mientras dura la animacion de
      // entrada: sin adelantar el reloj el tap cae en el vacio. No se usa
      // pumpAndSettle porque la SnackBar vive 5 segundos y nunca se asienta.
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Ver'));
      await tester.pump();

      final nav = Injector.i.resolve<NavigationHelper>();
      verify(
        () => nav.pushNamed(any(), routeName: Routes.orderDetail('WH-49281')),
      ).called(1);

      await _tearDownFeature(repo);
    });
  });
}
