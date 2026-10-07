import 'package:commons/commons.dart';
import 'package:catalog/src/data/dtos/order_constraints_dto.dart';
import 'package:catalog/src/data/dtos/price_dto.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:catalog/src/data/dtos/product_image_dto.dart';
import 'package:catalog/src/data/dtos/product_location_dto.dart';
import 'package:catalog/src/data/dtos/spec_dto.dart';
import 'package:catalog/src/data/dtos/stock_dto.dart';
import 'package:catalog/src/domain/entities/money.dart';
import 'package:catalog/src/domain/entities/order_constraints.dart';
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/product_category.dart';
import 'package:catalog/src/domain/entities/product_image.dart';
import 'package:catalog/src/domain/entities/product_location.dart';
import 'package:catalog/src/domain/entities/spec.dart';
import 'package:catalog/src/domain/entities/stock.dart';

extension ProductDtoMapper on ProductDto {
  Product toEntity() {
    // Un producto sin precio es un error de contrato: mejor cortar acá (la UI
    // muestra error con "Reintentar") que mostrar $0 y dejarlo comprar gratis.
    final priceDto = price;
    if (priceDto == null) {
      throw FormatException('Producto $id sin price');
    }
    final imgs = images.map((i) => i.toEntity()).toList(growable: false);
    return Product(
      id: id,
      sku: sku,
      name: name,
      description: description,
      category: ProductCategory.tryParse(category) ?? ProductCategory.otros,
      price: priceDto.toEntity(),
      stock: stock?.toEntity() ?? Stock.empty,
      orderConstraints:
          orderConstraints?.toEntity() ?? OrderConstraints.defaults,
      imageUrl: _pickThumbUrl(imgs, imageUrl),
      location: location?.toEntity(),
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
      images: imgs.isEmpty ? null : imgs,
      specs: specs.isEmpty ? null : specs.map((s) => s.toEntity()).toList(),
    );
  }
}

extension ProductImageDtoMapper on ProductImageDto {
  ProductImage toEntity() => ProductImage(
        // Resolvemos cualquier URL relativa del back (MinIO devuelve
        // `/api/v1/files/...`). Las absolutas (picsum/seed) pasan tal cual.
        url: ImageUrlResolver.resolve(url) ?? url,
        alt: alt,
        isPrimary: isPrimary,
      );
}

extension SpecDtoMapper on SpecDto {
  Spec toEntity() => Spec(label: label, value: value);
}

extension PriceDtoMapper on PriceDto {
  Money toEntity() =>
      Money(amount: amountCents, currency: currency, taxIncluded: taxIncluded);
}

extension StockDtoMapper on StockDto {
  Stock toEntity() => Stock(
        available: available,
        reserved: reserved,
        min: min,
        lowStockThreshold: lowStockThreshold,
      );
}

extension OrderConstraintsDtoMapper on OrderConstraintsDto {
  OrderConstraints toEntity() => OrderConstraints(
        maxQuantityPerOrder:
            maxQuantityPerOrder ?? OrderConstraints.defaults.maxQuantityPerOrder,
      );
}

extension ProductLocationDtoMapper on ProductLocationDto {
  ProductLocation? toEntity() {
    if (idZone == null || idLine == null || idPosition == null || height == null) {
      return null;
    }
    return ProductLocation(
      idZone: idZone!,
      idLine: idLine!,
      idPosition: idPosition!,
      height: height!,
    );
  }
}

String? _pickThumbUrl(List<ProductImage> imgs, String? flat) {
  if (flat != null && flat.isNotEmpty) return ImageUrlResolver.resolve(flat);
  if (imgs.isEmpty) return null;
  final primary = imgs.firstWhere(
    (i) => i.isPrimary,
    orElse: () => imgs.first,
  );
  return primary.url.isEmpty ? null : primary.url;
}
