import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/remote_recommendations_repository.dart';
import 'package:order_tracking/src/domain/repositories/recommendations_repository.dart';

class _FakeHttpHelper implements HttpHelper {
  Either<HttpResponseError, HttpResponse> Function(
    String path,
    Map<String, dynamic>? query,
  )
  getHandler = (_, __) => throw UnimplementedError();

  String? lastPath;
  Map<String, dynamic>? lastQuery;

  @override
  String get baseUrl => 'http://localhost';

  @override
  void init() {}

  @override
  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noCache = false,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async {
    lastPath = path;
    lastQuery = queryParameters;
    return getHandler(path, queryParameters);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fallback espía: registra las llamadas y devuelve una lista fija.
class _SpyFallback implements RecommendationsRepository {
  int calls = 0;
  List<Product> result = const [];

  @override
  Future<List<Product>> recommendedFor(Product product, {int limit = 8}) async {
    calls++;
    return result;
  }
}

Either<HttpResponseError, HttpResponse> _recos(
  List<Map<String, Object>> list,
) => Right(HttpResponse(data: <String, dynamic>{'recommendations': list}));

void main() {
  late _FakeHttpHelper http;
  late FakeCatalogRepository catalog;
  late _SpyFallback fallback;
  late RemoteRecommendationsRepository repo;

  final current = aProduct(id: 'p-cur', sku: 'TEC-001');

  setUp(() {
    http = _FakeHttpHelper();
    catalog = FakeCatalogRepository();
    fallback = _SpyFallback();
    repo = RemoteRecommendationsRepository(
      httpHelper: http,
      catalogRepository: catalog,
      fallback: fallback,
    );
    // El catálogo resuelve cualquier búsqueda devolviendo un producto cuyo
    // sku coincide exacto con lo buscado, con stock.
    catalog.onGetProducts = () => const Right(ProductsPage.empty);
  });

  /// Configura la búsqueda del catálogo para resolver estos SKUs (el resto
  /// no devuelve match exacto).
  void stubCatalog(Map<String, Product> bySku) {
    catalog.onGetProducts = () => Right(
      ProductsPage(
        items: bySku.values.toList(),
        page: 1,
        pageSize: 20,
        total: bySku.length,
        hasNext: false,
      ),
    );
  }

  test('consulta el path publico con el sku del producto y el limit', () async {
    http.getHandler = (_, __) => _recos(const []);

    await repo.recommendedFor(current, limit: 5);

    expect(http.lastPath, RemoteRecommendationsRepository.cartPath);
    expect(http.lastQuery, {'skus': 'TEC-001', 'limit': '5'});
  });

  test(
    'resuelve los SKUs del motor a productos en el orden del score',
    () async {
      final p7 = aProduct(id: 'p7', sku: 'TEC-007');
      final p9 = aProduct(id: 'p9', sku: 'TEC-009');
      stubCatalog({'TEC-007': p7, 'TEC-009': p9});
      http.getHandler = (_, __) => _recos(const [
        {'sku': 'TEC-007', 'score': 0.87},
        {'sku': 'TEC-009', 'score': 0.80},
      ]);

      final result = await repo.recommendedFor(current);

      expect(result.map((p) => p.id), ['p7', 'p9']);
      expect(fallback.calls, 0);
    },
  );

  test('excluye el producto actual aunque el motor lo devuelva', () async {
    final p7 = aProduct(id: 'p7', sku: 'TEC-007');
    stubCatalog({'TEC-007': p7, 'TEC-001': current});
    http.getHandler = (_, __) => _recos(const [
      {'sku': 'TEC-001', 'score': 0.9},
      {'sku': 'TEC-007', 'score': 0.8},
    ]);

    final result = await repo.recommendedFor(current);

    expect(result.map((p) => p.id), ['p7']);
  });

  test('excluye recomendados sin stock', () async {
    final agotado = aProduct(
      id: 'p3',
      sku: 'TEC-003',
      stock: aStock(available: 0),
    );
    final ok = aProduct(id: 'p7', sku: 'TEC-007');
    stubCatalog({'TEC-003': agotado, 'TEC-007': ok});
    http.getHandler = (_, __) => _recos(const [
      {'sku': 'TEC-003', 'score': 0.9},
      {'sku': 'TEC-007', 'score': 0.5},
    ]);

    final result = await repo.recommendedFor(current);

    expect(result.map((p) => p.id), ['p7']);
  });

  test('un SKU que el catalogo no resuelve se saltea sin romper', () async {
    final ok = aProduct(id: 'p7', sku: 'TEC-007');
    stubCatalog({'TEC-007': ok});
    http.getHandler = (_, __) => _recos(const [
      {'sku': 'FANTASMA-99', 'score': 0.9},
      {'sku': 'TEC-007', 'score': 0.5},
    ]);

    final result = await repo.recommendedFor(current);

    expect(result.map((p) => p.id), ['p7']);
  });

  test('respeta el limite aunque el motor devuelva de mas', () async {
    final products = {
      for (var i = 0; i < 5; i++) 'SKU-$i': aProduct(id: 'p$i', sku: 'SKU-$i'),
    };
    stubCatalog(products);
    http.getHandler = (_, __) => _recos([
      for (var i = 0; i < 5; i++) {'sku': 'SKU-$i', 'score': 1.0 - i / 10},
    ]);

    final result = await repo.recommendedFor(current, limit: 2);

    expect(result, hasLength(2));
  });

  group('fallback a la co-compra local', () {
    test('cuando el servicio devuelve error HTTP', () async {
      fallback.result = [aProduct(id: 'local')];
      http.getHandler = (_, __) => Left(
        HttpResponseError(errorType: 'down', message: 'x', statusCode: 503),
      );

      final result = await repo.recommendedFor(current);

      expect(fallback.calls, 1);
      expect(result.single.id, 'local');
    });

    test('cuando el motor devuelve lista vacia', () async {
      fallback.result = [aProduct(id: 'local')];
      http.getHandler = (_, __) => _recos(const []);

      final result = await repo.recommendedFor(current);

      expect(fallback.calls, 1);
      expect(result.single.id, 'local');
    });

    test('cuando la respuesta viene malformada', () async {
      fallback.result = [aProduct(id: 'local')];
      http.getHandler = (_, __) =>
          Right(HttpResponse(data: 'esto no es json de recos'));

      final result = await repo.recommendedFor(current);

      expect(fallback.calls, 1);
      expect(result.single.id, 'local');
    });

    test('cuando ningun SKU resuelve a producto con stock', () async {
      fallback.result = [aProduct(id: 'local')];
      http.getHandler = (_, __) => _recos(const [
        {'sku': 'FANTASMA', 'score': 0.9},
      ]);

      final result = await repo.recommendedFor(current);

      expect(fallback.calls, 1);
      expect(result.single.id, 'local');
    });

    test('si el http lanza una excepcion tambien cae al fallback', () async {
      fallback.result = [aProduct(id: 'local')];
      http.getHandler = (_, __) => throw StateError('boom');

      final result = await repo.recommendedFor(current);

      expect(fallback.calls, 1);
      expect(result.single.id, 'local');
    });
  });
}
