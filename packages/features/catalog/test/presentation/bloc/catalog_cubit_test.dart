import 'dart:async';

import 'package:catalog/catalog.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements CatalogRepository {
  final List<({int page, int pageSize, String? search, String? categoryId})> calls = [];
  Future<Either<CatalogFailure, ProductsPage>> Function(int page, String? search, String? categoryId) handler =
      (page, _, __) async => Right(_emptyPage(page));
  Future<Either<CatalogFailure, List<Category>>> Function() categoriesHandler =
      () async => const Right([Category(id: 'home', name: 'Hogar')]);

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  }) async {
    calls.add((page: page, pageSize: pageSize, search: search, categoryId: categoryId));
    return handler(page, search, categoryId);
  }

  @override
  Future<Either<CatalogFailure, List<Category>>> getCategories() => categoriesHandler();

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) =>
      throw UnimplementedError();
}

ProductsPage _emptyPage(int page) =>
    ProductsPage(items: const [], page: page, pageSize: 20, total: 0, hasNext: false);

Product _p(String id, {String category = 'home'}) => Product(
      id: id,
      sku: 'SKU-$id',
      name: 'Name $id',
      category: Category(id: category, name: category),
      price: const Money(amount: 1000, currency: 'ARS'),
      stock: const Stock(available: 10),
      orderConstraints: const OrderConstraints(maxQuantityPerOrder: 5),
    );

ProductsPage _page(int page, List<Product> items, {required int total, required bool hasNext}) =>
    ProductsPage(items: items, page: page, pageSize: 20, total: total, hasNext: hasNext);

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

    test('stale first-page response is dropped when a newer load fires', () async {
      final firstCompleter = Completer<Either<CatalogFailure, ProductsPage>>();
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
    });

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
      pageCompleter.complete(Right(_page(2, [_p('2')], total: 5, hasNext: true)));
      await Future.wait([first, second]);

      expect(repo.calls.where((c) => c.page == 2), hasLength(1));
    });

    test('keeps existing items when loadMore fails and surfaces loadMoreError', () async {
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
    });
  });

  group('CatalogCubit filter changes', () {
    test('selectCategory resets pagination to page 1', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, categoryId) async => Right(_page(
              page,
              [_p('$page', category: categoryId ?? 'home')],
              total: 5,
              hasNext: false,
            ));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      cubit.selectCategory('home');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls.last.page, 1);
      expect(repo.calls.last.categoryId, 'home');
    });

    test('setQuery debounces and only fires once', () async {
      final repo = _FakeRepo()
        ..handler = (page, search, _) async =>
            Right(_page(page, const [], total: 0, hasNext: false));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      cubit.setQuery('a');
      cubit.setQuery('ab');
      cubit.setQuery('abc');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final queryCalls = repo.calls.where((c) => c.search == 'abc');
      expect(queryCalls, hasLength(1));
    });
  });
}
