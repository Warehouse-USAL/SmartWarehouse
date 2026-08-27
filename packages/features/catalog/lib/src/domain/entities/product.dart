import 'package:catalog/src/domain/entities/money.dart';
import 'package:catalog/src/domain/entities/product_category.dart';
import 'package:catalog/src/domain/entities/order_constraints.dart';
import 'package:catalog/src/domain/entities/product_image.dart';
import 'package:catalog/src/domain/entities/product_location.dart';
import 'package:catalog/src/domain/entities/spec.dart';
import 'package:catalog/src/domain/entities/stock.dart';

/// Producto del catálogo. Estructura alineada al contrato
/// `docs/superpowers/specs/2026-05-19-api-contracts-design.md`.
///
/// Campos siempre presentes: id, sku, name, category, price, stock, orderConstraints.
/// Campos de la pantalla de detalle (nullables si solo se obtuvo el item desde
/// el listado): description, images, specs.
class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.orderConstraints,
    this.imageUrl,
    this.location,
    this.createdAt,
    this.description,
    this.images,
    this.specs,
  });

  final String id;
  final String sku;
  final String name;
  final ProductCategory category;
  final Money price;
  final Stock stock;
  final OrderConstraints orderConstraints;

  /// Thumb del listado.
  final String? imageUrl;
  final ProductLocation? location;
  final DateTime? createdAt;

  // Solo presentes en detalle:
  final String? description;
  final List<ProductImage>? images;
  final List<Spec>? specs;

  /// Máximo permitido por orden: el mínimo entre el stock disponible y el
  /// `maxQuantityPerOrder` definido en `order_constrains`.
  int get maxOrderableQuantity {
    final byStock = stock.available;
    final byPolicy = orderConstraints.maxQuantityPerOrder;
    return byStock < byPolicy ? byStock : byPolicy;
  }

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) || sku.toLowerCase().contains(q);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
