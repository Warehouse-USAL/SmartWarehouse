import 'package:catalog/src/presentation/widgets/recommendations_carousel.dart';
import 'package:flutter/material.dart';
import 'package:catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// catalog no puede dev-depender de catalog_test_builders (ciclo): factory
/// minimo local.
Product aProduct({required String id, String name = 'Producto'}) => Product(
  id: id,
  sku: 'SKU-$id',
  name: name,
  category: ProductCategory.otros,
  price: const Money(amount: 1000, currency: 'ARS'),
  stock: const Stock(available: 5),
  orderConstraints: const OrderConstraints(maxQuantityPerOrder: 5),
);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required Future<List<Product>> Function() load,
    void Function(Product)? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecommendationsCarousel(
              load: load,
              onProductTap: onTap ?? (_) {},
              // El timer de auto-scroll es infinito: apagado en tests.
              autoScroll: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('muestra heading y una card por recomendado', (tester) async {
    await pump(
      tester,
      load: () async => [
        aProduct(id: 'r1', name: 'Pasta selladora'),
        aProduct(id: 'r2', name: 'Guantes nitrilo'),
      ],
    );

    expect(find.text('Suelen llevarse juntos'), findsOneWidget);
    expect(find.byType(ProductCard), findsNWidgets(2));
    expect(find.text('Pasta selladora'), findsOneWidget);
  });

  testWidgets('sin recomendaciones la seccion desaparece entera', (
    tester,
  ) async {
    await pump(tester, load: () async => []);

    expect(find.text('Suelen llevarse juntos'), findsNothing);
    expect(find.byType(ProductCard), findsNothing);
  });

  testWidgets('tocar una card dispara onProductTap con ese producto', (
    tester,
  ) async {
    Product? tapped;
    await pump(
      tester,
      load: () async => [aProduct(id: 'r1', name: 'Pasta selladora')],
      onTap: (p) => tapped = p,
    );

    await tester.tap(find.byType(ProductCard));
    await tester.pump();

    expect(tapped?.id, 'r1');
  });

  testWidgets('scrollea horizontal, no rompe el layout vertical', (
    tester,
  ) async {
    await pump(
      tester,
      load: () async => [for (var i = 0; i < 8; i++) aProduct(id: 'r$i')],
    );

    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.scrollDirection, Axis.horizontal);
    expect(tester.takeException(), isNull);
  });
}
