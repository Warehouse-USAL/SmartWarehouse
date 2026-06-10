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
