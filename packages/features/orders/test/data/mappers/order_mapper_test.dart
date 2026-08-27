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
      expect(entity.items.length, 1);
      expect(entity.items.first.productName, 'Casco');
      expect(entity.createdAt.toIso8601String(), startsWith('2026-06-03'));
    });

    test('uses now() when timestamps.created_at is missing', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'x', 'status': 'PENDING', 'items': []},
      });
      expect(dto.order.toEntity(fallbackItems: []).createdAt, isNotNull);
    });
  });
}
