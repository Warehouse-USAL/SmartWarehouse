import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';

void main() {
  test('label en castellano para cada estado', () {
    expect(OrderStatus.pending.label, 'Pendiente');
    expect(OrderStatus.inProgress.label, 'En progreso');
    expect(OrderStatus.completed.label, 'Completado');
    expect(OrderStatus.cancelled.label, 'Cancelado');
  });

  test('isCancellable solo para ordenes que no terminaron', () {
    expect(OrderStatus.pending.isCancellable, isTrue);
    expect(OrderStatus.inProgress.isCancellable, isTrue);
    expect(OrderStatus.completed.isCancellable, isFalse);
    expect(OrderStatus.cancelled.isCancellable, isFalse);
  });

  test('canReorder solo para ordenes que ya no se mueven', () {
    expect(OrderStatus.pending.canReorder, isFalse);
    expect(OrderStatus.inProgress.canReorder, isFalse);
    expect(OrderStatus.completed.canReorder, isTrue);
    expect(OrderStatus.cancelled.canReorder, isTrue);
  });

  group('humanizeCancelReason', () {
    test('traduce INSUFFICIENT_STOCK a copy en castellano', () {
      expect(
        humanizeCancelReason('INSUFFICIENT_STOCK'),
        'Cancelada por falta de stock',
      );
    });

    test('codigo desconocido devuelve null (no se muestra crudo)', () {
      expect(humanizeCancelReason('SOME_FUTURE_CODE'), isNull);
    });

    test('null y vacio devuelven null', () {
      expect(humanizeCancelReason(null), isNull);
      expect(humanizeCancelReason(''), isNull);
      expect(humanizeCancelReason('   '), isNull);
    });

    test('texto libre ya legible pasa tal cual', () {
      expect(
        humanizeCancelReason('Cancelada por el usuario desde la app'),
        'Cancelada por el usuario desde la app',
      );
    });
  });
}
