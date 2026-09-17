import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeCatalogRepository', () {
    test('falla por defecto, para que un test que no lo configura no pase por accidente', () async {
      final fake = FakeCatalogRepository();

      expect((await fake.getProductById('p-1')).isLeft(), isTrue);
      expect((await fake.getProducts()).isLeft(), isTrue);
      expect((await fake.getCategories()).isLeft(), isTrue);
    });

    test('devuelve el producto que le configuran', () async {
      final fake = FakeCatalogRepository()
        ..onGetProductById = (id) => Right(aProduct(id: id));

      final result = await fake.getProductById('p-7');

      expect(result.getOrElse(() => aProduct()).id, 'p-7');
    });

    test('registra los ids pedidos, en orden', () async {
      final fake = FakeCatalogRepository();

      await fake.getProductById('p-1');
      await fake.getProductById('p-2');

      expect(fake.requestedIds, ['p-1', 'p-2']);
    });
  });
}
