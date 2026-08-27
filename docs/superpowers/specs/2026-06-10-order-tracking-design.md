# Order Tracking — Design Spec

**Fecha:** 2026-06-10  
**Feature:** Seguimiento de órdenes del usuario  
**Status:** Approved — listo para plan de implementación

---

## 1. Goal

Lista de órdenes del usuario ordenadas por fecha, y pantalla de detalle con timeline de estados actualizado en tiempo real vía WebSocket.

**Definition of Done:**

- Usuario ve lista de sus órdenes ordenadas por fecha descendente.
- Estado cambia en tiempo real cuando el backend emite `order.updated`.
- Reconexión transparente al perder señal (sin intervención del usuario).
- Se muestran 4 estados: `pending`, `in_progress`, `completed`, `cancelled`.

---

## 2. Cambios en el package `orders` existente

### 2.1 `OrderStatus` — reemplazar enum

El enum actual (`pending, confirmed, shipped, delivered, cancelled`) se reemplaza por los 4 estados del DOD:

```dart
enum OrderStatus { pending, inProgress, completed, cancelled }
```

### 2.2 Mapper actualizado

```
backend string       → OrderStatus
─────────────────────────────────
"pending"          → pending
"in_progress"      → inProgress
"confirmed"        → inProgress
"shipped"          → inProgress
"completed"        → completed
"delivered"        → completed
"cancelled"        → cancelled
(default)          → pending
```

El resto del código que consume `OrderStatus` (create flow, success page) no depende de los valores específicos del enum, por lo que este cambio es seguro.

---

## 3. Nuevo package `order_tracking`

### 3.1 Ubicación y dependencias

```
packages/features/order_tracking/
```

`pubspec.yaml` dependencies:
- `flutter`, `flutter_bloc`, `freezed_annotation`, `json_annotation`, `dartz`
- `commons` (path: `../../commons`) — HttpHelper, Injector
- `core` (path: `../../core`) — AppDataSource, NavigationHelper, Routes
- `design_system` (path: `../../design_system`)
- `orders` (path: `../orders`) — Order, OrderStatus, OrderItem, Money
- `web_socket_channel: ^3.0.1`

`build.yaml`: `field_rename: snake` (igual que los otros features).

### 3.2 Estructura de archivos

```
lib/
├── order_tracking.dart                          ← barrel
└── src/
    ├── order_tracking_feature_builder.dart
    ├── domain/
    │   └── repositories/
    │       └── order_tracking_repository.dart   ← interfaz + failure
    ├── data/
    │   ├── dtos/
    │   │   ├── order_list_response_dto.dart      ← { orders: [OrderDto] }
    │   │   ├── order_tracking_detail_dto.dart    ← { order: OrderDto }
    │   │   └── ws_order_event_dto.dart           ← { event, payload: { order_id, status } }
    │   ├── mappers/
    │   │   └── order_tracking_mapper.dart        ← extension methods
    │   └── repositories/
    │       ├── mock_order_tracking_repository.dart
    │       └── remote_order_tracking_repository.dart
    └── presentation/
        ├── bloc/
        │   ├── order_list_cubit.dart
        │   ├── order_list_state.dart
        │   ├── order_detail_cubit.dart
        │   └── order_detail_state.dart
        ├── pages/
        │   ├── order_list_page.dart
        │   └── order_detail_page.dart
        └── widgets/
            ├── order_card.dart
            └── order_status_timeline.dart
```

---

## 4. Dominio

```dart
abstract class OrderTrackingRepository {
  /// GET /orders — lista de órdenes del usuario autenticado, sin paginación.
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders();

  /// GET /orders/:id — detalle de una orden.
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id);

  /// Stream en tiempo real de una orden vía WebSocket.
  /// Al suscribirse: hace REST fetch primero, luego escucha WS.
  /// Reconexión transparente con backoff exponencial.
  Stream<Order> watchOrder(String id);
}

class OrderTrackingFailure {
  const OrderTrackingFailure([this.message]);
  final String? message;
}
```

No hay nuevas entities de dominio. `Order`, `OrderStatus`, `OrderItem`, `Money` vienen de `orders`.

---

## 5. DTOs

### `OrderListResponseDto`
```json
{
  "orders": [ ...OrderDto ]
}
```

### `OrderTrackingDetailDto`
```json
{
  "order": { ...OrderDto }
}
```

### `WsOrderEventDto`
```json
{
  "event": "order.updated",
  "payload": {
    "order_id": "abc123",
    "status": "in_progress"
  }
}
```

Los tres son `@freezed` con `factory fromJson`. Reutilizan `OrderDto` de `orders`.

---

## 6. Implementaciones de repositorio

### `RemoteOrderTrackingRepository`

**`getOrders()`**
```
GET /orders
Authorization: Bearer <token>
→ OrderListResponseDto.fromJson → list.map(dto.toEntity(fallbackItems: []))
```

**`getOrderById(id)`**
```
GET /orders/:id
Authorization: Bearer <token>
→ OrderTrackingDetailDto.fromJson → dto.order.toEntity(fallbackItems: [])
```

> Nota: el mapper de `orders` requiere `fallbackItems` porque el backend no devuelve precios en órdenes. En el contexto de tracking esto es aceptable — se muestra el total como $0 o se omite si no está disponible. El equipo de backend debe evaluar incluir precios en este endpoint.

**`watchOrder(id)`**

Ciclo de vida:
1. Conectar `WebSocketChannel` a `ws://<host>/ws?token=<JWT>`
2. Llamar `GET /orders/:id` y emitir al `StreamController` (estado al conectar)
3. Escuchar mensajes del canal; deserializar `WsOrderEventDto`; ignorar eventos con `event != "order.updated"` o `payload.order_id != id`
4. En cada evento válido: llamar `GET /orders/:id` para obtener la entidad completa y emitir
5. Si el canal cierra: backoff exponencial (1 s → 2 s → 4 s → 8 s → 30 s tope), volver a paso 1
6. Al cancelar la suscripción: cerrar el canal y el `StreamController`

El token se obtiene via `TokenRepository` (ya inyectado en commons).

### `MockOrderTrackingRepository`

- `getOrders()`: devuelve lista hardcodeada de 5 órdenes con estados variados.
- `getOrderById(id)`: busca en la lista hardcodeada.
- `watchOrder(id)`: usa `StreamController<Order>`; emite el estado inicial del mock inmediatamente. La referencia al controller se expone para que tests y modo demo puedan inyectar updates manuales.

---

## 7. Presentación

### `OrderListCubit`

```dart
sealed class OrderListState { const OrderListState(); }
class OrderListLoading extends OrderListState { const OrderListLoading(); }
class OrderListError  extends OrderListState { const OrderListError(this.message); final String message; }
class OrderListReady  extends OrderListState {
  const OrderListReady({ required this.orders });
  final List<Order> orders;  // ordenadas por createdAt desc
}
```

Métodos públicos: `load()` (llamado en constructor), `refresh()`.

### `OrderDetailCubit`

```dart
sealed class OrderDetailState { const OrderDetailState(); }
class OrderDetailLoading extends OrderDetailState { const OrderDetailLoading(); }
class OrderDetailError   extends OrderDetailState { const OrderDetailError(this.message); final String message; }
class OrderDetailReady   extends OrderDetailState {
  const OrderDetailReady({ required this.order });
  final Order order;
}
```

Expone `load(String orderId)`, llamado desde `buildOrderDetailPage`. Internamente llama `repository.watchOrder(orderId)`, guarda la `StreamSubscription` y la cancela en `close()`. El estado inicial es `OrderDetailLoading`.

### Pages

- **`OrderListPage`**: BlocBuilder sobre `OrderListCubit`. Loading skeleton → lista de `OrderCard` → empty state si vacía.
- **`OrderDetailPage`**: BlocBuilder sobre `OrderDetailCubit`. Muestra `OrderStatusTimeline` en la parte superior + lista de items con SKU, qty y precio.

### Widgets

- **`OrderCard`**: número de orden (formato `WH-XXXXX`), fecha `createdAt` formateada, badge de `OrderStatus` con color semántico, total (si `Money.amount == 0` muestra `"-"` — el backend no siempre incluye precios en el endpoint de lista).
  - Colores de badge: `pending` → amarillo, `in_progress` → azul, `completed` → verde, `cancelled` → gris.
- **`OrderStatusTimeline`**: 4 nodos en fila con líneas conectoras. Nodos completados: ícono de check + timestamp. Nodo activo: resaltado con `SwColors.yellow`. Nodos futuros: gris. Compatible con estado `cancelled` (todos los nodos posteriores al punto de cancelación quedan grises).

---

## 8. Navegación

### Nuevas rutas en `core/Routes`

```dart
static const String orders = '/orders';
static const String orderDetailPattern = '/orders/:id';
static String orderDetail(String id) => '/orders/$id';
```

### `OrderTrackingFeatureBuilder`

```dart
class OrderTrackingFeatureBuilder {
  static void injectDependencies() {
    Injector.i.registerLazySingleton<OrderTrackingRepository>(
      () => Injector.i.resolve<AppDataSource>().isMock
          ? MockOrderTrackingRepository()
          : RemoteOrderTrackingRepository(
              httpHelper: Injector.i.resolve<HttpHelper>(),
              tokenRepository: Injector.i.resolve<TokenRepository>(),
            ),
    );
    // OrderDetailCubit: factory (no singleton) porque cada instancia lleva un orderId.
    Injector.i.registerFactory<OrderDetailCubit>(
      () => OrderDetailCubit(Injector.i.resolve<OrderTrackingRepository>()),
    );
    Injector.i.registerLazySingleton<OrderListCubit>(
      () => OrderListCubit(Injector.i.resolve<OrderTrackingRepository>()),
    );
  }

  static Widget buildOrderListPage() =>
      OrderListPage(cubit: Injector.i.resolve<OrderListCubit>());

  static Widget buildOrderDetailPage(String orderId) {
    final cubit = Injector.i.resolve<OrderDetailCubit>()..load(orderId);
    return OrderDetailPage(cubit: cubit);
  }
}
```

### `BeamerConfigHelper` — rutas a agregar

```dart
Routes.orders: (_, __, ___) => _beamerPage(
  title: 'Mis órdenes',
  key: 'orders',
  child: OrderTrackingFeatureBuilder.buildOrderListPage(),
),
Routes.orderDetailPattern: (_, state, __) {
  final id = state.pathParameters['id'] ?? '';
  return _beamerPage(
    title: 'Detalle de orden',
    key: 'order-detail-$id',
    child: OrderTrackingFeatureBuilder.buildOrderDetailPage(id),
  );
},
```

La tab "Orders" del `BottomNavigationBar` navega a `Routes.orders`.

---

## 9. API contracts nuevos requeridos (para el backend)

Estos endpoints no están en `docs/superpowers/specs/2026-05-19-api-contracts-design.md` y deben coordinarse con el equipo de backend:

| Método | Path | Descripción |
|--------|------|-------------|
| `GET` | `/orders` | Lista órdenes del usuario autenticado, sin paginación |
| `GET` | `/orders/:id` | Detalle de una orden |
| `WS` | `ws://<host>/ws?token=<JWT>` | Conexión existente, event `order.updated` |

Payload esperado de `order.updated`:
```json
{ "event": "order.updated", "payload": { "order_id": "abc123", "status": "in_progress" } }
```

---

## 10. Tests mínimos requeridos

| Archivo | Qué cubre |
|---------|-----------|
| `test/data/mappers/order_tracking_mapper_test.dart` | JSON golden de `OrderListResponseDto`, `WsOrderEventDto` |
| `test/data/repositories/remote_order_tracking_repository_test.dart` | Parsing de lista y detalle con fake HttpHelper |
| `test/presentation/bloc/order_list_cubit_test.dart` | `load()` emite Loading → Ready; error del repo emite Error |
| `test/presentation/bloc/order_detail_cubit_test.dart` | Stream emite Ready en cada update; `close()` cancela suscripción |

---

## 11. Out of scope (esta iteración)

- Paginación de la lista de órdenes
- Filtros por estado en la lista
- Push notifications para cambios de estado
- Infraestructura WS compartida con vehicle tracking (a refactorizar cuando llegue esa feature)
