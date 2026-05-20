import 'package:catalog/src/data/repositories/mock_catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockCatalogRepository repo;

  setUp(() {
    repo = MockCatalogRepository();
  });

  group('MockCatalogRepository.getProducts', () {
    test('returns first page with pagination metadata', () async {
      final result = await repo.getProducts(page: 1, pageSize: 20);
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(20));
          expect(page.page, 1);
          expect(page.pageSize, 20);
          expect(page.total, 45);
          expect(page.hasNext, isTrue);
        },
      );
    });

    test('returns last partial page with hasNext=false', () async {
      final result = await repo.getProducts(page: 3, pageSize: 20);
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(5));
          expect(page.page, 3);
          expect(page.total, 45);
          expect(page.hasNext, isFalse);
        },
      );
    });

    test('filters by categoryId before paginating', () async {
      final result = await repo.getProducts(
        page: 1,
        pageSize: 20,
        categoryId: 'books',
      );
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(9));
          expect(page.total, 9);
          expect(page.hasNext, isFalse);
          expect(page.items.every((p) => p.category.id == 'books'), isTrue);
        },
      );
    });

    test('filters by search (case-insensitive name/SKU substring)', () async {
      final result = await repo.getProducts(
        page: 1,
        pageSize: 20,
        search: 'cafe',
      );
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(1));
          expect(page.items.first.id, 'p15');
        },
      );
    });
  });
}
