import 'package:cart/src/data/repositories/in_memory_cart_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';

void main() {
  late InMemoryCartRepository repo;

  setUp(() => repo = InMemoryCartRepository());

  group('add', () {
    test('adds a new product as one line', () {
      repo.add(aProduct(id: 'p-1'));

      expect(repo.current.items, hasLength(1));
      expect(repo.current.quantityOf('p-1'), 1);
    });

    test('adds the requested quantity', () {
      repo.add(aProduct(id: 'p-1'), quantity: 3);

      expect(repo.current.quantityOf('p-1'), 3);
    });

    test('accumulates onto the existing line instead of duplicating it', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);
      repo.add(aProduct(id: 'p-1'), quantity: 3);

      expect(repo.current.items, hasLength(1));
      expect(repo.current.quantityOf('p-1'), 5);
    });

    test('keeps different products on separate lines', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));

      expect(repo.current.items, hasLength(2));
    });

    test('ignores a quantity of zero', () {
      repo.add(aProduct(id: 'p-1'), quantity: 0);

      expect(repo.current.isEmpty, isTrue);
    });

    test('ignores a negative quantity', () {
      repo.add(aProduct(id: 'p-1'), quantity: -2);

      expect(repo.current.isEmpty, isTrue);
    });
  });

  group('add con fromRecommendation', () {
    test('la línea nueva queda marcada como venida del carrusel', () {
      repo.add(aProduct(id: 'p-1'), fromRecommendation: true);

      expect(repo.current.items.single.fromRecommendation, isTrue);
    });

    test('por defecto la línea es orgánica (false)', () {
      repo.add(aProduct(id: 'p-1'));

      expect(repo.current.items.single.fromRecommendation, isFalse);
    });

    test('merge pegajoso: true + false queda true', () {
      // La recomendación ya influyó en que la línea exista: agregar más
      // cantidad por otro camino no borra ese origen.
      repo.add(aProduct(id: 'p-1'), fromRecommendation: true);
      repo.add(aProduct(id: 'p-1'), quantity: 2);

      expect(repo.current.items.single.fromRecommendation, isTrue);
      expect(repo.current.quantityOf('p-1'), 3);
    });

    test('merge pegajoso: false + true queda true', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-1'), fromRecommendation: true);

      expect(repo.current.items.single.fromRecommendation, isTrue);
    });

    test('false + false sigue false', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-1'));

      expect(repo.current.items.single.fromRecommendation, isFalse);
    });

    test('applyProductUpdate preserva el flag', () {
      repo.add(aProduct(id: 'p-1'), fromRecommendation: true);

      repo.applyProductUpdate('p-1', aProduct(id: 'p-1'));

      expect(repo.current.items.single.fromRecommendation, isTrue);
    });

    test('markUnavailable preserva el flag', () {
      repo.add(aProduct(id: 'p-1'), fromRecommendation: true);

      repo.markUnavailable('p-1');

      final line = repo.current.items.single;
      expect(line.unavailable, isTrue);
      expect(line.fromRecommendation, isTrue);
    });
  });

  group('remove', () {
    test('drops the line for that product', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));

      repo.remove('p-1');

      expect(repo.current.items, hasLength(1));
      expect(repo.current.quantityOf('p-1'), 0);
    });

    test('is a no-op for a product that is not in the cart', () {
      repo.add(aProduct(id: 'p-1'));

      repo.remove('p-inexistente');

      expect(repo.current.items, hasLength(1));
    });
  });

  group('updateQuantity', () {
    test('sets the quantity of an existing line', () {
      repo.add(aProduct(id: 'p-1'), quantity: 1);

      repo.updateQuantity('p-1', 3);

      expect(repo.current.quantityOf('p-1'), 3);
    });

    test(
      'clamps the quantity to maxOrderableQuantity (stock/max por orden)',
      () {
        // El builder usa maxQuantityPerOrder: 5, así que pedir 7 clampea a 5.
        repo.add(aProduct(id: 'p-1'), quantity: 1);

        repo.updateQuantity('p-1', 7);

        expect(repo.current.quantityOf('p-1'), 5);
      },
    );

    test('removes the line when the quantity drops to zero', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);

      repo.updateQuantity('p-1', 0);

      expect(repo.current.isEmpty, isTrue);
    });

    test('removes the line for a negative quantity', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);

      repo.updateQuantity('p-1', -1);

      expect(repo.current.isEmpty, isTrue);
    });

    test('is a no-op for a product that is not in the cart', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);

      repo.updateQuantity('p-inexistente', 9);

      expect(repo.current.quantityOf('p-1'), 2);
      expect(repo.current.items, hasLength(1));
    });
  });

  group('clear', () {
    test('empties the cart', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));

      repo.clear();

      expect(repo.current.isEmpty, isTrue);
    });

    test('is a no-op on an already empty cart', () {
      repo.clear();

      expect(repo.current.isEmpty, isTrue);
    });
  });

  group('current', () {
    test(
      'returns an unmodifiable view, so callers cannot mutate the store',
      () {
        repo.add(aProduct(id: 'p-1'));

        expect(
          () => repo.current.items.add(repo.current.items.first),
          throwsUnsupportedError,
        );
      },
    );
  });
}
