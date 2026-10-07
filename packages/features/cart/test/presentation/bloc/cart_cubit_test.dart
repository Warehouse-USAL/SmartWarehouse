import 'package:bloc_test/bloc_test.dart';
import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart';
import 'package:cart/src/data/repositories/in_memory_cart_repository.dart';
import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/presentation/bloc/cart_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';

/// `Cart` no implementa `==`, así que no se puede comparar instancias en el
/// `expect` de blocTest. Este matcher afirma sobre los campos.
Matcher cartWith({required int itemCount, required int lineCount}) =>
    isA<Cart>()
        .having((c) => c.itemCount, 'itemCount', itemCount)
        .having((c) => c.items.length, 'lineCount', lineCount);

void main() {
  late InMemoryCartRepository repo;

  setUp(() => repo = InMemoryCartRepository());

  test('initial state is the repository current cart', () {
    repo.add(aProduct(id: 'p-1'), quantity: 2);

    final cubit = CartCubit(repo);

    expect(cubit.state.itemCount, 2);
    cubit.close();
  });

  test('initial state of an empty repository is an empty cart', () {
    final cubit = CartCubit(repo);

    expect(cubit.state.isEmpty, isTrue);
    cubit.close();
  });

  blocTest<CartCubit, Cart>(
    'add emits a cart containing the product',
    build: () => CartCubit(repo),
    act: (cubit) => cubit.add(aProduct(id: 'p-1')),
    expect: () => [cartWith(itemCount: 1, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'add with a quantity emits that quantity',
    build: () => CartCubit(repo),
    act: (cubit) => cubit.add(aProduct(id: 'p-1'), quantity: 4),
    expect: () => [cartWith(itemCount: 4, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'adding the same product twice accumulates onto one line',
    build: () => CartCubit(repo),
    act: (cubit) => cubit
      ..add(aProduct(id: 'p-1'), quantity: 2)
      ..add(aProduct(id: 'p-1'), quantity: 3),
    expect: () => [
      cartWith(itemCount: 2, lineCount: 1),
      cartWith(itemCount: 5, lineCount: 1),
    ],
  );

  blocTest<CartCubit, Cart>(
    'remove emits a cart without that product',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));
      return repo.current;
    },
    act: (cubit) => cubit.remove('p-1'),
    expect: () => [cartWith(itemCount: 1, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'updateQuantity emits the new quantity',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'), quantity: 1);
      return repo.current;
    },
    // 4 queda dentro del clamp del builder (maxQuantityPerOrder: 5).
    act: (cubit) => cubit.updateQuantity('p-1', 4),
    expect: () => [cartWith(itemCount: 4, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'updateQuantity to zero emits an empty cart',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'), quantity: 3);
      return repo.current;
    },
    act: (cubit) => cubit.updateQuantity('p-1', 0),
    expect: () => [cartWith(itemCount: 0, lineCount: 0)],
  );

  blocTest<CartCubit, Cart>(
    'clear emits an empty cart',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);
      repo.add(aProduct(id: 'p-2'), quantity: 1);
      return repo.current;
    },
    act: (cubit) => cubit.clear(),
    expect: () => [cartWith(itemCount: 0, lineCount: 0)],
  );

  blocTest<CartCubit, Cart>(
    'every action emits, even when the resulting cart is unchanged',
    build: () => CartCubit(repo),
    act: (cubit) => cubit.remove('p-inexistente'),
    expect: () => [cartWith(itemCount: 0, lineCount: 0)],
  );

  revalidateTests();
}

/// Catálogo fake para revalidate: responde por id según el mapa configurado.
class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.byId);

  /// id -> Right(producto fresco) | Left(failure)
  final Map<String, Either<CatalogFailure, Product>> byId;

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async =>
      byId[id] ?? const Left(CatalogFailure('sin configurar'));

  @override
  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories() =>
      throw UnimplementedError();

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    ProductCategory? category,
  }) => throw UnimplementedError();
}

void revalidateTests() {
  group('revalidate', () {
    late InMemoryCartRepository repo;

    setUp(() => repo = InMemoryCartRepository());

    test('refresca el stock del producto con la versión del catálogo', () async {
      repo.add(aProduct(id: 'p-1', stock: aStock(available: 10)), quantity: 4);
      final fresh = aProduct(id: 'p-1', stock: aStock(available: 2));
      final cubit = CartCubit(
        repo,
        catalogRepository: _FakeCatalogRepository({'p-1': Right(fresh)}),
      );

      await cubit.revalidate();

      // La cantidad pedida NO se ajusta sola: la línea pasa a bloquear.
      expect(cubit.state.items.single.quantity, 4);
      expect(cubit.state.items.single.product.stock.available, 2);
      expect(cubit.state.hasInvalidQuantities, isTrue);
      expect(cubit.state.invalidItems.single.product.id, 'p-1');
      await cubit.close();
    });

    test('marca no disponible cuando el catálogo devuelve 404', () async {
      repo.add(aProduct(id: 'p-1'), quantity: 1);
      final cubit = CartCubit(
        repo,
        catalogRepository: _FakeCatalogRepository({
          'p-1': const Left(CatalogFailure('Producto no encontrado', true)),
        }),
      );

      await cubit.revalidate();

      expect(cubit.state.items.single.unavailable, isTrue);
      expect(cubit.state.hasInvalidQuantities, isTrue);
      await cubit.close();
    });

    test('un error de red NO castiga la línea', () async {
      repo.add(aProduct(id: 'p-1', stock: aStock(available: 10)), quantity: 2);
      final cubit = CartCubit(
        repo,
        catalogRepository: _FakeCatalogRepository({
          'p-1': const Left(CatalogFailure('timeout')),
        }),
      );

      await cubit.revalidate();

      expect(cubit.state.items.single.unavailable, isFalse);
      expect(cubit.state.hasInvalidQuantities, isFalse);
      await cubit.close();
    });

    test('una revalidación posterior exitosa limpia el no disponible', () async {
      repo.add(aProduct(id: 'p-1'), quantity: 1);
      repo.markUnavailable('p-1');
      final fresh = aProduct(id: 'p-1', stock: aStock(available: 5));
      final cubit = CartCubit(
        repo,
        catalogRepository: _FakeCatalogRepository({'p-1': Right(fresh)}),
      );

      await cubit.revalidate();

      expect(cubit.state.items.single.unavailable, isFalse);
      expect(cubit.state.hasInvalidQuantities, isFalse);
      await cubit.close();
    });

    test('sin catálogo inyectado es un no-op', () async {
      repo.add(aProduct(id: 'p-1'), quantity: 1);
      final cubit = CartCubit(repo);

      await cubit.revalidate();

      expect(cubit.state.itemCount, 1);
      await cubit.close();
    });
  });
}
