import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart';

/// Stand-in de [CatalogRepository] para tests de otros packages.
///
/// Reemplaza los `_FakeCatalog` duplicados a mano que el spec 4.3 marca por
/// nombre. Cada metodo delega en un callback reasignable, asi un test
/// configura solo lo que le importa.
///
/// Los defaults fallan a proposito: un test que consume el catalogo sin
/// configurarlo se esta apoyando en un valor que nadie eligio.
class FakeCatalogRepository implements CatalogRepository {
  Either<CatalogFailure, Product> Function(String id) onGetProductById =
      (_) => const Left(CatalogFailure('not configured'));

  Either<CatalogFailure, ProductsPage> Function() onGetProducts =
      () => const Left(CatalogFailure('not configured'));

  Either<CatalogFailure, List<ProductCategory>> Function() onGetCategories =
      () => const Left(CatalogFailure('not configured'));

  /// Ids pedidos a [getProductById], en orden. Sirve para afirmar que un
  /// cache evito un segundo fetch sin tener que mockear.
  final List<String> requestedIds = [];

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async {
    requestedIds.add(id);
    return onGetProductById(id);
  }

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    ProductCategory? category,
  }) async =>
      onGetProducts();

  @override
  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories() async =>
      onGetCategories();
}
