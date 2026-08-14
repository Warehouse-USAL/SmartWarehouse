import 'package:bloc_test/bloc_test.dart';
import 'package:cart/src/data/repositories/in_memory_cart_repository.dart';
import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/presentation/bloc/cart_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

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
    act: (cubit) => cubit.updateQuantity('p-1', 6),
    expect: () => [cartWith(itemCount: 6, lineCount: 1)],
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
}
