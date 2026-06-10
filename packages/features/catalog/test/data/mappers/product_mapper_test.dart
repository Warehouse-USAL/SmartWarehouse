import 'package:catalog/catalog.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:catalog/src/data/dtos/products_page_dto.dart';
import 'package:catalog/src/data/mappers/product_mapper.dart';
import 'package:catalog/src/data/mappers/products_page_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductDtoMapper.toEntity', () {
    test('parses a full product response from the backend', () {
      final json = <String, dynamic>{
        'id': '6a20992630a2fa66d223d5d4',
        'sku': 'SEG-001',
        'name': 'Casco de seguridad',
        'description': 'Casco industrial.',
        'category': 'TECNOLOGIA',
        'images': [
          {'url': 'https://example.com/a.jpg', 'alt': 'Casco', 'is_primary': true},
        ],
        'price': {'amount_cents': 1250000, 'currency': 'ARS', 'tax_included': true},
        'specs': [
          {'label': 'Material', 'value': 'HDPE'},
        ],
        'stock': {'available': 150, 'reserved': 0, 'min': 5},
        'order_constraints': {'max_quantity_per_order': 10},
        'created_at': '2026-06-03T21:14:14.900019429Z',
      };

      final product = ProductDto.fromJson(json).toEntity();

      expect(product.id, '6a20992630a2fa66d223d5d4');
      expect(product.sku, 'SEG-001');
      expect(product.name, 'Casco de seguridad');
      expect(product.category, ProductCategory.tecnologia);
      expect(product.category.key, 'TECNOLOGIA');
      expect(product.category.label, 'Tecnología');
      expect(product.price.amount, 1250000);
      expect(product.price.currency, 'ARS');
      expect(product.price.taxIncluded, true);
      expect(product.stock.available, 150);
      expect(product.stock.min, 5);
      expect(product.orderConstraints.maxQuantityPerOrder, 10);
      expect(product.images?.length, 1);
      expect(product.imageUrl, 'https://example.com/a.jpg');
      expect(product.specs?.length, 1);
      expect(product.createdAt, isNotNull);
    });

    test('falls back to defaults when fields are missing', () {
      final dto = ProductDto.fromJson(<String, dynamic>{
        'id': 'x',
        'sku': 'X',
        'name': 'X',
      });
      final product = dto.toEntity();
      expect(product.price, Money.zero('ARS'));
      expect(product.stock, Stock.empty);
      expect(product.orderConstraints.maxQuantityPerOrder,
          OrderConstraints.defaults.maxQuantityPerOrder);
      expect(product.imageUrl, isNull);
      expect(product.images, isNull);
      expect(product.specs, isNull);
    });

    test('picks primary image when `image_url` is absent', () {
      final dto = ProductDto.fromJson(<String, dynamic>{
        'id': 'x',
        'sku': 'X',
        'name': 'X',
        'images': [
          {'url': 'https://a.jpg', 'is_primary': false},
          {'url': 'https://primary.jpg', 'is_primary': true},
        ],
      });
      expect(dto.toEntity().imageUrl, 'https://primary.jpg');
    });
  });

  group('ProductsPageDtoMapper.toEntity', () {
    test('translates 0-indexed backend page to 1-indexed client page', () {
      final dto = ProductsPageDto.fromJson(<String, dynamic>{
        'products': [],
        'pagination': {
          'page': 0,
          'size': 5,
          'total_elements': 15,
          'total_pages': 3,
        },
      });
      final entity = dto.toEntity();
      expect(entity.page, 1);
      expect(entity.pageSize, 5);
      expect(entity.total, 15);
      expect(entity.hasNext, isTrue);
    });

    test('reports hasNext=false on last page', () {
      final dto = ProductsPageDto.fromJson(<String, dynamic>{
        'products': [],
        'pagination': {
          'page': 2,
          'size': 5,
          'total_elements': 15,
          'total_pages': 3,
        },
      });
      expect(dto.toEntity().hasNext, isFalse);
    });
  });
}
