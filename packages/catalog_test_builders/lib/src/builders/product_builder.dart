import 'package:catalog/catalog.dart';

import 'money_builder.dart';
import 'stock_builder.dart';

/// Construye un [Product] con defaults razonables.
///
/// `Product` define `==` solo por `id`, así que dos productos con el mismo id
/// son iguales aunque difieran en todo lo demás. Los tests que dependen de
/// distinguir productos tienen que pasar ids distintos.
Product aProduct({
  String id = 'p-1',
  String sku = 'SKU-1',
  String name = 'Producto de prueba',
  ProductCategory category = ProductCategory.herramientas,
  Money? price,
  Stock? stock,
  OrderConstraints? orderConstraints,
  String? imageUrl,
  String? description,
}) =>
    Product(
      id: id,
      sku: sku,
      name: name,
      category: category,
      price: price ?? aMoney(),
      stock: stock ?? aStock(),
      orderConstraints:
          orderConstraints ?? const OrderConstraints(maxQuantityPerOrder: 5),
      imageUrl: imageUrl,
      description: description,
    );
