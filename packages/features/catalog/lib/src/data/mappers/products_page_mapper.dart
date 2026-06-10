import 'package:catalog/src/data/dtos/products_page_dto.dart';
import 'package:catalog/src/data/mappers/product_mapper.dart';
import 'package:catalog/src/domain/entities/products_page.dart';

extension ProductsPageDtoMapper on ProductsPageDto {
  /// Convierte la página devuelta por el back (0-indexed) a la entity del
  /// dominio (1-indexed). Si no viene `pagination`, asume página única.
  ProductsPage toEntity() {
    final items = products.map((p) => p.toEntity()).toList(growable: false);
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
