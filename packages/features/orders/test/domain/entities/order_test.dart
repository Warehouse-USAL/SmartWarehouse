import 'package:catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';

Order _order({String? cancelReason}) => Order(
  id: 'o1',
  items: const [],
  status: OrderStatus.cancelled,
  createdAt: DateTime(2026),
  total: Money.zero('ARS'),
  cancelReason: cancelReason,
);

void main() {
  group('Order.cancelReasonMessage', () {
    test('null sin motivo (backend viejo) o motivo vacío', () {
      expect(_order().cancelReasonMessage, isNull);
      expect(_order(cancelReason: '  ').cancelReasonMessage, isNull);
    });

    test('INSUFFICIENT_STOCK da una explicación sin filtrar SKUs', () {
      final msg = _order(
        cancelReason: 'INSUFFICIENT_STOCK: SKU-123 (needed 5, available 2)',
      ).cancelReasonMessage;
      expect(msg, contains('stock'));
      expect(msg, isNot(contains('SKU-123')));
      expect(msg, isNot(contains('INSUFFICIENT_STOCK')));
    });

    test('motivo libre/desconocido no se muestra (queda como hoy)', () {
      expect(
        _order(cancelReason: 'Cancelada por el usuario').cancelReasonMessage,
        isNull,
      );
    });

    test('copyWith conserva y reemplaza cancelReason', () {
      final o = _order(cancelReason: 'INSUFFICIENT_STOCK: x');
      expect(o.copyWith(id: 'o2').cancelReason, 'INSUFFICIENT_STOCK: x');
      expect(o.copyWith(cancelReason: 'otro').cancelReason, 'otro');
    });
  });
}
