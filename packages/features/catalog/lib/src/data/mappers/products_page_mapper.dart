import 'dart:developer';

import 'package:catalog/src/data/dtos/products_page_dto.dart';
import 'package:catalog/src/data/mappers/product_mapper.dart';
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/products_page.dart';

extension ProductsPageDtoMapper on ProductsPageDto {
  /// Convierte la página devuelta por el back (0-indexed) a la entity del
  /// dominio (1-indexed). Si no viene `pagination`, asume página única.
  ProductsPage toEntity() {
    // Una fila inválida (p.ej. sin precio) se saltea con log en vez de tirar
    // toda la página: el resto del catálogo sigue siendo usable.
    final items = products
        .map((p) {
          try {
            return p.toEntity();
          } on FormatException catch (e) {
            log('Producto inválido salteado en /products: $e');
            return null;
          }
        })
        .whereType<Product>()
        .toList(growable: false);
    final p = pagination;
    if (p == null) {
      return ProductsPage(
        items: items,
        page: 1,
        pageSize: items.length,
        total: items.length,
        hasNext: false,
      );
    }
    final clientPage = p.page + 1;
    return ProductsPage(
      items: items,
      page: clientPage,
      pageSize: p.size,
      total: p.totalElements,
      hasNext: clientPage < p.totalPages,
    );
  }
}
