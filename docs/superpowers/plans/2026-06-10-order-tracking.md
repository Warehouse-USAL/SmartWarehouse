# Order Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar lista de órdenes del usuario y detalle con timeline de estados actualizado en tiempo real vía WebSocket.

**Architecture:** Nuevo package `order_tracking` (Clean Architecture: domain → data → presentation). El repositorio encapsula tanto REST como WebSocket; el cubit se suscribe a `watchOrder()` sin saber que existe un socket. `OrderStatus` en el package `orders` se actualiza a los 4 estados del DOD.

**Tech Stack:** Flutter, flutter_bloc (Cubit), freezed + json_serializable, dartz (Either), web_socket_channel, Beamer.

**Spec:** `docs/superpowers/specs/2026-06-10-order-tracking-design.md`

---

## File Map

### Cambios en `packages/features/orders/`
| Acción | Archivo |
|--------|---------|
| Modify | `lib/src/domain/entities/order_status.dart` |
| Modify | `lib/src/data/mappers/order_mapper.dart` |
| Modify | `test/data/mappers/order_mapper_test.dart` |

### Nuevo package `packages/features/order_tracking/`
| Acción | Archivo |
|--------|---------|
| Create | `pubspec.yaml` |
| Create | `build.yaml` |
| Create | `lib/order_tracking.dart` |
| Create | `lib/src/domain/repositories/order_tracking_repository.dart` |
| Create | `lib/src/data/dtos/order_list_response_dto.dart` |
| Create | `lib/src/data/dtos/order_tracking_item_dto.dart` |
| Create | `lib/src/data/dtos/order_tracking_line_item_dto.dart` |
| Create | `lib/src/data/dtos/order_tracking_detail_response_dto.dart` |
| Create | `lib/src/data/dtos/ws_order_event_dto.dart` |
| Create | `lib/src/data/dtos/ws_order_payload_dto.dart` |
| Create | `lib/src/data/mappers/order_tracking_mapper.dart` |
| Create | `lib/src/data/repositories/mock_order_tracking_repository.dart` |
| Create | `lib/src/data/repositories/remote_order_tracking_repository.dart` |
| Create | `lib/src/presentation/bloc/order_list_cubit.dart` |
| Create | `lib/src/presentation/bloc/order_list_state.dart` |
| Create | `lib/src/presentation/bloc/order_detail_cubit.dart` |
| Create | `lib/src/presentation/bloc/order_detail_state.dart` |
| Create | `lib/src/presentation/pages/order_list_page.dart` |
| Create | `lib/src/presentation/pages/order_detail_page.dart` |
| Create | `lib/src/presentation/widgets/order_card.dart` |
| Create | `lib/src/presentation/widgets/order_status_timeline.dart` |
| Create | `lib/src/order_tracking_feature_builder.dart` |
| Create | `test/data/mappers/order_tracking_mapper_test.dart` |
| Create | `test/data/repositories/remote_order_tracking_repository_test.dart` |
| Create | `test/presentation/bloc/order_list_cubit_test.dart` |
| Create | `test/presentation/bloc/order_detail_cubit_test.dart` |

### Cambios en el app shell
| Acción | Archivo |
|--------|---------|
| Modify | `packages/core/lib/src/navigation/routes.dart` |
| Modify | `packages/core/pubspec.yaml` |
| Modify | `packages/core/lib/core.dart` |
| Modify | `lib/config/ioc_manager.dart` |
| Modify | `lib/application/navigation/beamer_config_helper.dart` |
| Modify | `packages/features/bottom_navigation_bar/lib/src/bottom_navigation_bar_feature_builder.dart` |
| Modify | `packages/features/orders/lib/src/presentation/pages/order_success_page.dart` |

---

## Task 1: Actualizar `OrderStatus` en `orders`

**Files:**
- Modify: `packages/features/orders/lib/src/domain/entities/order_status.dart`
- Modify: `packages/features/orders/lib/src/data/mappers/order_mapper.dart`
- Modify: `packages/features/orders/test/data/mappers/order_mapper_test.dart`

- [ ] **Step 1: Actualizar el enum**

Reemplazar el contenido de `packages/features/orders/lib/src/domain/entities/order_status.dart`:

```dart
enum OrderStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}
```

- [ ] **Step 2: Actualizar `_parseStatus` en el mapper**

En `packages/features/orders/lib/src/data/mappers/order_mapper.dart`, reemplazar la función `_parseStatus`:

```dart
OrderStatus _parseStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'in_progress':
    case 'confirmed':
    case 'shipped':
      return OrderStatus.inProgress;
    case 'completed':
    case 'delivered':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}
```

- [ ] **Step 3: Actualizar el test del mapper**

Reemplazar el contenido de `packages/features/orders/test/data/mappers/order_mapper_test.dart`:

```dart
import 'package:catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/src/data/dtos/order_response_dto.dart';
import 'package:orders/src/data/mappers/order_mapper.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/entities/order_status.dart';

void main() {
  group('OrderDtoMapper.toEntity', () {
    test('maps PENDING status', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'ord-1', 'status': 'PENDING', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).status, OrderStatus.pending);
    });

    test('maps in_progress status to inProgress', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'ord-1', 'status': 'in_progress', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).status, OrderStatus.inProgress);
    });

    test('maps confirmed status to inProgress (backward compat)', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'ord-1', 'status': 'confirmed', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).status, OrderStatus.inProgress);
    });

    test('maps shipped status to inProgress (backward compat)', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'ord-1', 'status': 'shipped', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).status, OrderStatus.inProgress);
    });

    test('maps completed status', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'ord-1', 'status': 'completed', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).status, OrderStatus.completed);
    });

    test('maps delivered status to completed (backward compat)', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'ord-1', 'status': 'delivered', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).status, OrderStatus.completed);
    });

    test('maps cancelled status', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'ord-1', 'status': 'cancelled', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).status, OrderStatus.cancelled);
    });

    test('parses created order response and uses fallbackItems for totals', () {
      final json = <String, dynamic>{
        'order': {
          'id': 'order-1',
          'status': 'PENDING',
          'items': [
            {'product_id': 'p1', 'sku': 'SKU-1', 'quantity': 2},
          ],
          'destination_area': 'Bay 14',
          'timestamps': {
            'created_at': '2026-06-03T21:14:14.900019429Z',
          },
        },
      };
      final fallback = [
        OrderItem(
          productId: 'p1',
          productName: 'Casco',
          quantity: 2,
          unitPrice: const Money(amount: 1250000, currency: 'ARS'),
        ),
      ];
      final dto = OrderResponseDto.fromJson(json);
      final entity = dto.order.toEntity(fallbackItems: fallback);
      expect(entity.id, 'order-1');
      expect(entity.status, OrderStatus.pending);
      expect(entity.total.amount, 2500000);
    });

    test('uses now() when timestamps.created_at is missing', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'x', 'status': 'PENDING', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).createdAt, isNotNull);
    });
  });
}
```

- [ ] **Step 4: Correr tests**

```bash
cd packages/features/orders && flutter test
```

Esperado: todos los tests pasan.

- [ ] **Step 5: Correr analyze**

```bash
cd packages/features/orders && dart analyze
```

Esperado: no issues.

- [ ] **Step 6: Commit**

```bash
git add packages/features/orders/lib/src/domain/entities/order_status.dart \
        packages/features/orders/lib/src/data/mappers/order_mapper.dart \
        packages/features/orders/test/data/mappers/order_mapper_test.dart
git commit -m "feat(orders): update OrderStatus to 4 DOD states (pending/inProgress/completed/cancelled)"
```

---

## Task 2: Bootstrap del package `order_tracking`

**Files:**
- Create: `packages/features/order_tracking/pubspec.yaml`
- Create: `packages/features/order_tracking/build.yaml`
- Create: `packages/features/order_tracking/lib/order_tracking.dart`

- [ ] **Step 1: Crear directorios**

```bash
mkdir -p packages/features/order_tracking/lib/src/domain/repositories
mkdir -p packages/features/order_tracking/lib/src/data/dtos
mkdir -p packages/features/order_tracking/lib/src/data/mappers
mkdir -p packages/features/order_tracking/lib/src/data/repositories
mkdir -p packages/features/order_tracking/lib/src/presentation/bloc
mkdir -p packages/features/order_tracking/lib/src/presentation/pages
mkdir -p packages/features/order_tracking/lib/src/presentation/widgets
mkdir -p packages/features/order_tracking/test/data/mappers
mkdir -p packages/features/order_tracking/test/data/repositories
mkdir -p packages/features/order_tracking/test/presentation/bloc
```

- [ ] **Step 2: Crear `pubspec.yaml`**

Crear `packages/features/order_tracking/pubspec.yaml`:

```yaml
name: order_tracking
description: "Order tracking: list orders and real-time status updates via WebSocket."
version: 0.0.1
publish_to: none

environment:
  sdk: '>=3.8.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  commons:
    path: ../../commons
  core:
    path: ../../core
  design_system:
    path: ../../design_system
  orders:
    path: ../orders
  dartz: ^0.10.1
  flutter_bloc: ^9.1.1
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0
  web_socket_channel: ^3.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  freezed: ^3.2.5
  json_serializable: ^6.9.0
```

- [ ] **Step 3: Crear `build.yaml`**

Crear `packages/features/order_tracking/build.yaml`:

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          field_rename: snake
          explicit_to_json: true
```

- [ ] **Step 4: Crear barrel**

Crear `packages/features/order_tracking/lib/order_tracking.dart`:

```dart
library order_tracking;

export 'src/order_tracking_feature_builder.dart';
```

- [ ] **Step 5: Correr melos bootstrap**

Desde la raíz del monorepo:

```bash
melos bootstrap
```

Esperado: se resuelven dependencias y se crea `pubspec_overrides.yaml` en el package.

- [ ] **Step 6: Verificar que compila**

```bash
cd packages/features/order_tracking && dart analyze
```

Esperado: puede haber warnings de archivos vacíos/faltantes — se resuelven en las siguientes tareas.

---

## Task 3: DTOs + code generation

**Files:**
- Create: `lib/src/data/dtos/order_tracking_line_item_dto.dart`
- Create: `lib/src/data/dtos/order_tracking_item_dto.dart`
- Create: `lib/src/data/dtos/order_list_response_dto.dart`
- Create: `lib/src/data/dtos/order_tracking_detail_response_dto.dart`
- Create: `lib/src/data/dtos/ws_order_payload_dto.dart`
- Create: `lib/src/data/dtos/ws_order_event_dto.dart`

Todos los paths siguientes son relativos a `packages/features/order_tracking/`.

- [ ] **Step 1: `order_tracking_line_item_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_tracking_line_item_dto.freezed.dart';
part 'order_tracking_line_item_dto.g.dart';

@freezed
sealed class OrderTrackingLineItemDto with _$OrderTrackingLineItemDto {
  const factory OrderTrackingLineItemDto({
    required String productId,
    String? name,
    @Default(0) int quantity,
  }) = _OrderTrackingLineItemDto;

  factory OrderTrackingLineItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingLineItemDtoFromJson(json);
}
```

- [ ] **Step 2: `order_tracking_item_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_line_item_dto.dart';

part 'order_tracking_item_dto.freezed.dart';
part 'order_tracking_item_dto.g.dart';

@freezed
sealed class OrderTrackingItemDto with _$OrderTrackingItemDto {
  const factory OrderTrackingItemDto({
    required String id,
    required String status,
    @Default([]) List<OrderTrackingLineItemDto> items,
    String? createdAt,
  }) = _OrderTrackingItemDto;

  factory OrderTrackingItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingItemDtoFromJson(json);
}
```

- [ ] **Step 3: `order_list_response_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';

part 'order_list_response_dto.freezed.dart';
part 'order_list_response_dto.g.dart';

@freezed
sealed class OrderListResponseDto with _$OrderListResponseDto {
  const factory OrderListResponseDto({
    @Default([]) List<OrderTrackingItemDto> orders,
  }) = _OrderListResponseDto;

  factory OrderListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderListResponseDtoFromJson(json);
}
```

- [ ] **Step 4: `order_tracking_detail_response_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';

part 'order_tracking_detail_response_dto.freezed.dart';
part 'order_tracking_detail_response_dto.g.dart';

@freezed
sealed class OrderTrackingDetailResponseDto with _$OrderTrackingDetailResponseDto {
  const factory OrderTrackingDetailResponseDto({
    required OrderTrackingItemDto order,
  }) = _OrderTrackingDetailResponseDto;

  factory OrderTrackingDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingDetailResponseDtoFromJson(json);
}
```

- [ ] **Step 5: `ws_order_payload_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ws_order_payload_dto.freezed.dart';
part 'ws_order_payload_dto.g.dart';

@freezed
sealed class WsOrderPayloadDto with _$WsOrderPayloadDto {
  const factory WsOrderPayloadDto({
    required String orderId,
    required String status,
  }) = _WsOrderPayloadDto;

  factory WsOrderPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$WsOrderPayloadDtoFromJson(json);
}
```

- [ ] **Step 6: `ws_order_event_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order_tracking/src/data/dtos/ws_order_payload_dto.dart';

part 'ws_order_event_dto.freezed.dart';
part 'ws_order_event_dto.g.dart';

@freezed
sealed class WsOrderEventDto with _$WsOrderEventDto {
  const factory WsOrderEventDto({
    required String event,
    required WsOrderPayloadDto payload,
  }) = _WsOrderEventDto;

  factory WsOrderEventDto.fromJson(Map<String, dynamic> json) =>
      _$WsOrderEventDtoFromJson(json);
}
```

- [ ] **Step 7: Generar código Freezed/JSON**

```bash
cd packages/features/order_tracking && dart run build_runner build --delete-conflicting-outputs
```

Esperado: se generan 12 archivos (`*.freezed.dart`, `*.g.dart` por cada DTO).

- [ ] **Step 8: Commit**

```bash
git add packages/features/order_tracking/
git commit -m "feat(order-tracking): add DTOs and run code generation"
```

---

## Task 4: Interfaz del repositorio de dominio

**Files:**
- Create: `packages/features/order_tracking/lib/src/domain/repositories/order_tracking_repository.dart`

- [ ] **Step 1: Crear el archivo**

```dart
import 'package:dartz/dartz.dart' hide Order;
import 'package:orders/orders.dart';

class OrderTrackingFailure {
  const OrderTrackingFailure([this.message]);
  final String? message;
}

abstract class OrderTrackingRepository {
  /// GET /orders — lista de órdenes del usuario autenticado, ordenadas por fecha desc.
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders();

  /// GET /orders/:id — detalle completo de una orden.
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id);

  /// Stream en tiempo real de una orden vía WebSocket.
  /// Emite el estado actual via REST al suscribirse, luego emite en cada
  /// evento WS `order.updated` para el orderId dado.
  /// Reconexión con backoff exponencial ante pérdida de señal.
  Stream<Order> watchOrder(String id);
}
```

- [ ] **Step 2: Correr analyze**

```bash
cd packages/features/order_tracking && dart analyze lib/src/domain/
```

Esperado: no issues.

- [ ] **Step 3: Commit**

```bash
git add packages/features/order_tracking/lib/src/domain/
git commit -m "feat(order-tracking): add OrderTrackingRepository domain interface"
```

---

## Task 5: Mappers + tests (TDD)

**Files:**
- Create: `packages/features/order_tracking/lib/src/data/mappers/order_tracking_mapper.dart`
- Create: `packages/features/order_tracking/test/data/mappers/order_tracking_mapper_test.dart`

- [ ] **Step 1: Escribir tests (failing)**

Crear `packages/features/order_tracking/test/data/mappers/order_tracking_mapper_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/dtos/order_list_response_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_line_item_dto.dart';
import 'package:order_tracking/src/data/dtos/ws_order_event_dto.dart';
import 'package:order_tracking/src/data/mappers/order_tracking_mapper.dart';
import 'package:orders/orders.dart';

void main() {
  group('OrderTrackingItemDtoMapper', () {
    test('maps pending status', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'pending');
      expect(dto.toEntity().status, OrderStatus.pending);
    });

    test('maps in_progress status to inProgress', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'in_progress');
      expect(dto.toEntity().status, OrderStatus.inProgress);
    });

    test('maps confirmed to inProgress (backward compat)', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'confirmed');
      expect(dto.toEntity().status, OrderStatus.inProgress);
    });

    test('maps shipped to inProgress (backward compat)', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'shipped');
      expect(dto.toEntity().status, OrderStatus.inProgress);
    });

    test('maps completed status', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'completed');
      expect(dto.toEntity().status, OrderStatus.completed);
    });

    test('maps delivered to completed (backward compat)', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'delivered');
      expect(dto.toEntity().status, OrderStatus.completed);
    });

    test('maps cancelled status', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'cancelled');
      expect(dto.toEntity().status, OrderStatus.cancelled);
    });

    test('maps unknown status to pending', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'foobar');
      expect(dto.toEntity().status, OrderStatus.pending);
    });

    test('maps createdAt ISO string to DateTime', () {
      final dto = OrderTrackingItemDto(
        id: 'o1',
        status: 'pending',
        createdAt: '2026-06-10T09:00:00Z',
      );
      expect(dto.toEntity().createdAt.year, 2026);
      expect(dto.toEntity().createdAt.month, 6);
    });

    test('uses DateTime.now() when createdAt is null', () {
      final dto = OrderTrackingItemDto(id: 'o1', status: 'pending');
      expect(dto.toEntity().createdAt, isNotNull);
    });

    test('maps line items to OrderItems', () {
      final dto = OrderTrackingItemDto(
        id: 'o1',
        status: 'pending',
        items: [
          OrderTrackingLineItemDto(productId: 'p1', name: 'Box', quantity: 3),
        ],
      );
      final entity = dto.toEntity();
      expect(entity.items.length, 1);
      expect(entity.items.first.productName, 'Box');
      expect(entity.items.first.quantity, 3);
    });

    test('uses empty string for line item name when null', () {
      final dto = OrderTrackingItemDto(
        id: 'o1',
        status: 'pending',
        items: [OrderTrackingLineItemDto(productId: 'p1', quantity: 1)],
      );
      expect(dto.toEntity().items.first.productName, '');
    });
  });

  group('OrderListResponseDto JSON parsing', () {
    test('parses list from JSON', () {
      final json = <String, dynamic>{
        'orders': [
          {'id': 'o1', 'status': 'pending', 'items': []},
          {'id': 'o2', 'status': 'completed', 'items': []},
        ],
      };
      final dto = OrderListResponseDto.fromJson(json);
      expect(dto.orders.length, 2);
      expect(dto.orders.first.id, 'o1');
    });

    test('returns empty list when orders key is missing', () {
      final dto = OrderListResponseDto.fromJson(<String, dynamic>{});
      expect(dto.orders, isEmpty);
    });
  });

  group('WsOrderEventDto JSON parsing', () {
    test('parses order.updated event', () {
      final json = <String, dynamic>{
        'event': 'order.updated',
        'payload': {'order_id': 'ord-42', 'status': 'in_progress'},
      };
      final dto = WsOrderEventDto.fromJson(json);
      expect(dto.event, 'order.updated');
      expect(dto.payload.orderId, 'ord-42');
      expect(dto.payload.status, 'in_progress');
    });
  });
}
```

- [ ] **Step 2: Correr tests para verificar que fallan**

```bash
cd packages/features/order_tracking && flutter test test/data/mappers/
```

Esperado: FAIL — `order_tracking_mapper.dart` no existe aún.

- [ ] **Step 3: Implementar los mappers**

Crear `packages/features/order_tracking/lib/src/data/mappers/order_tracking_mapper.dart`:

```dart
import 'package:catalog/catalog.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_line_item_dto.dart';
import 'package:orders/orders.dart';

extension OrderTrackingItemDtoMapper on OrderTrackingItemDto {
  Order toEntity() {
    final mappedItems = items.map((i) => i.toEntity()).toList();
    return Order(
      id: id,
      status: _parseStatus(status),
      items: mappedItems,
      createdAt: createdAt != null
          ? (DateTime.tryParse(createdAt!) ?? DateTime.now())
          : DateTime.now(),
      total: Money.zero('ARS'),
    );
  }
}

extension OrderTrackingLineItemDtoMapper on OrderTrackingLineItemDto {
  OrderItem toEntity() => OrderItem(
        productId: productId,
        productName: name ?? '',
        quantity: quantity,
        unitPrice: Money.zero('ARS'),
      );
}

OrderStatus _parseStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'in_progress':
    case 'confirmed':
    case 'shipped':
      return OrderStatus.inProgress;
    case 'completed':
    case 'delivered':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}
```

- [ ] **Step 4: Correr tests**

```bash
cd packages/features/order_tracking && flutter test test/data/mappers/
```

Esperado: todos pasan.

- [ ] **Step 5: Commit**

```bash
git add packages/features/order_tracking/lib/src/data/mappers/ \
        packages/features/order_tracking/test/data/mappers/
git commit -m "feat(order-tracking): add order tracking mappers with TDD"
```

---

## Task 6: Mock repository + tests (TDD)

**Files:**
- Create: `packages/features/order_tracking/lib/src/data/repositories/mock_order_tracking_repository.dart`

- [ ] **Step 1: Escribir tests del mock (failing)**

Crear `packages/features/order_tracking/test/data/repositories/mock_order_tracking_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

void main() {
  late MockOrderTrackingRepository repo;

  setUp(() => repo = MockOrderTrackingRepository());
  tearDown(() => repo.dispose());

  group('getOrders', () {
    test('returns non-empty list', () async {
      final result = await repo.getOrders();
      expect(result.isRight(), true);
      result.fold((_) {}, (orders) => expect(orders, isNotEmpty));
    });

    test('returns orders sorted by createdAt descending', () async {
      final result = await repo.getOrders();
      result.fold((_) {}, (orders) {
        for (int i = 0; i < orders.length - 1; i++) {
          expect(orders[i].createdAt.isAfter(orders[i + 1].createdAt), true);
        }
      });
    });
  });

  group('getOrderById', () {
    test('returns matching order', () async {
      final listResult = await repo.getOrders();
      final firstId = listResult.fold((_) => '', (o) => o.first.id);
      final result = await repo.getOrderById(firstId);
      expect(result.isRight(), true);
      result.fold((_) {}, (order) => expect(order.id, firstId));
    });

    test('returns failure for unknown id', () async {
      final result = await repo.getOrderById('nonexistent-id');
      expect(result.isLeft(), true);
    });
  });

  group('watchOrder', () {
    test('emits initial state immediately', () async {
      final listResult = await repo.getOrders();
      final firstId = listResult.fold((_) => '', (o) => o.first.id);
      final order = await repo.watchOrder(firstId).first;
      expect(order.id, firstId);
    });

    test('emits update when emitUpdate is called', () async {
      final listResult = await repo.getOrders();
      final firstOrder = listResult.fold((_) => throw Exception(), (o) => o.first);
      final updatedOrder = Order(
        id: firstOrder.id,
        items: firstOrder.items,
        status: OrderStatus.completed,
        createdAt: firstOrder.createdAt,
        total: firstOrder.total,
      );

      final emitted = <Order>[];
      final sub = repo.watchOrder(firstOrder.id).listen(emitted.add);
      await Future<void>.delayed(Duration.zero);

      repo.emitUpdate(firstOrder.id, updatedOrder);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      expect(emitted.length, 2);
      expect(emitted.last.status, OrderStatus.completed);
    });
  });
}
```

- [ ] **Step 2: Correr tests para verificar que fallan**

```bash
cd packages/features/order_tracking && flutter test test/data/repositories/mock_order_tracking_repository_test.dart
```

Esperado: FAIL — archivo de repositorio no existe.

- [ ] **Step 3: Implementar el mock**

Crear `packages/features/order_tracking/lib/src/data/repositories/mock_order_tracking_repository.dart`:

```dart
import 'dart:async';

import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

class MockOrderTrackingRepository implements OrderTrackingRepository {
  final List<Order> _orders = [
    Order(
      id: 'WH-49281',
      items: [
        const OrderItem(
          productId: 'p1',
          productName: 'Heavy-duty shipping box 60×40×40',
          quantity: 8,
          unitPrice: Money(amount: 0, currency: 'ARS'),
        ),
      ],
      status: OrderStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
    Order(
      id: 'WH-49202',
      items: [],
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
    Order(
      id: 'WH-49150',
      items: [],
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
    Order(
      id: 'WH-49100',
      items: [],
      status: OrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
  ];

  final Map<String, StreamController<Order>> _controllers = {};

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async {
    final sorted = [..._orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Right(sorted);
  }

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async {
    try {
      final order = _orders.firstWhere((o) => o.id == id);
      return Right(order);
    } catch (_) {
      return Left(OrderTrackingFailure('Orden $id no encontrada'));
    }
  }

  @override
  Stream<Order> watchOrder(String id) {
    final controller = StreamController<Order>.broadcast();
    _controllers[id] = controller;
    final order = _orders.firstWhere(
      (o) => o.id == id,
      orElse: () => _orders.first,
    );
    Future.microtask(() {
      if (!controller.isClosed) controller.add(order);
    });
    return controller.stream;
  }

  /// Para tests y modo demo: inyectar un update de estado.
  void emitUpdate(String id, Order updated) {
    _controllers[id]?.add(updated);
  }

  void dispose() {
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
  }
}
```

- [ ] **Step 4: Correr tests**

```bash
cd packages/features/order_tracking && flutter test test/data/repositories/mock_order_tracking_repository_test.dart
```

Esperado: todos pasan.

- [ ] **Step 5: Commit**

```bash
git add packages/features/order_tracking/lib/src/data/repositories/mock_order_tracking_repository.dart \
        packages/features/order_tracking/test/data/repositories/mock_order_tracking_repository_test.dart
git commit -m "feat(order-tracking): add MockOrderTrackingRepository with TDD"
```

---

## Task 7: Remote repository — REST + tests (TDD)

**Files:**
- Create: `packages/features/order_tracking/lib/src/data/repositories/remote_order_tracking_repository.dart`
- Create: `packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart`

- [ ] **Step 1: Escribir tests del repositorio remoto REST (failing)**

Crear `packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart`:

```dart
import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart' show Options;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

// ── Fake HttpHelper ──────────────────────────────────────────────────────────

class _FakeHttpHelper implements HttpHelper {
  Either<HttpResponseError, HttpResponse> Function(String path) getHandler =
      (_) => Right(HttpResponse(data: <String, dynamic>{'orders': []}));

  @override
  void init() {}

  @override
  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noCache = false,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      getHandler(path);

  @override
  Future<Either<HttpResponseError, HttpResponse>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool retryOnTokenExpired = true,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool external = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> postImages(
    String path, {
    required Map<String, dynamic> data,
    required FilesData filesData,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeHttpHelper fakeHttp;
  late RemoteOrderTrackingRepository repo;

  setUp(() {
    fakeHttp = _FakeHttpHelper();
    repo = RemoteOrderTrackingRepository(
      httpHelper: fakeHttp,
      getToken: () => 'test-token',
      baseUrl: 'http://localhost:8080',
    );
  });

  group('getOrders', () {
    test('returns empty list when orders is []', () async {
      fakeHttp.getHandler = (_) =>
          Right(HttpResponse(data: <String, dynamic>{'orders': []}));
      final result = await repo.getOrders();
      expect(result.isRight(), true);
      result.fold((_) {}, (orders) => expect(orders, isEmpty));
    });

    test('parses orders list correctly', () async {
      fakeHttp.getHandler = (_) => Right(HttpResponse(
            data: <String, dynamic>{
              'orders': [
                {'id': 'o1', 'status': 'pending', 'items': []},
                {'id': 'o2', 'status': 'in_progress', 'items': []},
              ],
            },
          ));
      final result = await repo.getOrders();
      result.fold(
        (_) => fail('Expected Right'),
        (orders) {
          expect(orders.length, 2);
          expect(orders.any((o) => o.id == 'o1'), true);
          expect(orders.any((o) => o.status == OrderStatus.inProgress), true);
        },
      );
    });

    test('returns failure on HTTP error', () async {
      fakeHttp.getHandler = (_) =>
          Left(HttpResponseError(errorType: 'server_error', message: 'Server error', statusCode: 500));
      final result = await repo.getOrders();
      expect(result.isLeft(), true);
    });

    test('returns failure when response is not a Map', () async {
      fakeHttp.getHandler = (_) =>
          Right(HttpResponse(data: 'not a map'));
      final result = await repo.getOrders();
      expect(result.isLeft(), true);
    });
  });

  group('getOrderById', () {
    test('parses single order correctly', () async {
      fakeHttp.getHandler = (path) {
        expect(path, '/orders/ord-1');
        return Right(HttpResponse(
          data: <String, dynamic>{
            'order': {'id': 'ord-1', 'status': 'completed', 'items': []},
          },
        ));
      };
      final result = await repo.getOrderById('ord-1');
      result.fold(
        (_) => fail('Expected Right'),
        (order) {
          expect(order.id, 'ord-1');
          expect(order.status, OrderStatus.completed);
        },
      );
    });

    test('returns failure on HTTP error', () async {
      fakeHttp.getHandler = (_) =>
          Left(HttpResponseError(errorType: 'not_found', message: 'Not found', statusCode: 404));
      final result = await repo.getOrderById('nonexistent');
      expect(result.isLeft(), true);
    });
  });
}
```

- [ ] **Step 2: Correr tests para verificar que fallan**

```bash
cd packages/features/order_tracking && flutter test test/data/repositories/remote_order_tracking_repository_test.dart
```

Esperado: FAIL — `RemoteOrderTrackingRepository` no existe aún.

- [ ] **Step 3: Implementar el repositorio remoto (solo REST; WS en Task 8)**

Crear `packages/features/order_tracking/lib/src/data/repositories/remote_order_tracking_repository.dart`:

```dart
import 'dart:async';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/data/dtos/order_list_response_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_detail_response_dto.dart';
import 'package:order_tracking/src/data/mappers/order_tracking_mapper.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

class RemoteOrderTrackingRepository implements OrderTrackingRepository {
  RemoteOrderTrackingRepository({
    required this.httpHelper,
    required this.getToken,
    required this.baseUrl,
  });

  final HttpHelper httpHelper;
  final String? Function() getToken;

  /// HTTP base URL (e.g. `http://10.0.2.2:8080`).
  /// watchOrder reemplaza el scheme a ws:// internamente.
  final String baseUrl;

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async {
    try {
      final result = await httpHelper.get('/orders');
      return result.fold(
        (error) => Left(OrderTrackingFailure(_mapError(error))),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(OrderTrackingFailure('Respuesta inválida'));
          }
          final dto = OrderListResponseDto.fromJson(data);
          final orders = dto.orders.map((o) => o.toEntity()).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return Right(orders);
        },
      );
    } catch (e, st) {
      log('getOrders error', error: e, stackTrace: st);
      return const Left(OrderTrackingFailure('Error de red'));
    }
  }

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async {
    try {
      final result = await httpHelper.get('/orders/$id');
      return result.fold(
        (error) => Left(OrderTrackingFailure(_mapError(error))),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(OrderTrackingFailure('Respuesta inválida'));
          }
          final dto = OrderTrackingDetailResponseDto.fromJson(data);
          return Right(dto.order.toEntity());
        },
      );
    } catch (e, st) {
      log('getOrderById error', error: e, stackTrace: st);
      return const Left(OrderTrackingFailure('Error de red'));
    }
  }

  @override
  Stream<Order> watchOrder(String id) {
    // Implementado en Task 8
    throw UnimplementedError('watchOrder not yet implemented');
  }

  String _mapError(HttpResponseError error) {
    if (error.statusCode == 404) return 'Orden no encontrada';
    if (error.statusCode == 401 || error.statusCode == 403) {
      return 'Sin permisos para ver órdenes';
    }
    return error.message ?? 'Error de red';
  }
}
```

- [ ] **Step 4: Correr tests REST**

```bash
cd packages/features/order_tracking && flutter test test/data/repositories/remote_order_tracking_repository_test.dart
```

Esperado: todos los tests de `getOrders` y `getOrderById` pasan.

- [ ] **Step 5: Commit**

```bash
git add packages/features/order_tracking/lib/src/data/repositories/remote_order_tracking_repository.dart \
        packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart
git commit -m "feat(order-tracking): add RemoteOrderTrackingRepository REST methods with TDD"
```

---

## Task 8: Remote repository — `watchOrder()` con WebSocket + tests (TDD)

**Files:**
- Modify: `packages/features/order_tracking/lib/src/data/repositories/remote_order_tracking_repository.dart`
- Modify: `packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart`

- [ ] **Step 1: Agregar tests de `watchOrder` al archivo de tests existente**

Agregar al final del `group` principal en `remote_order_tracking_repository_test.dart`, antes del cierre del `main()`:

```dart
  group('watchOrder', () {
    test('emits order from REST fetch immediately on subscribe', () async {
      fakeHttp.getHandler = (path) {
        if (path == '/orders/ord-1') {
          return Right(HttpResponse(
            data: <String, dynamic>{
              'order': {'id': 'ord-1', 'status': 'pending', 'items': []},
            },
          ));
        }
        return Right(HttpResponse(data: <String, dynamic>{'orders': []}));
      };

      final order = await repo.watchOrder('ord-1').first;
      expect(order.id, 'ord-1');
      expect(order.status, OrderStatus.pending);
    });
  });
```

- [ ] **Step 2: Correr para verificar que falla**

```bash
cd packages/features/order_tracking && flutter test test/data/repositories/remote_order_tracking_repository_test.dart --name "watchOrder"
```

Esperado: FAIL — `watchOrder` lanza `UnimplementedError`.

- [ ] **Step 3: Implementar `watchOrder` con WS**

Reemplazar el método `watchOrder` en `remote_order_tracking_repository.dart` y agregar los imports necesarios:

Agregar al inicio del archivo (después de los imports existentes):

```dart
import 'dart:convert';
import 'package:order_tracking/src/data/dtos/ws_order_event_dto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
```

Reemplazar el método `watchOrder`:

```dart
@override
Stream<Order> watchOrder(String id) {
  final controller = StreamController<Order>();
  _connectWithRetry(id, controller);
  return controller.stream;
}

void _connectWithRetry(String id, StreamController<Order> controller) async {
  const delays = [1, 2, 4, 8, 16, 30];
  int attempt = 0;

  while (!controller.isClosed) {
    try {
      // Guideline del backend: REST fetch antes de suscribirse a WS
      final restResult = await getOrderById(id);
      restResult.fold(
        (failure) {
          if (!controller.isClosed) controller.addError(Exception(failure.message));
        },
        (order) {
          if (!controller.isClosed) controller.add(order);
        },
      );

      final token = getToken();
      if (token == null) {
        if (!controller.isClosed) {
          controller.addError(Exception('No autenticado'));
        }
        return;
      }

      final wsUrl = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
      final channel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws?token=$token'));
      attempt = 0;

      await for (final message in channel.stream) {
        if (controller.isClosed) break;
        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final event = WsOrderEventDto.fromJson(json);
          if (event.event == 'order.updated' && event.payload.orderId == id) {
            final updated = await getOrderById(id);
            updated.fold((_) {}, (order) {
              if (!controller.isClosed) controller.add(order);
            });
          }
        } catch (_) {
          // Mensaje WS no parseable: ignorar
        }
      }
    } catch (_) {
      if (controller.isClosed) break;
      final delay = delays[attempt.clamp(0, delays.length - 1)];
      attempt++;
      await Future<void>.delayed(Duration(seconds: delay));
    }
  }
}
```

- [ ] **Step 4: Correr todos los tests del repositorio remoto**

```bash
cd packages/features/order_tracking && flutter test test/data/repositories/remote_order_tracking_repository_test.dart
```

Esperado: todos pasan (incluyendo el nuevo `watchOrder` test).

- [ ] **Step 5: Commit**

```bash
git add packages/features/order_tracking/lib/src/data/repositories/remote_order_tracking_repository.dart \
        packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart
git commit -m "feat(order-tracking): implement watchOrder with WebSocket reconnection"
```

---

## Task 9: `OrderListCubit` + tests (TDD)

**Files:**
- Create: `packages/features/order_tracking/lib/src/presentation/bloc/order_list_state.dart`
- Create: `packages/features/order_tracking/lib/src/presentation/bloc/order_list_cubit.dart`
- Create: `packages/features/order_tracking/test/presentation/bloc/order_list_cubit_test.dart`

- [ ] **Step 1: Crear `order_list_state.dart`**

```dart
import 'package:orders/orders.dart';

sealed class OrderListState {
  const OrderListState();
}

class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

class OrderListError extends OrderListState {
  const OrderListError(this.message);
  final String message;
}

class OrderListReady extends OrderListState {
  const OrderListReady({required this.orders});
  final List<Order> orders;
}
```

- [ ] **Step 2: Escribir tests del cubit (failing)**

Crear `packages/features/order_tracking/test/presentation/bloc/order_list_cubit_test.dart`:

```dart
import 'dart:async';

import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_cubit.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_state.dart';
import 'package:orders/orders.dart';

class _FakeRepo implements OrderTrackingRepository {
  Either<OrderTrackingFailure, List<Order>> result =
      const Right([]);

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async => result;

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async =>
      const Left(OrderTrackingFailure('not used'));

  @override
  Stream<Order> watchOrder(String id) => const Stream.empty();
}

Order _order(String id) => Order(
      id: id,
      items: [],
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      total: const Money(amount: 0, currency: 'ARS'),
    );

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  test('initial state is OrderListLoading', () {
    repo.result = const Right([]);
    final cubit = OrderListCubit(repo);
    // Constructor llama load() async; el primer estado emitido es Loading
    expect(cubit.state, isA<OrderListLoading>());
    cubit.close();
  });

  test('emits Loading then Ready with orders', () async {
    repo.result = Right([_order('o1'), _order('o2')]);
    final cubit = OrderListCubit(repo);
    final states = <OrderListState>[];
    final sub = cubit.stream.listen(states.add);

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    await cubit.close();

    expect(states.first, isA<OrderListLoading>());
    expect(states.last, isA<OrderListReady>());
    final ready = states.last as OrderListReady;
    expect(ready.orders.length, 2);
  });

  test('emits Error when repository returns failure', () async {
    repo.result =
        const Left(OrderTrackingFailure('Error de red'));
    final cubit = OrderListCubit(repo);
    final states = <OrderListState>[];
    final sub = cubit.stream.listen(states.add);

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    await cubit.close();

    expect(states.last, isA<OrderListError>());
    expect((states.last as OrderListError).message, 'Error de red');
  });

  test('refresh re-emits Loading then Ready', () async {
    repo.result = Right([_order('o1')]);
    final cubit = OrderListCubit(repo);
    await Future<void>.delayed(Duration.zero);

    final states = <OrderListState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.refresh();
    await sub.cancel();
    await cubit.close();

    expect(states.first, isA<OrderListLoading>());
    expect(states.last, isA<OrderListReady>());
  });
}
```

- [ ] **Step 3: Correr tests para verificar que fallan**

```bash
cd packages/features/order_tracking && flutter test test/presentation/bloc/order_list_cubit_test.dart
```

Esperado: FAIL — `OrderListCubit` no existe.

- [ ] **Step 4: Crear `order_list_cubit.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_state.dart';

export 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit(this._repository) : super(const OrderListLoading()) {
    load();
  }

  final OrderTrackingRepository _repository;

  Future<void> load() async {
    emit(const OrderListLoading());
    final result = await _repository.getOrders();
    result.fold(
      (failure) => emit(OrderListError(failure.message ?? 'Error desconocido')),
      (orders) => emit(OrderListReady(orders: orders)),
    );
  }

  Future<void> refresh() => load();
}
```

- [ ] **Step 5: Correr tests**

```bash
cd packages/features/order_tracking && flutter test test/presentation/bloc/order_list_cubit_test.dart
```

Esperado: todos pasan.

- [ ] **Step 6: Commit**

```bash
git add packages/features/order_tracking/lib/src/presentation/bloc/order_list_state.dart \
        packages/features/order_tracking/lib/src/presentation/bloc/order_list_cubit.dart \
        packages/features/order_tracking/test/presentation/bloc/order_list_cubit_test.dart
git commit -m "feat(order-tracking): add OrderListCubit with TDD"
```

---

## Task 10: `OrderDetailCubit` + tests (TDD)

**Files:**
- Create: `packages/features/order_tracking/lib/src/presentation/bloc/order_detail_state.dart`
- Create: `packages/features/order_tracking/lib/src/presentation/bloc/order_detail_cubit.dart`
- Create: `packages/features/order_tracking/test/presentation/bloc/order_detail_cubit_test.dart`

- [ ] **Step 1: Crear `order_detail_state.dart`**

```dart
import 'package:orders/orders.dart';

sealed class OrderDetailState {
  const OrderDetailState();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailError extends OrderDetailState {
  const OrderDetailError(this.message);
  final String message;
}

class OrderDetailReady extends OrderDetailState {
  const OrderDetailReady({required this.order});
  final Order order;
}
```

- [ ] **Step 2: Escribir tests del cubit (failing)**

Crear `packages/features/order_tracking/test/presentation/bloc/order_detail_cubit_test.dart`:

```dart
import 'dart:async';

import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_cubit.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_state.dart';
import 'package:orders/orders.dart';

class _FakeRepo implements OrderTrackingRepository {
  final Map<String, StreamController<Order>> controllers = {};

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async =>
      const Right([]);

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async =>
      const Left(OrderTrackingFailure('not used'));

  @override
  Stream<Order> watchOrder(String id) {
    final controller = StreamController<Order>.broadcast();
    controllers[id] = controller;
    return controller.stream;
  }

  void emitOrder(String id, Order order) => controllers[id]?.add(order);

  void emitError(String id, Object error) => controllers[id]?.addError(error);
}

Order _order(String id, OrderStatus status) => Order(
      id: id,
      items: [],
      status: status,
      createdAt: DateTime.now(),
      total: const Money(amount: 0, currency: 'ARS'),
    );

void main() {
  late _FakeRepo repo;
  late OrderDetailCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = OrderDetailCubit(repo);
  });

  tearDown(() => cubit.close());

  test('initial state is OrderDetailLoading', () {
    expect(cubit.state, isA<OrderDetailLoading>());
  });

  test('emits Ready when stream emits an order', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);

    final states = <OrderDetailState>[];
    final sub = cubit.stream.listen(states.add);

    repo.emitOrder('ord-1', _order('ord-1', OrderStatus.inProgress));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.last, isA<OrderDetailReady>());
    expect((states.last as OrderDetailReady).order.status, OrderStatus.inProgress);
  });

  test('emits Ready on each update from stream', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);

    final states = <OrderDetailState>[];
    final sub = cubit.stream.listen(states.add);

    repo.emitOrder('ord-1', _order('ord-1', OrderStatus.pending));
    await Future<void>.delayed(Duration.zero);
    repo.emitOrder('ord-1', _order('ord-1', OrderStatus.completed));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.length, 2);
    expect((states.last as OrderDetailReady).order.status, OrderStatus.completed);
  });

  test('emits Error when stream emits an error', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);

    final states = <OrderDetailState>[];
    final sub = cubit.stream.listen(states.add);

    repo.emitError('ord-1', Exception('connection lost'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.last, isA<OrderDetailError>());
  });

  test('cancels subscription on close', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    // After close, controller should have no listeners
    expect(repo.controllers['ord-1']?.hasListener, isFalse);
  });
}
```

- [ ] **Step 3: Correr tests para verificar que fallan**

```bash
cd packages/features/order_tracking && flutter test test/presentation/bloc/order_detail_cubit_test.dart
```

Esperado: FAIL — `OrderDetailCubit` no existe.

- [ ] **Step 4: Crear `order_detail_cubit.dart`**

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_state.dart';
import 'package:orders/orders.dart';

export 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit(this._repository) : super(const OrderDetailLoading());

  final OrderTrackingRepository _repository;
  StreamSubscription<Order>? _subscription;

  void load(String orderId) {
    _subscription?.cancel();
    emit(const OrderDetailLoading());
    _subscription = _repository.watchOrder(orderId).listen(
      (order) => emit(OrderDetailReady(order: order)),
      onError: (Object e) =>
          emit(OrderDetailError(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 5: Correr tests**

```bash
cd packages/features/order_tracking && flutter test test/presentation/bloc/order_detail_cubit_test.dart
```

Esperado: todos pasan.

- [ ] **Step 6: Correr todos los tests del package**

```bash
cd packages/features/order_tracking && flutter test
```

Esperado: todos pasan.

- [ ] **Step 7: Commit**

```bash
git add packages/features/order_tracking/lib/src/presentation/bloc/order_detail_state.dart \
        packages/features/order_tracking/lib/src/presentation/bloc/order_detail_cubit.dart \
        packages/features/order_tracking/test/presentation/bloc/order_detail_cubit_test.dart
git commit -m "feat(order-tracking): add OrderDetailCubit with TDD"
```

---

## Task 11: `OrderTrackingFeatureBuilder`

**Files:**
- Create: `packages/features/order_tracking/lib/src/order_tracking_feature_builder.dart`

- [ ] **Step 1: Crear el archivo**

```dart
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_cubit.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_cubit.dart';
import 'package:order_tracking/src/presentation/pages/order_detail_page.dart';
import 'package:order_tracking/src/presentation/pages/order_list_page.dart';

class OrderTrackingFeatureBuilder {
  static void injectDependencies({required String wsBaseUrl}) {
    Injector.i
      ..registerLazySingleton<OrderTrackingRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockOrderTrackingRepository()
            : RemoteOrderTrackingRepository(
                httpHelper: Injector.i.resolve<HttpHelper>(),
                getToken: OnGetTokenUseCase.call,
                baseUrl: wsBaseUrl,
              ),
      )
      ..registerLazySingleton<OrderListCubit>(
        () => OrderListCubit(
          Injector.i.resolve<OrderTrackingRepository>(),
        ),
      );
  }

  static Widget buildOrderListPage() =>
      OrderListPage(cubit: Injector.i.resolve<OrderListCubit>());

  /// Crea un nuevo OrderDetailCubit por cada invocación (no es singleton).
  static Widget buildOrderDetailPage(String orderId) {
    final cubit = OrderDetailCubit(Injector.i.resolve<OrderTrackingRepository>())
      ..load(orderId);
    return OrderDetailPage(cubit: cubit);
  }
}
```

- [ ] **Step 2: Actualizar el barrel `order_tracking.dart`**

Reemplazar el contenido de `packages/features/order_tracking/lib/order_tracking.dart`:

```dart
library order_tracking;

export 'src/domain/repositories/order_tracking_repository.dart';
export 'src/presentation/bloc/order_detail_cubit.dart';
export 'src/presentation/bloc/order_list_cubit.dart';
export 'src/order_tracking_feature_builder.dart';
```

- [ ] **Step 3: Correr analyze**

```bash
cd packages/features/order_tracking && dart analyze
```

Esperado: no issues (puede haber warnings de páginas/widgets que aún no existen — se crean en las siguientes tareas).

- [ ] **Step 4: Commit**

```bash
git add packages/features/order_tracking/lib/src/order_tracking_feature_builder.dart \
        packages/features/order_tracking/lib/order_tracking.dart
git commit -m "feat(order-tracking): add OrderTrackingFeatureBuilder and DI setup"
```

---

## Task 12: UI Widgets

**Files:**
- Create: `packages/features/order_tracking/lib/src/presentation/widgets/order_card.dart`
- Create: `packages/features/order_tracking/lib/src/presentation/widgets/order_status_timeline.dart`

- [ ] **Step 1: Crear `order_card.dart`**

```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:orders/orders.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, required this.onTap, super.key});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SwColors.white,
          border: Border.all(color: SwColors.border),
          borderRadius: BorderRadius.circular(SwRadii.card),
          boxShadow: SwShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ${order.id}',
                    style: SwText.body(size: 14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: SwText.body(size: 12, color: SwColors.text3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 0) return 'Today, $time';
    if (diff.inDays == 1) return 'Yesterday, $time';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: SwText.body(size: 12, color: _textColor, weight: FontWeight.w500),
      ),
    );
  }

  String get _label => switch (status) {
        OrderStatus.pending => 'Pending',
        OrderStatus.inProgress => 'In progress',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };

  Color get _bgColor => switch (status) {
        OrderStatus.pending => SwColors.yellowSoft,
        OrderStatus.inProgress => const Color(0xFFEBF3FF),
        OrderStatus.completed => const Color(0xFFE6F4EA),
        OrderStatus.cancelled => SwColors.surface,
      };

  Color get _textColor => switch (status) {
        OrderStatus.pending => SwColors.yellowDark,
        OrderStatus.inProgress => SwColors.link,
        OrderStatus.completed => SwColors.stockIn,
        OrderStatus.cancelled => SwColors.text3,
      };
}
```

- [ ] **Step 2: Crear `order_status_timeline.dart`**

```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:orders/orders.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({required this.status, super.key});

  final OrderStatus status;

  static const _steps = [
    (value: OrderStatus.pending, label: 'Pending'),
    (value: OrderStatus.inProgress, label: 'In progress'),
    (value: OrderStatus.completed, label: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return _CancelledBanner();
    }
    final currentIndex = _indexFor(status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            _TimelineNode(
              label: _steps[i].label,
              nodeState: i < currentIndex
                  ? _NodeState.done
                  : i == currentIndex
                      ? _NodeState.active
                      : _NodeState.upcoming,
            ),
            if (i < _steps.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    height: 2,
                    color: i < currentIndex ? SwColors.stockIn : SwColors.border,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  int _indexFor(OrderStatus s) => switch (s) {
        OrderStatus.pending => 0,
        OrderStatus.inProgress => 1,
        OrderStatus.completed => 2,
        OrderStatus.cancelled => 0,
      };
}

enum _NodeState { done, active, upcoming }

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.label, required this.nodeState});

  final String label;
  final _NodeState nodeState;

  @override
  Widget build(BuildContext context) {
    final circleColor = switch (nodeState) {
      _NodeState.done => SwColors.stockIn,
      _NodeState.active => SwColors.yellow,
      _NodeState.upcoming => SwColors.border,
    };
    final textColor = nodeState == _NodeState.upcoming ? SwColors.text3 : SwColors.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: nodeState == _NodeState.done
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: SwText.body(size: 10, color: textColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SwColors.surface,
        borderRadius: BorderRadius.circular(SwRadii.card),
        border: Border.all(color: SwColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, size: 20, color: SwColors.text3),
          const SizedBox(width: 8),
          Text('Order cancelled', style: SwText.body(size: 14, color: SwColors.text3)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Correr analyze**

```bash
cd packages/features/order_tracking && dart analyze lib/src/presentation/widgets/
```

Esperado: no issues.

- [ ] **Step 4: Commit**

```bash
git add packages/features/order_tracking/lib/src/presentation/widgets/
git commit -m "feat(order-tracking): add OrderCard and OrderStatusTimeline widgets"
```

---

## Task 13: UI Pages

**Files:**
- Create: `packages/features/order_tracking/lib/src/presentation/pages/order_list_page.dart`
- Create: `packages/features/order_tracking/lib/src/presentation/pages/order_detail_page.dart`

- [ ] **Step 1: Crear `order_list_page.dart`**

```dart
import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_cubit.dart';
import 'package:order_tracking/src/presentation/widgets/order_card.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({required this.cubit, super.key});

  final OrderListCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBarFeatureBuilder.buildScaffold(
      context,
      selectedTab: const NavigationBarOption.orders(),
      scrollable: false,
      appBar: AppBar(
        backgroundColor: SwColors.white,
        elevation: 0,
        title: Text('My orders', style: SwText.body(size: 18, weight: FontWeight.w600)),
        automaticallyImplyLeading: false,
      ),
      child: BlocBuilder<OrderListCubit, OrderListState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          OrderListLoading() => const Center(child: SwLoadingSpinner()),
          OrderListError(:final message) => SwErrorView(
              message: message,
              onRetry: cubit.refresh,
            ),
          OrderListReady(:final orders) => orders.isEmpty
              ? const SwEmptyView(
                  title: 'No orders yet',
                  message: 'Your orders will appear here once you place one.',
                  icon: Icons.receipt_long_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => OrderCard(
                    order: orders[i],
                    onTap: () => Injector.i.resolve<NavigationHelper>().pushNamed(
                          context,
                          routeName: Routes.orderDetail(orders[i].id),
                        ),
                  ),
                ),
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Crear `order_detail_page.dart`**

```dart
import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_cubit.dart';
import 'package:order_tracking/src/presentation/widgets/order_status_timeline.dart';
import 'package:orders/orders.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({required this.cubit, super.key});

  final OrderDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBarFeatureBuilder.buildScaffold(
      context,
      selectedTab: const NavigationBarOption.orders(),
      scrollable: false,
      appBar: AppBar(
        backgroundColor: SwColors.white,
        elevation: 0,
        title: Text('Order detail', style: SwText.body(size: 18, weight: FontWeight.w600)),
      ),
      child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          OrderDetailLoading() => const Center(child: SwLoadingSpinner()),
          OrderDetailError(:final message) => SwErrorView(
              message: message,
              onRetry: () {},
            ),
          OrderDetailReady(:final order) => _DetailContent(order: order),
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ${order.id}',
                  style: SwText.body(size: 16, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                'Placed ${_formatDate(order.createdAt)}',
                style: SwText.body(size: 12, color: SwColors.text3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrderStatusTimeline(status: order.status),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, color: SwColors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Order details',
              style: SwText.body(size: 14, weight: FontWeight.w600)),
        ),
        if (order.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('No items', style: SwText.body(size: 14, color: SwColors.text3)),
          )
        else
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: SwText.body(size: 14)),
                        const SizedBox(height: 2),
                        Text(
                          '${item.productId} · qty ${item.quantity}',
                          style: SwText.body(size: 12, color: SwColors.text3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 0) return 'Today, $time';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
```

- [ ] **Step 3: Correr analyze del package completo**

```bash
cd packages/features/order_tracking && dart analyze
```

Esperado: no issues.

- [ ] **Step 4: Correr todos los tests**

```bash
cd packages/features/order_tracking && flutter test
```

Esperado: todos pasan.

- [ ] **Step 5: Commit**

```bash
git add packages/features/order_tracking/lib/src/presentation/pages/
git commit -m "feat(order-tracking): add OrderListPage and OrderDetailPage"
```

---

## Task 14: Navigation wire-up (Routes, Beamer, BottomNav, IocManager)

**Files:**
- Modify: `packages/core/lib/src/navigation/routes.dart`
- Modify: `packages/core/pubspec.yaml`
- Modify: `packages/core/lib/core.dart`
- Modify: `lib/config/ioc_manager.dart`
- Modify: `lib/application/navigation/beamer_config_helper.dart`
- Modify: `packages/features/bottom_navigation_bar/lib/src/bottom_navigation_bar_feature_builder.dart`
- Modify: `packages/features/orders/lib/src/presentation/pages/order_success_page.dart`

- [ ] **Step 1: Agregar rutas a `Routes`**

En `packages/core/lib/src/navigation/routes.dart`, agregar después de `orderSuccessPattern`:

```dart
static const String orders = '/orders';
static const String orderDetailPattern = '/orders/:id';

static String orderDetail(String id) => '/orders/$id';
```

El archivo completo queda:

```dart
class Routes {
  static const String login = '/login';
  static const String profile = '/profile';
  static const String catalog = '/catalog';
  static const String catalogDetailPattern = '/catalog/:id';
  static const String cart = '/cart';
  static const String orderSuccessPattern = '/order/:id/success';
  static const String orders = '/orders';
  static const String orderDetailPattern = '/orders/:id';

  static String catalogDetail(String productId) => '/catalog/$productId';
  static String orderSuccess(String orderId) => '/order/$orderId/success';
  static String orderDetail(String id) => '/orders/$id';
}
```

- [ ] **Step 2: Agregar `order_tracking` a `core/pubspec.yaml`**

En `packages/core/pubspec.yaml`, agregar en `dependencies` (después de `orders:`):

```yaml
  order_tracking:
    path: ../features/order_tracking
```

- [ ] **Step 3: Re-exportar `order_tracking` desde `core.dart`**

En `packages/core/lib/core.dart`, agregar (después de `export 'package:orders/orders.dart';`):

```dart
export 'package:order_tracking/order_tracking.dart';
```

- [ ] **Step 4: Actualizar `IocManager` — registrar feature y añadir `_toWsUrl`**

En `lib/config/ioc_manager.dart`:

a) Agregar al final del archivo (antes del último `}`):

```dart
String _toWsUrl() =>
    _localBackendUrl().replaceFirst(RegExp(r'^http'), 'ws');
```

b) Dentro de `IocManager.register()`, agregar después de `CartFeatureBuilder.injectDependencies();`:

```dart
OrderTrackingFeatureBuilder.injectDependencies(
  wsBaseUrl: config.environment.when(
    dev: _toWsUrl,
    qa: _toWsUrl,
    prod: _toWsUrl,
  ),
);
```

- [ ] **Step 5: Agregar rutas a `BeamerConfigHelper`**

En `lib/application/navigation/beamer_config_helper.dart`, dentro de `_buildRoutes()`, agregar después del entry de `Routes.orderSuccessPattern`:

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

- [ ] **Step 6: Actualizar `BottomNavigationBarFeatureBuilder` para navegar a órdenes**

En `packages/features/bottom_navigation_bar/lib/src/bottom_navigation_bar_feature_builder.dart`, reemplazar el handler de `orders:`:

```dart
orders: () => Beamer.of(context).beamToNamed(Routes.orders),
```

El bloque `option.when(...)` completo queda:

```dart
option.when(
  products: () => Beamer.of(context).beamToNamed(Routes.catalog),
  cart: () => Beamer.of(context).beamToNamed(Routes.cart),
  orders: () => Beamer.of(context).beamToNamed(Routes.orders),
  profile: () => Beamer.of(context).beamToNamed(Routes.profile),
);
```

- [ ] **Step 7: Actualizar `OrderSuccessPage` — botón "Ver mis pedidos"**

En `packages/features/orders/lib/src/presentation/pages/order_success_page.dart`, reemplazar el segundo `SwButton`:

```dart
SwButton(
  label: 'Ver mis pedidos',
  variant: SwButtonVariant.secondary,
  onPressed: () => Injector.i.resolve<NavigationHelper>().pushNamed(
    context,
    routeName: Routes.orders,
    replace: true,
  ),
),
```

- [ ] **Step 8: Correr melos bootstrap**

```bash
melos bootstrap
```

Esperado: todas las dependencias resueltas.

- [ ] **Step 9: Correr analyze en todos los packages tocados**

```bash
cd packages/features/order_tracking && dart analyze
cd packages/core && dart analyze
cd packages/features/orders && dart analyze
cd packages/features/bottom_navigation_bar && dart analyze
```

Y desde la raíz:

```bash
dart analyze lib/
```

Esperado: no issues en ningún package.

- [ ] **Step 10: Correr todos los tests**

```bash
cd packages/features/order_tracking && flutter test
cd packages/features/orders && flutter test
```

Esperado: todos pasan.

- [ ] **Step 11: Commit final**

```bash
git add packages/core/lib/src/navigation/routes.dart \
        packages/core/pubspec.yaml \
        packages/core/lib/core.dart \
        lib/config/ioc_manager.dart \
        lib/application/navigation/beamer_config_helper.dart \
        packages/features/bottom_navigation_bar/lib/src/bottom_navigation_bar_feature_builder.dart \
        packages/features/orders/lib/src/presentation/pages/order_success_page.dart
git commit -m "feat(order-tracking): wire up navigation, DI, and BottomNav orders tab"
```

---

## Checklist de verificación final

Antes de abrir el PR, verificar:

- [ ] `flutter run --dart-define=APP_DATA_SOURCE=mock` → tab Orders muestra lista de 4 órdenes mock
- [ ] Tap en una orden → navega al detalle con timeline correcto según el status
- [ ] Tab "Ver mis pedidos" en `OrderSuccessPage` navega a la lista
- [ ] `flutter run --dart-define=APP_DATA_SOURCE=remote` → lista conecta al backend real
- [ ] `dart analyze` limpio en todos los packages
- [ ] `flutter test` pasa en `orders` y `order_tracking`
