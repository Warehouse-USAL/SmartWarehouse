import 'package:cart/cart.dart';
import 'package:catalog/catalog.dart';
import 'package:catalog/src/presentation/bloc/product_detail_cubit.dart';
import 'package:catalog/src/presentation/pages/product_detail_page.dart';
import 'package:dartz/dartz.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_support/test_support.dart';

/// catalog no puede dev-depender de catalog_test_builders (ciclo): factory
/// mínimo local.
Product aProduct({required String id, String name = 'Producto'}) => Product(
  id: id,
  sku: 'SKU-$id',
  name: name,
  category: ProductCategory.otros,
  price: const Money(amount: 1000, currency: 'ARS'),
  stock: const Stock(available: 5),
  orderConstraints: const OrderConstraints(maxQuantityPerOrder: 5),
);

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.product);

  final Product product;

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async =>
      Right(product);

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

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // El bottom nav de la página resuelve el CartCubit real del Injector.
    CartFeatureBuilder.injectDependencies();
  });
  tearDown(resetInjector);

  Future<void> pump(
    WidgetTester tester, {
    required void Function(Product, {bool fromRecommendation}) onAddToCart,
    bool fromRecommendation = false,
  }) async {
    final cubit = ProductDetailCubit(
      repository: _FakeCatalogRepository(aProduct(id: 'p-1')),
      productId: 'p-1',
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailPage(
          cubit: cubit,
          onAddToCart: onAddToCart,
          fromRecommendation: fromRecommendation,
        ),
      ),
    );
    // Dos pumps: uno para resolver el future del load y otro para el rebuild.
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'con fromRecommendation=true el agregar dispara el callback con el flag',
    (tester) async {
      Product? added;
      bool? flagged;
      await pump(
        tester,
        fromRecommendation: true,
        onAddToCart: (p, {fromRecommendation = false}) {
          added = p;
          flagged = fromRecommendation;
        },
      );

      await tester.tap(find.byKey(E2eKeys.productDetailAddToCart));
      await tester.pump();

      expect(added?.id, 'p-1');
      expect(flagged, isTrue);
    },
  );

  testWidgets('por defecto el agregar sale sin el flag (orgánico)', (
    tester,
  ) async {
    bool? flagged;
    await pump(
      tester,
      onAddToCart: (p, {fromRecommendation = false}) {
        flagged = fromRecommendation;
      },
    );

    await tester.tap(find.byKey(E2eKeys.productDetailAddToCart));
    await tester.pump();

    expect(flagged, isFalse);
  });
}
