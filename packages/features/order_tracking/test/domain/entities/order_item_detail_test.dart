import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_item_detail.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:orders/orders.dart';
import 'package:orders_test_builders/orders_test_builders.dart';

void main() {
  group('OrderItemDetail.name', () {
    test('prefiere el nombre del producto hidratado', () {
      final detail = OrderItemDetail(
        item: anOrderItem(productName: 'del back'),
        product: aProduct(name: 'del catalogo'),
      );

      expect(detail.name, 'del catalogo');
    });

    test('cae al nombre del item cuando no hay producto', () {
      final detail = OrderItemDetail(item: anOrderItem(productName: 'del back'));

      expect(detail.name, 'del back');
    });

    test('cae al productId cuando no hay producto ni nombre', () {
      final detail = OrderItemDetail(
        item: anOrderItem(productId: 'p-42', productName: ''),
      );

      expect(detail.name, 'p-42');
    });
  });

  group('OrderItemDetail.unitPrice y subtotal', () {
    test('usa el precio del catalogo cuando hay producto', () {
      final detail = OrderItemDetail(
        item: anOrderItem(quantity: 3, unitPrice: aMoney(amount: 100)),
        product: aProduct(price: aMoney(amount: 250)),
      );

      expect(detail.unitPrice.amount, 250);
      expect(detail.subtotal.amount, 750);
    });

    test('cae al precio del item cuando el fetch de catalogo fallo', () {
      final detail = OrderItemDetail(
        item: anOrderItem(quantity: 2, unitPrice: aMoney(amount: 100)),
      );

      expect(detail.unitPrice.amount, 100);
      expect(detail.subtotal.amount, 200);
    });
  });

  group('OrderItemDetail.imageUrl', () {
    test('es null sin producto, porque el OrderItem no trae imagen', () {
      expect(OrderItemDetail(item: anOrderItem()).imageUrl, isNull);
    });
  });

  group('OrderStatusChange', () {
    test('conserva el estado viejo y el nuevo', () {
      const change = OrderStatusChange(
        orderId: 'o-1',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.inProgress,
      );

      expect(change.orderId, 'o-1');
      expect(change.oldStatus, OrderStatus.pending);
      expect(change.newStatus, OrderStatus.inProgress);
    });
  });
}
