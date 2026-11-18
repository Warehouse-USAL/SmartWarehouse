import 'dart:async';

import 'package:catalog/catalog.dart';
import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements CatalogRepository {
  final List<
    ({int page, int pageSize, String? search, ProductCategory? category})
  >
  calls = [];
  Future<Either<CatalogFailure, ProductsPage>> Function(
    int page,
    String? search,
    ProductCategory? category,
  )
  handler = (page, _, __) async => Right(_emptyPage(page));
  Future<Either<CatalogFailure, List<ProductCategory>>> Function()
  categoriesHandler = () async => Right(ProductCategory.values);

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    ProductCategory? category,
  }) async {
    calls.add((
      page: page,
      pageSize: pageSize,
      search: search,
      category: category,
    ));
    return handler(page, search, category);
  }

  @override
  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories() =>
      categoriesHandler();

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) =>
      throw UnimplementedError();
}

ProductsPage _emptyPage(int page) => ProductsPage(
  items: const [],
  page: page,
  pageSize: 20,
  total: 0,
  hasNext: false,
);

Product _p(
  String id, {
  ProductCategory category = ProductCategory.otros,
  int stock = 10,
}) => Product(
  id: id,
  sku: 'SKU-$id',
  name: 'Name $id',
  category: category,
  price: const Money(amount: 1000, currency: 'ARS'),
  stock: Stock(available: stock),
  orderConstraints: const OrderConstraints(maxQuantityPerOrder: 5),
);

ProductsPage _page(
  int page,
  List<Product> items, {
  required int total,
  required bool hasNext,
}) => ProductsPage(
  items: items,
  page: page,
  pageSize: 20,
  total: total,
  hasNext: hasNext,
);

void main() {
  group('CatalogCubit.load', () {
    test('emits Loading then Ready with first page', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async =>
            Right(_page(1, [_p('1'), _p('2')], total: 30, hasNext: true));
      final cubit = CatalogCubit(repo);
      final emitted = <CatalogState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.first, isA<CatalogLoading>());
      expect(emitted.last, isA<CatalogReady>());
      final ready = emitted.last as CatalogReady;
      expect(ready.products, hasLength(2));
      expect(ready.page, 1);
      expect(ready.total, 30);
      expect(ready.hasNext, isTrue);
      expect(ready.isLoadingMore, isFalse);
    });

    test(
      'stale first-page response is dropped when a newer load fires',
      () async {
        final firstCompleter =
            Completer<Either<CatalogFailure, ProductsPage>>();
        var callCount = 0;
        final repo = _FakeRepo()
          ..handler = (page, search, _) async {
            callCount++;
            if (callCount == 1) return firstCompleter.future;
            return Right(_page(1, [_p('new')], total: 1, hasNext: false));
          };
        final cubit = CatalogCubit(repo);

        final first = cubit.load();
        final second = cubit.load();
        firstCompleter.complete(
          Right(_page(1, [_p('old')], total: 1, hasNext: false)),
        );
        await Future.wait([first, second]);

        final ready = cubit.state as CatalogReady;
        expect(ready.products.single.id, 'new');
      },
    );

    test('emits CatalogError when first-page load fails', () async {
      final repo = _FakeRepo()
        ..handler = (_, __, ___) async => const Left(CatalogFailure('boom'));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      expect(cubit.state, isA<CatalogError>());
      expect((cubit.state as CatalogError).message, 'boom');
    });
  });

  group('CatalogCubit.loadMore', () {
    test('appends next page and updates pagination', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async {
          if (page == 1) {
            return Right(_page(1, [_p('1'), _p('2')], total: 4, hasNext: true));
          }
          return Right(_page(2, [_p('3'), _p('4')], total: 4, hasNext: false));
        };
      final cubit = CatalogCubit(repo);
      await cubit.load();
      await cubit.loadMore();

      final ready = cubit.state as CatalogReady;
      expect(ready.products.map((p) => p.id), ['1', '2', '3', '4']);
      expect(ready.page, 2);
      expect(ready.hasNext, isFalse);
      expect(ready.isLoadingMore, isFalse);
    });

    test('is a no-op when hasNext is false', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async =>
            Right(_page(1, [_p('1')], total: 1, hasNext: false));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      await cubit.loadMore();
      expect(repo.calls, isEmpty);
    });

    test('is a no-op when already loading more', () async {
      final repo = _FakeRepo();
      var firstCall = true;
      final pageCompleter = Completer<Either<CatalogFailure, ProductsPage>>();
      repo.handler = (page, _, __) async {
        if (page == 1) {
          return Right(_page(1, [_p('1')], total: 5, hasNext: true));
        }
        if (firstCall) {
          firstCall = false;
          return pageCompleter.future;
        }
        return Right(_page(2, [_p('2')], total: 5, hasNext: true));
      };
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      final first = cubit.loadMore();
      final second = cubit.loadMore(); // should be ignored
      pageCompleter.complete(
        Right(_page(2, [_p('2')], total: 5, hasNext: true)),
      );
      await Future.wait([first, second]);

      expect(repo.calls.where((c) => c.page == 2), hasLength(1));
    });

    test(
      'keeps existing items when loadMore fails and surfaces loadMoreError',
      () async {
        final repo = _FakeRepo()
          ..handler = (page, _, __) async {
            if (page == 1) {
              return Right(_page(1, [_p('1')], total: 5, hasNext: true));
            }
            return const Left(CatalogFailure('net'));
          };
        final cubit = CatalogCubit(repo);
        await cubit.load();
        await cubit.loadMore();

        final ready = cubit.state as CatalogReady;
        expect(ready.products, hasLength(1));
        expect(ready.loadMoreError, 'net');
        expect(ready.isLoadingMore, isFalse);
        expect(ready.hasNext, isTrue);
      },
    );
  });

  group('CatalogCubit filter changes', () {
    test('selectCategory resets pagination to page 1', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, category) async => Right(
          _page(
            page,
            [_p('$page', category: category ?? ProductCategory.otros)],
            total: 5,
            hasNext: false,
          ),
        );
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      cubit.selectCategory(ProductCategory.tecnologia);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls.last.page, 1);
      expect(repo.calls.last.category, ProductCategory.tecnologia);
    });

    test('setQuery alone does not trigger a fetch', () async {
      final repo = _FakeRepo()
        ..handler = (page, search, _) async =>
            Right(_page(page, const [], total: 0, hasNext: false));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      cubit.setQuery('a');
      cubit.setQuery('ab');
      cubit.setQuery('abc');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repo.calls, isEmpty);
    });

    test('submitSearch fires fetch with the query', () async {
      final repo = _FakeRepo()
        ..handler = (page, search, _) async =>
            Right(_page(page, const [], total: 0, hasNext: false));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      await cubit.submitSearch('abc');

      expect(repo.calls, hasLength(1));
      expect(repo.calls.single.search, 'abc');
      expect(repo.calls.single.page, 1);
    });
  });

  group('CatalogCubit sin stock', () {
    List<Product> outOfStock(int from, int n) => [
      for (var i = from; i < from + n; i++) _p('x$i', stock: 0),
    ];

    test('load oculta los productos sin stock', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async => Right(
          _page(
            1,
            [_p('1'), _p('2', stock: 0), _p('3')],
            total: 3,
            hasNext: false,
          ),
        );
      final cubit = CatalogCubit(repo);

      await cubit.load();

      final s = cubit.state as CatalogReady;
      expect(s.products.map((p) => p.id), ['1', '3']);
      expect(s.total, 2);
      await cubit.close();
    });

    test('stock negativo también se oculta', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async => Right(
          _page(1, [_p('1', stock: -3), _p('2')], total: 2, hasNext: false),
        );
      final cubit = CatalogCubit(repo);

      await cubit.load();

      expect((cubit.state as CatalogReady).products.map((p) => p.id), ['2']);
      await cubit.close();
    });

    test(
      'load sigue pidiendo páginas si el filtro dejó la primera corta',
      () async {
        final repo = _FakeRepo()
          ..handler = (page, _, __) async => Right(
            page == 1
                ? _page(1, outOfStock(0, 20), total: 22, hasNext: true)
                : _page(2, [_p('a'), _p('b')], total: 22, hasNext: false),
          );
        final cubit = CatalogCubit(repo);

        await cubit.load();

        final s = cubit.state as CatalogReady;
        expect(s.products.map((p) => p.id), ['a', 'b']);
        expect(s.page, 2);
        expect(s.hasNext, isFalse);
        expect(s.total, 2);
        expect(repo.calls.map((c) => c.page), [1, 2]);
        await cubit.close();
      },
    );

    test('load no pide de más si no se ocultó nada', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async =>
            Right(_page(1, [_p('1')], total: 30, hasNext: true));
      final cubit = CatalogCubit(repo);

      await cubit.load();

      expect(repo.calls, hasLength(1));
      await cubit.close();
    });

    test('el relleno automático respeta búsqueda y categoría', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async => Right(
          page == 1
              ? _page(1, outOfStock(0, 20), total: 21, hasNext: true)
              : _page(2, [_p('a')], total: 21, hasNext: false),
        );
      final cubit = CatalogCubit(repo);

      await cubit.submitSearch('cable');
      cubit.selectCategory(ProductCategory.values.first);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final last = repo.calls.last;
      expect(last.page, 2);
      expect(last.search, 'cable');
      expect(last.category, ProductCategory.values.first);
      expect((cubit.state as CatalogReady).products.single.id, 'a');
      await cubit.close();
    });

    test(
      'loadMore oculta sin stock y salta páginas enteras sin stock',
      () async {
        final repo = _FakeRepo()
          ..handler = (page, _, __) async => Right(switch (page) {
            1 => _page(
              1,
              [for (var i = 0; i < 20; i++) _p('p$i')],
              total: 50,
              hasNext: true,
            ),
            2 => _page(2, outOfStock(0, 20), total: 50, hasNext: true),
            _ => _page(
              3,
              [_p('z'), _p('y', stock: 0)],
              total: 50,
              hasNext: false,
            ),
          });
        final cubit = CatalogCubit(repo);
        await cubit.load();

        await cubit.loadMore();

        final s = cubit.state as CatalogReady;
        expect(s.products, hasLength(21));
        expect(s.products.last.id, 'z');
        expect(s.products.any((p) => p.stock.isOutOfStock), isFalse);
        expect(s.page, 3);
        expect(s.hasNext, isFalse);
        expect(s.total, 21);
        expect(s.isLoadingMore, isFalse);
        await cubit.close();
      },
    );

    test('el relleno tiene tope para no saturar el server', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async => Right(
          _page(page, outOfStock(page * 100, 20), total: 10000, hasNext: true),
        );
      final cubit = CatalogCubit(repo);

      await cubit.load();

      final s = cubit.state as CatalogReady;
      expect(s.products, isEmpty);
      expect(s.hasNext, isTrue);
      expect(repo.calls.length, lessThanOrEqualTo(5));
      await cubit.close();
    });
  });
}
