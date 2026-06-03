# SmartWarehouse Flutter — Architecture Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrar todos los repos remotos a Freezed DTOs + mappers y todas las pages/widgets a `StatelessWidget` con cubits dueños de los controllers, sin romper la app entre fases.

**Architecture:** Por feature end-to-end. Cada fase queda funcional al cerrar. DTOs viven en `data/dtos/`, mappers en `data/mappers/` (extension methods `dto.toEntity()`), entities del dominio quedan puros. Controllers (TextEditingController, PageController, ScrollController, etc.) viven en los cubits, instanciados en el constructor y dispuestos en `close()`.

**Tech Stack:** Flutter (Melos monorepo), `flutter_bloc`, `freezed`, `json_serializable`, `build_runner`, `dartz`, `dio`, `hive`. Backend: Spring Boot 4 con `JacksonConfig` snake_case.

**Spec:** `docs/superpowers/specs/2026-06-03-flutter-architecture-refactor-design.md`

---

## Pre-flight

- [ ] **Step 0: Verificar branch limpia**

```bash
cd /Users/juliansanchez/SmartWarehouse
git status
```
Expected: working tree clean en la branch actual.

Si hay cambios sin commitear que no son del refactor, parar y resolverlos antes.

---

## Fase 0 — Tooling

Habilita Freezed + JSON serialization en los 3 packages que no lo tienen (`catalog`, `orders`, `cart`) y deja un script `melos run generate` que regenera todo el repo.

### Task 0.1: Agregar deps a `catalog/pubspec.yaml`

**Files:**
- Modify: `packages/features/catalog/pubspec.yaml`

- [ ] **Step 1: Agregar deps**

Editar `packages/features/catalog/pubspec.yaml`. En la sección `dependencies:`, después de `google_fonts:`, agregar:

```yaml
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0
```

En `dev_dependencies:`, después de `flutter_lints:`, agregar:

```yaml
  build_runner: ^2.4.13
  freezed: ^3.2.3
  json_serializable: ^6.10.0
```

- [ ] **Step 2: Bootstrap melos**

```bash
cd /Users/juliansanchez/SmartWarehouse
melos bs
```
Expected: salida sin errores, `pub get` completo en `catalog` mostrando freezed/json_annotation resueltos.

- [ ] **Step 3: Verificar analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart analyze lib
```
Expected: `No issues found!`

### Task 0.2: Agregar deps a `orders/pubspec.yaml`

**Files:**
- Modify: `packages/features/orders/pubspec.yaml`

- [ ] **Step 1: Agregar deps**

Mismo cambio que Task 0.1 pero en `packages/features/orders/pubspec.yaml`. Si el archivo NO tiene `dev_dependencies`, crear la sección al final con el bloque correspondiente.

```yaml
# en dependencies:
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0
# en dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^3.2.3
  json_serializable: ^6.10.0
```

- [ ] **Step 2: Bootstrap + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse && melos bs
cd packages/features/orders && dart analyze lib
```
Expected: ambas salidas limpias.

### Task 0.3: Agregar deps a `cart/pubspec.yaml`

**Files:**
- Modify: `packages/features/cart/pubspec.yaml`

- [ ] **Step 1: Agregar deps**

Mismo cambio en `packages/features/cart/pubspec.yaml`.

- [ ] **Step 2: Bootstrap + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse && melos bs
cd packages/features/cart && dart analyze lib
```
Expected: ambas salidas limpias.

### Task 0.4: Confirmar melos `generate` script existe

**Files:**
- Modify: `melos.yaml` (sólo si falta)

- [ ] **Step 1: Verificar script existente**

```bash
grep -A4 "^  generate:" /Users/juliansanchez/SmartWarehouse/melos.yaml
```
Expected:
```yaml
  generate:
    exec: dart run build_runner build --delete-conflicting-outputs
    packageFilters:
      dependsOn: build_runner
```

Si ya está (es el caso actual), saltar al Step 2 sin tocar el archivo. Si no estuviese, agregarlo bajo `scripts:`.

- [ ] **Step 2: Smoke test de generate**

```bash
cd /Users/juliansanchez/SmartWarehouse
melos run generate
```
Expected: corre `build_runner` en todos los packages que dependen de build_runner (auth, catalog, orders, cart, core, login, token_repository, bottom_navigation_bar). Termina sin errores. Los `.freezed.dart` y `.g.dart` existentes quedan iguales (idempotente).

- [ ] **Step 3: Commit Fase 0**

```bash
cd /Users/juliansanchez/SmartWarehouse
git add packages/features/catalog/pubspec.yaml \
       packages/features/orders/pubspec.yaml \
       packages/features/cart/pubspec.yaml
git -c commit.gpgsign=false commit -m "chore(deps): add freezed/json_serializable/build_runner to catalog, orders, cart"
```

---

## Fase 1 — Catalog (canónica)

La feature más grande. Establece el patrón que copian las siguientes. Cuando termine: cero parsing handwritten en `RemoteCatalogRepository`, `CatalogPage` y `ProductDetailPage` son `StatelessWidget`, controllers viven en cubits.

### Task 1.1: Crear sub-DTOs sin dependencias internas

**Files:**
- Create: `packages/features/catalog/lib/src/data/dtos/product_image_dto.dart`
- Create: `packages/features/catalog/lib/src/data/dtos/spec_dto.dart`
- Create: `packages/features/catalog/lib/src/data/dtos/price_dto.dart`
- Create: `packages/features/catalog/lib/src/data/dtos/stock_dto.dart`
- Create: `packages/features/catalog/lib/src/data/dtos/order_constraints_dto.dart`
- Create: `packages/features/catalog/lib/src/data/dtos/product_location_dto.dart`
- Create: `packages/features/catalog/lib/src/data/dtos/pagination_dto.dart`

- [ ] **Step 1: `product_image_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image_dto.freezed.dart';
part 'product_image_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class ProductImageDto with _$ProductImageDto {
  const factory ProductImageDto({
    required String url,
    String? alt,
    @Default(false) bool isPrimary,
  }) = _ProductImageDto;

  factory ProductImageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductImageDtoFromJson(json);
}
```

- [ ] **Step 2: `spec_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'spec_dto.freezed.dart';
part 'spec_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class SpecDto with _$SpecDto {
  const factory SpecDto({
    required String label,
    required String value,
  }) = _SpecDto;

  factory SpecDto.fromJson(Map<String, dynamic> json) =>
      _$SpecDtoFromJson(json);
}
```

- [ ] **Step 3: `price_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_dto.freezed.dart';
part 'price_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class PriceDto with _$PriceDto {
  const factory PriceDto({
    @Default(0) int amountCents,
    @Default('ARS') String currency,
    bool? taxIncluded,
  }) = _PriceDto;

  factory PriceDto.fromJson(Map<String, dynamic> json) =>
      _$PriceDtoFromJson(json);
}
```

- [ ] **Step 4: `stock_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_dto.freezed.dart';
part 'stock_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class StockDto with _$StockDto {
  const factory StockDto({
    @Default(0) int available,
    int? reserved,
    int? min,
    int? lowStockThreshold,
  }) = _StockDto;

  factory StockDto.fromJson(Map<String, dynamic> json) =>
      _$StockDtoFromJson(json);
}
```

- [ ] **Step 5: `order_constraints_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_constraints_dto.freezed.dart';
part 'order_constraints_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class OrderConstraintsDto with _$OrderConstraintsDto {
  const factory OrderConstraintsDto({
    int? maxQuantityPerOrder,
  }) = _OrderConstraintsDto;

  factory OrderConstraintsDto.fromJson(Map<String, dynamic> json) =>
      _$OrderConstraintsDtoFromJson(json);
}
```

- [ ] **Step 6: `product_location_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_location_dto.freezed.dart';
part 'product_location_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class ProductLocationDto with _$ProductLocationDto {
  const factory ProductLocationDto({
    String? idZone,
    String? idLine,
    String? idPosition,
    String? height,
  }) = _ProductLocationDto;

  factory ProductLocationDto.fromJson(Map<String, dynamic> json) =>
      _$ProductLocationDtoFromJson(json);
}
```

- [ ] **Step 7: `pagination_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_dto.freezed.dart';
part 'pagination_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class PaginationDto with _$PaginationDto {
  const factory PaginationDto({
    @Default(0) int page,
    @Default(20) int size,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
  }) = _PaginationDto;

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);
}
```

- [ ] **Step 8: Generar código**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart run build_runner build --delete-conflicting-outputs
```
Expected: genera 14 archivos (7 `.freezed.dart` + 7 `.g.dart`). Sin errores.

- [ ] **Step 9: Analyze**

```bash
dart analyze lib
```
Expected: `No issues found!`

### Task 1.2: Crear DTO compuesto `ProductDto` y `ProductsPageDto`

**Files:**
- Create: `packages/features/catalog/lib/src/data/dtos/product_dto.dart`
- Create: `packages/features/catalog/lib/src/data/dtos/products_page_dto.dart`

- [ ] **Step 1: `product_dto.dart`**

```dart
import 'package:catalog/src/data/dtos/order_constraints_dto.dart';
import 'package:catalog/src/data/dtos/price_dto.dart';
import 'package:catalog/src/data/dtos/product_image_dto.dart';
import 'package:catalog/src/data/dtos/product_location_dto.dart';
import 'package:catalog/src/data/dtos/spec_dto.dart';
import 'package:catalog/src/data/dtos/stock_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
sealed class ProductDto with _$ProductDto {
  const factory ProductDto({
    required String id,
    required String sku,
    required String name,
    String? description,
    @Default('other') String category,
    String? imageUrl,
    @Default([]) List<ProductImageDto> images,
    PriceDto? price,
    @Default([]) List<SpecDto> specs,
    StockDto? stock,
    OrderConstraintsDto? orderConstraints,
    ProductLocationDto? location,
    String? createdAt,
  }) = _ProductDto;

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);
}
```

- [ ] **Step 2: `products_page_dto.dart`**

```dart
import 'package:catalog/src/data/dtos/pagination_dto.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'products_page_dto.freezed.dart';
part 'products_page_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
sealed class ProductsPageDto with _$ProductsPageDto {
  const factory ProductsPageDto({
    @Default([]) List<ProductDto> products,
    PaginationDto? pagination,
  }) = _ProductsPageDto;

  factory ProductsPageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductsPageDtoFromJson(json);
}
```

- [ ] **Step 3: Generar + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart run build_runner build --delete-conflicting-outputs
dart analyze lib
```
Expected: 4 archivos nuevos generados. `No issues found!`.

### Task 1.3: Crear mappers `data/mappers/`

**Files:**
- Create: `packages/features/catalog/lib/src/data/mappers/product_mapper.dart`
- Create: `packages/features/catalog/lib/src/data/mappers/products_page_mapper.dart`

- [ ] **Step 1: `product_mapper.dart`**

```dart
import 'package:catalog/src/data/dtos/order_constraints_dto.dart';
import 'package:catalog/src/data/dtos/price_dto.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:catalog/src/data/dtos/product_image_dto.dart';
import 'package:catalog/src/data/dtos/product_location_dto.dart';
import 'package:catalog/src/data/dtos/spec_dto.dart';
import 'package:catalog/src/data/dtos/stock_dto.dart';
import 'package:catalog/src/domain/entities/category.dart';
import 'package:catalog/src/domain/entities/money.dart';
import 'package:catalog/src/domain/entities/order_constraints.dart';
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/product_image.dart';
import 'package:catalog/src/domain/entities/product_location.dart';
import 'package:catalog/src/domain/entities/spec.dart';
import 'package:catalog/src/domain/entities/stock.dart';

extension ProductDtoMapper on ProductDto {
  Product toEntity() {
    final imgs = images.map((i) => i.toEntity()).toList(growable: false);
    return Product(
      id: id,
      sku: sku,
      name: name,
      description: description,
      category: _categoryFromSlug(category),
      price: price?.toEntity() ?? Money.zero('ARS'),
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
  ProductImage toEntity() => ProductImage(url: url, alt: alt, isPrimary: isPrimary);
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

Category _categoryFromSlug(String slug) {
  if (slug.isEmpty) return const Category(id: 'other', name: 'Otros');
  final name = slug[0].toUpperCase() + slug.substring(1).replaceAll('_', ' ');
  return Category(id: slug, name: name);
}

String? _pickThumbUrl(List<ProductImage> imgs, String? flat) {
  if (flat != null && flat.isNotEmpty) return flat;
  if (imgs.isEmpty) return null;
  final primary = imgs.firstWhere(
    (i) => i.isPrimary,
    orElse: () => imgs.first,
  );
  return primary.url.isEmpty ? null : primary.url;
}
```

- [ ] **Step 2: `products_page_mapper.dart`**

```dart
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
```

- [ ] **Step 3: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart analyze lib
```
Expected: `No issues found!`

### Task 1.4: Reescribir `RemoteCatalogRepository` usando DTOs + mappers

**Files:**
- Modify: `packages/features/catalog/lib/src/data/repositories/remote_catalog_repository.dart`

- [ ] **Step 1: Reescribir el archivo completo**

Borrar el contenido actual y reemplazarlo con:

```dart
import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:catalog/src/data/dtos/products_page_dto.dart';
import 'package:catalog/src/data/mappers/product_mapper.dart';
import 'package:catalog/src/data/mappers/products_page_mapper.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';

/// Talks to the SmartWarehouse REST API.
///
///   GET    /products?category=&search=&isActive=&page=&size=
///   GET    /products/{id}
///   GET    /categories      ← NO IMPLEMENTADO en el backend; devolvemos mock.
class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository({required this.httpHelper});

  final HttpHelper httpHelper;

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  }) async {
    try {
      final backendPage = (page - 1).clamp(0, 1 << 30);
      final query = <String, dynamic>{
        'page': backendPage,
        'size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      };
      final result = await httpHelper.get('/products', queryParameters: query);
      return result.fold(
        (error) => Left(CatalogFailure(error.message ?? 'Error obteniendo productos')),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          final dto = ProductsPageDto.fromJson(data);
          return Right(dto.toEntity());
        },
      );
    } catch (e, st) {
      log('getProducts error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }

  @override
  Future<Either<CatalogFailure, List<Category>>> getCategories() async {
    // El backend todavía no tiene `/categories`. Devolvemos una lista hardcoded
    // con los slugs que existen en los products seedeados, para que el filtro
    // de la UI funcione. Cuando el endpoint exista, reemplazar por HTTP real.
    return const Right(_mockCategories);
  }

  static const _mockCategories = [
    Category(id: 'seguridad', name: 'Seguridad'),
    Category(id: 'herramientas', name: 'Herramientas'),
    Category(id: 'almacenamiento', name: 'Almacenamiento'),
  ];

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async {
    try {
      final result = await httpHelper.get('/products/$id');
      return result.fold(
        (error) {
          if (error.statusCode == 404) {
            return const Left(CatalogFailure('Producto no encontrado'));
          }
          return Left(CatalogFailure(error.message ?? 'Error obteniendo producto'));
        },
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          final raw = data['product'];
          if (raw is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          final dto = ProductDto.fromJson(raw);
          return Right(dto.toEntity());
        },
      );
    } catch (e, st) {
      log('getProductById error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }
}
```

- [ ] **Step 2: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart analyze lib
```
Expected: `No issues found!`

### Task 1.5: Test de smoke para `product_mapper`

**Files:**
- Create: `packages/features/catalog/test/data/mappers/product_mapper_test.dart`

- [ ] **Step 1: Crear test con golden JSON**

```dart
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
        'category': 'seguridad',
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
      expect(product.category.id, 'seguridad');
      expect(product.category.name, 'Seguridad');
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
```

- [ ] **Step 2: Correr los tests**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
flutter test test/data/mappers/product_mapper_test.dart
```
Expected: 5 tests pasan.

### Task 1.6: Borrar test obsoleto del parser handwritten

**Files:**
- Delete: `packages/features/catalog/test/data/remote_catalog_repository_test.dart`

- [ ] **Step 1: Inspeccionar el test viejo**

```bash
head -30 /Users/juliansanchez/SmartWarehouse/packages/features/catalog/test/data/remote_catalog_repository_test.dart
```

Si el test valida sólo el parsing handwritten (que acabamos de eliminar), borrarlo. Si tiene casos que el mapper NO cubre (ej. retries, errores HTTP específicos), no borrar — adaptar.

- [ ] **Step 2: Decidir y ejecutar**

Si conviene borrarlo:
```bash
git rm packages/features/catalog/test/data/remote_catalog_repository_test.dart
```

Si conviene adaptarlo: dejar para más tarde, no bloquear la fase.

- [ ] **Step 3: Correr toda la suite del package**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
flutter test
```
Expected: todos los tests pasan.

### Task 1.7: Mover `TextEditingController` al `CatalogCubit`

**Files:**
- Modify: `packages/features/catalog/lib/src/presentation/bloc/catalog_cubit.dart`

- [ ] **Step 1: Agregar controller + dispose**

En `CatalogCubit`, después de `late final ScrollController scrollController;` (existente):

```dart
late final TextEditingController searchController;
```

En el constructor, después de la línea `scrollController = ScrollController()..addListener(_onScroll);`:

```dart
searchController = TextEditingController();
```

En `close()`, antes de `return super.close();`, agregar:

```dart
searchController.dispose();
```

- [ ] **Step 2: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart analyze lib
```
Expected: `No issues found!`

### Task 1.8: Convertir `CatalogPage` a `StatelessWidget`

**Files:**
- Modify: `packages/features/catalog/lib/src/presentation/pages/catalog_page.dart`

- [ ] **Step 1: Reescribir la clase top-level y borrar el State**

Reemplazar las clases `CatalogPage extends StatefulWidget` + `_CatalogPageState extends State<CatalogPage>` por una sola:

```dart
class CatalogPage extends StatelessWidget {
  const CatalogPage({required this.cubit, super.key});
  final CatalogCubit cubit;

  @override
  Widget build(BuildContext context) {
    // Kick-off del primer fetch si el cubit aún no cargó.
    if (cubit.state is! CatalogReady) {
      // Microtask para no llamar emit durante build.
      Future.microtask(cubit.load);
    }
    return Scaffold(
      backgroundColor: SwColors.white,
      bottomNavigationBar:
          BottomNavigationBarFeatureBuilder.build(context, const NavigationBarOption.products()),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CatalogCubit, CatalogState>(
          bloc: cubit,
          builder: (context, state) {
            return Column(
              children: [
                _CatalogAppBar(state: state),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: CatalogSearchBar(
                    controller: cubit.searchController,
                    onChanged: cubit.setQuery,
                    onSubmit: cubit.submitSearch,
                  ),
                ),
                if (cubit.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: CategoryFilterBar(
                      categories: cubit.categories,
                      selectedCategoryId: cubit.selectedCategoryId,
                      onSelected: cubit.selectCategory,
                    ),
                  ),
                Expanded(child: _Results(cubit: cubit, state: state, onProductTap: _onProductTap)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onProductTap(BuildContext context, String productId) {
    Injector.i.resolve<NavigationHelper>().pushNamed(
          context,
          routeName: Routes.catalogDetail(productId),
        );
  }
}
```

Las otras clases (`_CatalogAppBar`, `_Results`, `_EmptyView`, `_ErrorView`) quedan iguales — ya son `StatelessWidget`.

- [ ] **Step 2: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart analyze lib
```
Expected: `No issues found!`

### Task 1.9: Crear `ProductDetailCubit` + `ProductDetailState`

**Files:**
- Create: `packages/features/catalog/lib/src/presentation/bloc/product_detail_state.dart`
- Create: `packages/features/catalog/lib/src/presentation/bloc/product_detail_cubit.dart`

- [ ] **Step 1: `product_detail_state.dart`**

```dart
import 'package:catalog/src/domain/entities/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_detail_state.freezed.dart';

@freezed
sealed class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState.loading() = ProductDetailLoading;
  const factory ProductDetailState.ready(Product product) = ProductDetailReady;
  const factory ProductDetailState.error(String message) = ProductDetailError;
}
```

- [ ] **Step 2: `product_detail_cubit.dart`**

```dart
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/product_detail_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required CatalogRepository repository,
    required String productId,
  })  : _repository = repository,
        _productId = productId,
        super(const ProductDetailState.loading()) {
    pageController = PageController();
    load();
  }

  final CatalogRepository _repository;
  final String _productId;
  late final PageController pageController;
  int currentImageIndex = 0;

  Future<void> load() async {
    emit(const ProductDetailState.loading());
    final result = await _repository.getProductById(_productId);
    result.fold(
      (failure) =>
          emit(ProductDetailState.error(failure.message ?? 'Error cargando producto')),
      (product) => emit(ProductDetailState.ready(product)),
    );
  }

  void onPageChanged(int index) {
    currentImageIndex = index;
  }

  Future<void> jumpToImage(int index) async {
    currentImageIndex = index;
    if (pageController.hasClients) {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
```

- [ ] **Step 3: Generar + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart run build_runner build --delete-conflicting-outputs
dart analyze lib
```
Expected: 1 archivo nuevo (`product_detail_state.freezed.dart`). `No issues found!`.

### Task 1.10: Convertir `ProductDetailPage` a `StatelessWidget`

**Files:**
- Modify: `packages/features/catalog/lib/src/presentation/pages/product_detail_page.dart`
- Modify: `packages/features/catalog/lib/src/catalog_feature_builder.dart`

- [ ] **Step 1: Releer la implementación actual completa**

```bash
cat /Users/juliansanchez/SmartWarehouse/packages/features/catalog/lib/src/presentation/pages/product_detail_page.dart
```

Identificar:
- En `_DetailViewState`: el `PageController` y los handlers de `onPageChanged`/`jumpToImage`.
- En `_ProductDetailPageState`: el `initState` que llama `repository.getProductById`.

Estos dos pedazos se mueven al `ProductDetailCubit` (ya creado en Task 1.9).

- [ ] **Step 2: Reescribir `ProductDetailPage` como Stateless + leer del cubit**

Reemplazar el contenido del archivo (mantener el resto de los widgets internos como están) por:

```dart
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/presentation/bloc/product_detail_cubit.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    required this.cubit,
    required this.onAddToCart,
    super.key,
  });

  final ProductDetailCubit cubit;
  final void Function(Product product) onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      body: SafeArea(
        child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          bloc: cubit,
          builder: (context, state) {
            return switch (state) {
              ProductDetailLoading() =>
                const Center(child: CircularProgressIndicator()),
              ProductDetailError(:final message) =>
                _ErrorView(message: message, onRetry: cubit.load),
              ProductDetailReady(:final product) =>
                _DetailView(
                  product: product,
                  pageController: cubit.pageController,
                  onPageChanged: cubit.onPageChanged,
                  onThumbnailTap: cubit.jumpToImage,
                  onAddToCart: () => onAddToCart(product),
                ),
            };
          },
        ),
      ),
    );
  }
}
```

Y convertir `_DetailView` de `StatefulWidget` a `StatelessWidget`, recibiendo `pageController`, `onPageChanged`, `onThumbnailTap` como props (en vez de instanciarlos). Reemplazar todas las referencias a `_pageController` por `widget.pageController` y luego por el parámetro `pageController`.

> **IMPORTANTE para el ejecutor**: el archivo tiene 460 líneas. Cambiar SOLO las clases `ProductDetailPage`, `_ProductDetailPageState`, `_DetailView`, `_DetailViewState`. NO tocar `_ImageCarousel`, `_Thumbnail`, `_SpecRow`, `_ErrorView`, `_PriceFormatter`, etc. — esos son widgets `StatelessWidget` puros que reciben datos por constructor.

Pasos concretos:
1. Borrar `_ProductDetailPageState` por completo.
2. `ProductDetailPage` → `StatelessWidget` con el `build` del Step 2 ↑.
3. `_DetailView` → `StatelessWidget`, recibe `pageController`, `onPageChanged`, `onThumbnailTap` por constructor.
4. Borrar `_DetailViewState`.

- [ ] **Step 3: Actualizar `CatalogFeatureBuilder.buildProductDetailPage`**

Editar `packages/features/catalog/lib/src/catalog_feature_builder.dart`:

```dart
static Widget buildProductDetailPage(
  String productId, {
  required void Function(Product product) onAddToCart,
}) {
  return ProductDetailPage(
    cubit: ProductDetailCubit(
      repository: Injector.i.resolve<CatalogRepository>(),
      productId: productId,
    ),
    onAddToCart: onAddToCart,
  );
}
```

Imports nuevos: `import 'package:catalog/src/presentation/bloc/product_detail_cubit.dart';` y borrar el que ya no se usa de `catalog_repository.dart` si quedó huérfano.

- [ ] **Step 4: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
dart analyze lib
```
Expected: `No issues found!`

### Task 1.11: Smoke test manual de catalog

- [ ] **Step 1: Verificar que la app compila**

```bash
cd /Users/juliansanchez/SmartWarehouse
flutter pub get
flutter analyze
```
Expected: sin errores en ninguna de las raíces.

- [ ] **Step 2: Verificar suite de catalog completa**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/catalog
flutter test
```
Expected: todos los tests pasan.

- [ ] **Step 3: Smoke manual**

Levantar la app (Android emulator o iOS sim), loguearse con `admin@smartwarehouse.local` / `changeme`, y verificar:
- Lista de productos se carga con paginación.
- Tap a un chip de categoría filtra.
- Search por texto funciona.
- Tap a un producto abre el detail con carousel funcionando y thumbnails clickeables.

### Task 1.12: Commit Fase 1

- [ ] **Step 1: Commit**

```bash
cd /Users/juliansanchez/SmartWarehouse
git add packages/features/catalog/
git -c commit.gpgsign=false commit -m "refactor(catalog): Freezed DTOs + mappers and stateless pages with cubit-owned controllers

- Add data/dtos/ (ProductDto, ProductsPageDto, PriceDto, StockDto, etc.)
  with @JsonSerializable(fieldRename: FieldRename.snake) global and
  factory fromJson generated by build_runner.
- Add data/mappers/ with extension dto.toEntity() methods that absorb all
  derivations (image thumb pick, category slug to entity, 0-indexed →
  1-indexed pagination translation).
- RemoteCatalogRepository now does HTTP → fromJson → toEntity. Zero
  handwritten parsing remains.
- CatalogCubit owns the TextEditingController for search (dispose in close).
- CatalogPage and ProductDetailPage are StatelessWidget; new
  ProductDetailCubit owns the PageController for the image carousel and
  drives the load lifecycle.
- New product_mapper_test with golden JSON from the backend."
```

---

## Fase 2 — Orders

Aplica el mismo patrón. La response de `POST /orders` tiene shape `{order: {...}}` con timestamps anidados.

### Task 2.1: Crear DTOs en `orders`

**Files:**
- Create: `packages/features/orders/lib/src/data/dtos/order_dto.dart`
- Create: `packages/features/orders/lib/src/data/dtos/order_item_dto.dart`
- Create: `packages/features/orders/lib/src/data/dtos/order_timestamps_dto.dart`
- Create: `packages/features/orders/lib/src/data/dtos/order_response_dto.dart`
- Create: `packages/features/orders/lib/src/data/dtos/create_order_request_dto.dart`

- [ ] **Step 1: `order_item_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_dto.freezed.dart';
part 'order_item_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class OrderItemDto with _$OrderItemDto {
  const factory OrderItemDto({
    required String productId,
    String? sku,
    String? name,
    @Default(0) int quantity,
  }) = _OrderItemDto;

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);
}
```

- [ ] **Step 2: `order_timestamps_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_timestamps_dto.freezed.dart';
part 'order_timestamps_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class OrderTimestampsDto with _$OrderTimestampsDto {
  const factory OrderTimestampsDto({
    String? createdAt,
    String? startedAt,
    String? completedAt,
  }) = _OrderTimestampsDto;

  factory OrderTimestampsDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTimestampsDtoFromJson(json);
}
```

- [ ] **Step 3: `order_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:orders/src/data/dtos/order_item_dto.dart';
import 'package:orders/src/data/dtos/order_timestamps_dto.dart';

part 'order_dto.freezed.dart';
part 'order_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
sealed class OrderDto with _$OrderDto {
  const factory OrderDto({
    required String id,
    required String status,
    String? requestedByUserId,
    @Default([]) List<OrderItemDto> items,
    String? destinationArea,
    String? assignedVehicleId,
    OrderTimestampsDto? timestamps,
    String? cancelReason,
  }) = _OrderDto;

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);
}
```

- [ ] **Step 4: `order_response_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:orders/src/data/dtos/order_dto.dart';

part 'order_response_dto.freezed.dart';
part 'order_response_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
sealed class OrderResponseDto with _$OrderResponseDto {
  const factory OrderResponseDto({
    required OrderDto order,
  }) = _OrderResponseDto;

  factory OrderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseDtoFromJson(json);
}
```

- [ ] **Step 5: `create_order_request_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_request_dto.freezed.dart';
part 'create_order_request_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
sealed class CreateOrderRequestDto with _$CreateOrderRequestDto {
  const factory CreateOrderRequestDto({
    required List<CreateOrderItemDto> items,
    required String destinationArea,
  }) = _CreateOrderRequestDto;

  factory CreateOrderRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestDtoFromJson(json);
}

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class CreateOrderItemDto with _$CreateOrderItemDto {
  const factory CreateOrderItemDto({
    required String productId,
    required int quantity,
  }) = _CreateOrderItemDto;

  factory CreateOrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderItemDtoFromJson(json);
}
```

- [ ] **Step 6: Generar + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/orders
dart run build_runner build --delete-conflicting-outputs
dart analyze lib
```
Expected: 10 archivos generados. `No issues found!`.

### Task 2.2: Crear mapper

**Files:**
- Create: `packages/features/orders/lib/src/data/mappers/order_mapper.dart`

- [ ] **Step 1: Escribir mapper**

```dart
import 'package:catalog/catalog.dart';
import 'package:orders/src/data/dtos/order_dto.dart';
import 'package:orders/src/data/dtos/order_item_dto.dart';
import 'package:orders/src/domain/entities/order.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/entities/order_status.dart';

extension OrderDtoMapper on OrderDto {
  /// El backend NO devuelve precios en el endpoint de orders; se reciben los
  /// `fallbackItems` desde la UI (los items que enviamos al crear la orden)
  /// para preservar nombre y precio en post-creación.
  Order toEntity({required List<OrderItem> fallbackItems}) {
    final currency = fallbackItems.isEmpty
        ? 'ARS'
        : fallbackItems.first.unitPrice.currency;
    var total = Money.zero(currency);
    for (final i in fallbackItems) {
      total = total + i.subtotal;
    }
    return Order(
      id: id,
      items: fallbackItems,
      status: _parseStatus(status),
      createdAt: _parseDate(timestamps?.createdAt) ?? DateTime.now(),
      total: total,
    );
  }
}

extension OrderItemDtoMapper on OrderItemDto {
  /// Sin price: el back no devuelve precio en items. Usar con `fallbackItems`
  /// que sí tienen unitPrice.
  OrderItem toEntity({required Money unitPrice, String? fallbackName}) =>
      OrderItem(
        productId: productId,
        productName: name ?? fallbackName ?? '',
        quantity: quantity,
        unitPrice: unitPrice,
      );
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

OrderStatus _parseStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'in_progress':
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'shipped':
      return OrderStatus.shipped;
    case 'completed':
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}
```

- [ ] **Step 2: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/orders
dart analyze lib
```
Expected: `No issues found!`

### Task 2.3: Reescribir `RemoteOrderRepository`

**Files:**
- Modify: `packages/features/orders/lib/src/data/repositories/remote_order_repository.dart`

- [ ] **Step 1: Reescribir completo**

```dart
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:orders/src/data/dtos/create_order_request_dto.dart';
import 'package:orders/src/data/dtos/order_response_dto.dart';
import 'package:orders/src/data/mappers/order_mapper.dart';
import 'package:orders/src/domain/entities/order.dart';
import 'package:orders/src/domain/entities/order_destination.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/repositories/order_repository.dart';

/// Talks to `POST /orders` and `POST /orders/{id}/cancel`.
///
/// Body shape (snake_case por JacksonConfig):
/// ```json
/// {
///   "items": [{ "product_id": "p1", "quantity": 2 }],
///   "destination_area": "Bay 14"
/// }
/// ```
class RemoteOrderRepository implements OrderRepository {
  RemoteOrderRepository({required this.httpHelper});

  final HttpHelper httpHelper;

  @override
  Future<Either<OrderFailure, Order>> create({
    required List<OrderItem> items,
    required OrderDestination destination,
  }) async {
    try {
      final body = CreateOrderRequestDto(
        items: items
            .map((i) =>
                CreateOrderItemDto(productId: i.productId, quantity: i.quantity))
            .toList(growable: false),
        destinationArea: destination.area,
      ).toJson();

      final result = await httpHelper.post('/orders', data: body);
      return result.fold(
        (error) => Left(OrderFailure(_mapError(error))),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(OrderFailure('Respuesta inválida'));
          }
          final dto = OrderResponseDto.fromJson(data);
          return Right(dto.order.toEntity(fallbackItems: items));
        },
      );
    } catch (e, st) {
      log('createOrder error', error: e, stackTrace: st);
      return const Left(OrderFailure('Error de red'));
    }
  }

  @override
  Future<Either<OrderFailure, Unit>> cancel({
    required String id,
    required String reason,
  }) async {
    try {
      final result = await httpHelper.post(
        '/orders/$id/cancel',
        data: {'reason': reason},
      );
      return result.fold(
        (error) => Left(OrderFailure(_mapError(error))),
        (_) => const Right(unit),
      );
    } catch (e, st) {
      log('cancelOrder error', error: e, stackTrace: st);
      return const Left(OrderFailure('Error de red'));
    }
  }

  String _mapError(HttpResponseError error) {
    if (error.statusCode == 401 || error.statusCode == 403) {
      return 'No tenés permisos para crear órdenes';
    }
    if (error.statusCode == 400) {
      return error.message ?? 'Datos inválidos en la orden';
    }
    return error.message ?? 'No se pudo crear la orden';
  }
}
```

- [ ] **Step 2: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/orders
dart analyze lib
```
Expected: `No issues found!`

### Task 2.4: Test del mapper de orders

**Files:**
- Create: `packages/features/orders/test/data/mappers/order_mapper_test.dart`

- [ ] **Step 1: Escribir test**

```dart
import 'package:catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/src/data/dtos/order_response_dto.dart';
import 'package:orders/src/data/mappers/order_mapper.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/entities/order_status.dart';

void main() {
  group('OrderDtoMapper.toEntity', () {
    test('parses created order response and uses fallbackItems for totals', () {
      final json = <String, dynamic>{
        'order': {
          'id': 'order-1',
          'status': 'PENDING',
          'items': [
            {'product_id': 'p1', 'sku': 'SKU-1', 'quantity': 2},
          ],
          'destination_area': 'Bay 14',
          'timestamps': {
            'created_at': '2026-06-03T21:14:14.900019429Z',
          },
        },
      };

      final fallback = [
        OrderItem(
          productId: 'p1',
          productName: 'Casco',
          quantity: 2,
          unitPrice: const Money(amount: 1250000, currency: 'ARS'),
        ),
      ];

      final dto = OrderResponseDto.fromJson(json);
      final entity = dto.order.toEntity(fallbackItems: fallback);

      expect(entity.id, 'order-1');
      expect(entity.status, OrderStatus.pending);
      expect(entity.items.length, 1);
      expect(entity.items.first.productName, 'Casco');
      expect(entity.total.amount, 2500000);
      expect(entity.createdAt.toIso8601String(), startsWith('2026-06-03'));
    });

    test('uses now() when timestamps.created_at is missing', () {
      final dto = OrderResponseDto.fromJson(<String, dynamic>{
        'order': {'id': 'x', 'status': 'PENDING', 'items': []},
      });
      final entity = dto.order.toEntity(fallbackItems: const []);
      expect(entity.createdAt, isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/orders
flutter test test/data/mappers/order_mapper_test.dart
```
Expected: 2 tests pasan.

### Task 2.5: Commit Fase 2

- [ ] **Step 1: Commit**

```bash
cd /Users/juliansanchez/SmartWarehouse
git add packages/features/orders/
git -c commit.gpgsign=false commit -m "refactor(orders): Freezed DTOs + mappers for order create/cancel flow

- OrderDto, OrderItemDto, OrderTimestampsDto, OrderResponseDto:
  parse the backend response. CreateOrderRequestDto + CreateOrderItemDto
  build the POST body. All with snake_case fieldRename.
- order_mapper.dart: extension dto.toEntity() with fallbackItems for
  client-side total calculation (the back doesn't include prices in the
  order response).
- RemoteOrderRepository now does HTTP → fromJson → toEntity, no manual
  parsing.
- order_mapper_test with golden JSON for created/missing-timestamp cases."
```

---

## Fase 3 — Cart (auditoría)

Cart no tiene JSON parsing. `CartPage` ya es `StatelessWidget`. Esta fase es una auditoría rápida para confirmar y dejar un commit que cierre el seguimiento.

### Task 3.1: Auditar widgets internos

- [ ] **Step 1: Listar todos los Stateful/Stateless**

```bash
grep -nE "class .*Widget|extends State<" /Users/juliansanchez/SmartWarehouse/packages/features/cart/lib/src/presentation/**/*.dart
```
Expected: ningún `extends StatefulWidget` ni `extends State<`. Si aparece, agregar una sub-task aquí para migrar.

- [ ] **Step 2: Listar controllers**

```bash
grep -nE "Controller\(\)|FocusNode\(\)|AnimationController" /Users/juliansanchez/SmartWarehouse/packages/features/cart/lib/src/presentation/**/*.dart
```
Expected: vacío. Si aparece, mover a `CartCubit`.

### Task 3.2: Commit Fase 3

- [ ] **Step 1: Commit vacío o con cambios menores**

Si no hay cambios:
```bash
cd /Users/juliansanchez/SmartWarehouse
git -c commit.gpgsign=false commit --allow-empty -m "chore(cart): audit pass — already stateless with no controllers, no changes needed"
```

Si hubo cambios chicos:
```bash
git add packages/features/cart/
git -c commit.gpgsign=false commit -m "refactor(cart): align with stateless-with-cubit-owned-controllers pattern"
```

---

## Fase 4 — Auth + Login

`LoginFormCubit` y `EmailFormCubit` ya tienen sus controllers adentro. Solo falta:
- DTOs para `LoginRequest` y `LoginResponse`.
- Reescribir `RemoteLoginRepository` usando DTOs.
- `PersistableAuthData` Freezed.
- `AuthData` con `fromJson` Freezed.
- `LoginPage` → `StatelessWidget` (hoy tiene `_obscurePassword` en setState — mover al `LoginCubit` o crear un `_PasswordVisibilityCubit` chico).

### Task 4.1: DTOs de login

**Files:**
- Create: `packages/features/login/lib/src/data/dtos/login_request_dto.dart`
- Create: `packages/features/login/lib/src/data/dtos/login_response_dto.dart`
- Create: `packages/features/login/lib/src/data/dtos/user_dto.dart`

- [ ] **Step 1: Agregar deps a login si faltan**

```bash
grep -E "json_annotation|json_serializable|build_runner" /Users/juliansanchez/SmartWarehouse/packages/features/login/pubspec.yaml
```

Si falta `json_annotation`/`json_serializable`/`build_runner`, agregarlos siguiendo el patrón de Task 0.1. Luego `melos bs`.

- [ ] **Step 2: `user_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    @Default('') String name,
    @Default('') String email,
    @Default('') String role,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
```

- [ ] **Step 3: `login_request_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_dto.freezed.dart';
part 'login_request_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String email,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}
```

- [ ] **Step 4: `login_response_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:login/src/data/dtos/user_dto.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
sealed class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String token,
    UserDto? user,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
```

- [ ] **Step 5: Generar + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/login
dart run build_runner build --delete-conflicting-outputs
dart analyze lib
```
Expected: 6 archivos generados. `No issues found!`.

### Task 4.2: Mapper de login

**Files:**
- Create: `packages/features/login/lib/src/data/mappers/login_mapper.dart`

- [ ] **Step 1: Mapper**

```dart
import 'package:login/src/data/dtos/login_response_dto.dart';
import 'package:login/src/data/dtos/user_dto.dart';
import 'package:login/src/domain/entities/auth_tokens.dart';
import 'package:login/src/domain/entities/user.dart';

extension LoginResponseDtoMapper on LoginResponseDto {
  AuthTokens toEntity() => AuthTokens(
        accessToken: token,
        user: user?.toEntity(),
      );
}

extension UserDtoMapper on UserDto {
  User toEntity() => User(id: id, name: name, email: email, role: role);
}
```

- [ ] **Step 2: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/login
dart analyze lib
```
Expected: `No issues found!`

### Task 4.3: Reescribir `RemoteLoginRepository`

**Files:**
- Modify: `packages/features/login/lib/src/data/repositories/remote_login_repository.dart`

- [ ] **Step 1: Reescribir**

Reemplazar el `_parseUser` handwritten + el armado a mano del `AuthTokens` con `LoginResponseDto.fromJson(data).toEntity()`:

```dart
import 'dart:async';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart';
import 'package:login/src/data/dtos/login_request_dto.dart';
import 'package:login/src/data/dtos/login_response_dto.dart';
import 'package:login/src/data/mappers/login_mapper.dart';
import 'package:login/src/domain/entities/auth_tokens.dart';
import 'package:login/src/domain/entities/login_credentials.dart';
import 'package:login/src/domain/entities/login_failure.dart';
import 'package:login/src/domain/repositories/login_repository.dart';

class RemoteLoginRepository implements LoginRepository {
  RemoteLoginRepository({required this.httpHelper});

  final HttpHelper httpHelper;
  Completer<void>? _loginCompleter;

  @override
  Future<Either<LoginFailure, AuthTokens>> login(LoginCredentials credentials) async {
    try {
      final body = LoginRequestDto(
        email: credentials.email.toLowerCase(),
        password: credentials.password,
      ).toJson();

      final result = await httpHelper.post(
        '/auth/login',
        data: body,
        retryOnTokenExpired: false,
      );
      return result.fold(
        (error) => Left(_mapError(error)),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) return const Left(UnknownLoginFailure());
          final dto = LoginResponseDto.fromJson(data);
          if (dto.token.isEmpty) return const Left(UnknownLoginFailure());
          return Right(dto.toEntity());
        },
      );
    } catch (e, st) {
      log('login error', error: e, stackTrace: st);
      return const Left(UnknownLoginFailure());
    }
  }

  LoginFailure _mapError(HttpResponseError error) {
    if (error.statusCode == 401) return const InvalidCredentialsFailure();
    final type = error.errorType?.toLowerCase() ?? '';
    if (type.contains('timeout')) return const TimeoutFailure();
    if (error.statusCode == 999) return const NetworkFailure();
    return UnknownLoginFailure(error.message ?? 'Ocurrió un error. Reintentá.');
  }

  @override
  Future<Option<LoginFailure>> authenticateEmail(String email) async {
    try {
      if (_loginCompleter != null) {
        return const Some(UnknownLoginFailure('Esperá a que termine el envío anterior.'));
      }
      _loginCompleter = Completer<void>();
      _loginCompleter?.future.whenComplete(() => _loginCompleter = null);
      final result = await httpHelper.post('/authenticate/email', data: {'email': email.toLowerCase()});
      await _completeAndWaitForCompleter();
      return result.fold(
        (failure) => Some(_mapError(failure)),
        (_) => const None(),
      );
    } catch (e) {
      log('$e');
      await _completeAndWaitForCompleter();
      return const Some(UnknownLoginFailure());
    }
  }

  Future<void> _completeAndWaitForCompleter() async {
    _loginCompleter?.complete();
    await _loginCompleter?.future;
  }
}
```

- [ ] **Step 2: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/login
dart analyze lib
```
Expected: `No issues found!`

### Task 4.4: `PersistableAuthData` Freezed

**Files:**
- Modify: `packages/features/auth/lib/src/data/models/persistable_auth_data.dart`

- [ ] **Step 1: Reescribir como Freezed**

```dart
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'persistable_auth_data.freezed.dart';
part 'persistable_auth_data.g.dart';

/// Modelo persistido en Hive (clave `smart-warehouse-auth-key`). El JSON guardado
/// usa las keys `token` y `refreshToken` (camelCase), distinto del wire format
/// del backend (que es snake_case). Se mantiene así por compat con datos ya
/// persistidos en devices.
@freezed
@JsonSerializable()
sealed class PersistableAuthData
    with _$PersistableAuthData
    implements PersistableObject {
  const PersistableAuthData._();

  const factory PersistableAuthData({
    @Default('') String token,
    String? refreshToken,
  }) = _PersistableAuthData;

  factory PersistableAuthData.fromAuthData(AuthData data) => PersistableAuthData(
        token: data.token,
        refreshToken: data.refreshToken,
      );

  factory PersistableAuthData.fromJson(Map<String, dynamic> json) =>
      _$PersistableAuthDataFromJson(json);

  AuthData get authData => AuthData(token: token, refreshToken: refreshToken);
}
```

- [ ] **Step 2: Actualizar uso en `LocalAuthRepository`**

Editar `packages/features/auth/lib/src/data/repositories/local_auth_repository.dart`. En `save(AuthData authData)`, reemplazar la línea actual `PersistableAuthData(authData: authData)` por:

```dart
PersistableAuthData.fromAuthData(authData)
```

- [ ] **Step 3: Generar + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/auth
dart run build_runner build --delete-conflicting-outputs
dart analyze lib
```
Expected: 2 archivos generados. `No issues found!`.

### Task 4.5: `AuthData` Freezed (opcional, ya tiene `fromJson` handwritten)

**Files:**
- Modify: `packages/features/auth/lib/src/domain/entities/auth_data.dart`

> **Nota arquitectónica**: el spec dice que las entities del dominio NO deberían tener `fromJson`. `AuthData` hoy tiene uno. Decisión: borrar el `fromJson` de `AuthData` y mantenerla como entity plana (sin Freezed, sin fromJson). Quien necesite parsear JSON, usa el DTO en `data/dtos/`.

- [ ] **Step 1: Reescribir**

```dart
class AuthData {
  const AuthData({required this.token, this.refreshToken});

  factory AuthData.empty() => const AuthData(token: '', refreshToken: '');

  final String token;
  final String? refreshToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthData &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => Object.hash(token, refreshToken);
}
```

- [ ] **Step 2: Cazar usos del `AuthData.fromJson` viejo**

```bash
grep -rn "AuthData.fromJson" /Users/juliansanchez/SmartWarehouse --include="*.dart"
```
Expected: vacío después de borrar (`AuthData.fromJson` no se usa en presentación; el JWT decoding usa `AuthCubit.decodeToken` que devuelve `Map`).

Si aparecen usos, actualizarlos al nuevo path (DTO + mapper). Si la suite estaba mockeando con `AuthData.fromJson`, adaptar el test al constructor directo.

- [ ] **Step 3: Analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/auth
dart analyze lib
```
Expected: `No issues found!`

### Task 4.6: Mover `_obscurePassword` de `LoginPage` al cubit

**Files:**
- Modify: `packages/features/login/lib/src/presentation/bloc/login_form/login_form_cubit.dart`
- Modify: `packages/features/login/lib/src/presentation/bloc/login_form/login_form_state.dart`
- Modify: `packages/features/login/lib/src/presentation/pages/login_page.dart`

- [ ] **Step 1: Agregar `obscurePassword` al state**

Editar `login_form_state.dart`. Agregar el campo `obscurePassword` a `LoginFormState` (mantener el resto igual). Si el state es Freezed:

```dart
const factory LoginFormState({
  @Default('') String email,
  @Default('') String password,
  String? emailError,
  String? passwordError,
  @Default(false) bool showErrors,
  @Default(true) bool obscurePassword,
}) = _LoginFormState;
```

Si el state es plain class con `copyWith`, agregar el field correspondiente.

- [ ] **Step 2: Toggle en `LoginFormCubit`**

Agregar al cubit:

```dart
void toggleObscurePassword() {
  emit(state.copyWith(obscurePassword: !state.obscurePassword));
}
```

- [ ] **Step 3: Convertir `LoginPage` a `StatelessWidget`**

- Reemplazar `class LoginPage extends StatefulWidget` + `_LoginPageState` por una única clase `StatelessWidget`.
- Borrar `_obscurePassword` local.
- En el `SwTextField` de password, usar `obscure: formState.obscurePassword`.
- En el `_PasswordVisibilityToggle`, usar `onToggle: widget.formCubit.toggleObscurePassword` (ahora `cubit.toggleObscurePassword`).
- `_onSubmit` y `_onLoginStateChanged` quedan como funciones top-level o estáticas dentro del widget que reciben `BuildContext` + cubits por parámetro.

Esqueleto:

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({
    required this.formCubit,
    required this.loginCubit,
    required this.onLoginSuccess,
    super.key,
  });

  final LoginFormCubit formCubit;
  final LoginCubit loginCubit;
  final void Function(BuildContext context, AuthTokens tokens) onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          bloc: loginCubit,
          listener: (context, state) {
            if (state is LoginSuccess) {
              onLoginSuccess(context, state.tokens);
              loginCubit.reset();
            }
          },
          builder: (context, loginState) {
            final isSubmitting = loginState is LoginSubmitting;
            final failureMessage =
                loginState is LoginFailureState ? loginState.failure.message : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              child: BlocBuilder<LoginFormCubit, LoginFormState>(
                bloc: formCubit,
                builder: (context, formState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // … (idéntico al build actual, pero usando
                      // formState.obscurePassword y formCubit.toggleObscurePassword)
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
```

> **El ejecutor debe**: copiar el body actual de `_LoginPageState.build()` adentro del nuevo `build`, reemplazar `widget.X` por la prop directa, reemplazar `_obscurePassword` por `formState.obscurePassword`, reemplazar `setState(() => _obscurePassword = !_obscurePassword)` por `formCubit.toggleObscurePassword()`. NO tocar `_InputLeadingIcon`, `_PasswordVisibilityToggle`, `_ErrorBanner` — quedan como están.

- [ ] **Step 4: Generar (si state es Freezed) + analyze**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/login
dart run build_runner build --delete-conflicting-outputs
dart analyze lib
```
Expected: `No issues found!`.

### Task 4.7: Test del mapper de login

**Files:**
- Create: `packages/features/login/test/data/mappers/login_mapper_test.dart`

- [ ] **Step 1: Test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:login/src/data/dtos/login_response_dto.dart';
import 'package:login/src/data/mappers/login_mapper.dart';

void main() {
  group('LoginResponseDtoMapper.toEntity', () {
    test('parses a real login response', () {
      final json = <String, dynamic>{
        'token': 'jwt-abc',
        'user': {
          'id': 'u1',
          'name': 'Admin',
          'email': 'admin@example.com',
          'role': 'SUPERADMIN',
        },
      };
      final tokens = LoginResponseDto.fromJson(json).toEntity();
      expect(tokens.accessToken, 'jwt-abc');
      expect(tokens.user?.email, 'admin@example.com');
      expect(tokens.user?.role, 'SUPERADMIN');
    });

    test('handles missing user', () {
      final tokens = LoginResponseDto.fromJson(<String, dynamic>{
        'token': 'jwt-only',
      }).toEntity();
      expect(tokens.accessToken, 'jwt-only');
      expect(tokens.user, isNull);
    });
  });
}
```

- [ ] **Step 2: Run**

```bash
cd /Users/juliansanchez/SmartWarehouse/packages/features/login
flutter test test/data/mappers/login_mapper_test.dart
```
Expected: 2 tests pasan.

### Task 4.8: Commit Fase 4

- [ ] **Step 1: Commit**

```bash
cd /Users/juliansanchez/SmartWarehouse
git add packages/features/login/ packages/features/auth/
git -c commit.gpgsign=false commit -m "refactor(auth+login): Freezed DTOs, stateless LoginPage, obscure-password in cubit

- New data/dtos/ in login: LoginRequestDto, LoginResponseDto, UserDto with
  fromJson/toJson generated. New data/mappers/login_mapper.dart with
  extension methods.
- RemoteLoginRepository uses DTO + mapper. Zero handwritten parsing.
- PersistableAuthData rewritten as Freezed with fromAuthData factory.
- AuthData.fromJson removed (entities are not allowed to do parsing).
- LoginPage migrated to StatelessWidget. The obscurePassword toggle
  moved from local setState to LoginFormCubit + state."
```

---

## Fase 5 — ARCHITECTURE.md

Documentar los dos patrones en el doc para que cualquiera que sume una feature siga la regla.

### Task 5.1: Actualizar `docs/ARCHITECTURE.md`

**Files:**
- Modify: `docs/ARCHITECTURE.md`

- [ ] **Step 1: Localizar secciones existentes**

```bash
grep -n "^##\|^###" /Users/juliansanchez/SmartWarehouse/docs/ARCHITECTURE.md | head -40
```

Identificar dónde hablan de "data layer", "repositories", "cubits", "presentation".

- [ ] **Step 2: Insertar nueva sección "DTO + Mapper pattern"**

Después de la sección de "Data layer" (o equivalente), insertar:

````markdown
### DTO + Mapper pattern

Todo repo remoto que parsee JSON usa **Freezed DTOs** + **extension mappers**. Cero parsing handwritten en los repos.

**Ubicación**:
- DTO: `packages/features/<feature>/lib/src/data/dtos/<name>_dto.dart`
- Mapper: `packages/features/<feature>/lib/src/data/mappers/<name>_mapper.dart`

**DTO**:
- Matchea el JSON del back, no la forma ideal de la entity.
- Sin lógica, solo campos.
- `@JsonSerializable(fieldRename: FieldRename.snake)` global. Solo `@JsonKey(name: '...')` puntual cuando un campo no sigue snake_case.
- Defaults para opcionales: `@Default(...)` o nullable. Fallbacks ante null van al mapper, no al DTO.

**Mapper**:
- Extension method sobre el DTO: `extension ProductDtoMapper on ProductDto { Product toEntity() {...} }`.
- Absorbe defaults, fallbacks y derivaciones (parse `DateTime`, calcular `imageUrl` desde `images[]`, mapear slug → `Category`, traducir 0-indexed → 1-indexed, etc.).
- Nunca toca el dominio (no instancia repositories, no llama use cases) — solo lee del DTO y construye la entity.

**Repo**:
- Pasos del repo: HTTP → `Dto.fromJson(...)` → `dto.toEntity()` → `Right(entity)`.

Ejemplo canónico: `packages/features/catalog/lib/src/data/dtos/product_dto.dart` + `packages/features/catalog/lib/src/data/mappers/product_mapper.dart`.

**Build**: cualquier cambio en un DTO requiere `dart run build_runner build --delete-conflicting-outputs` en el package (o `melos run generate` desde la raíz).
````

- [ ] **Step 3: Insertar nueva sección "Stateless widgets, cubit-owned controllers"**

Después de la sección de "Presentation layer" (o equivalente), insertar:

````markdown
### Stateless widgets, cubit-owned controllers

**Regla**: toda widget en `presentation/` (pages y widgets) extiende `StatelessWidget`.

Si una widget necesita un controller (`TextEditingController`, `PageController`, `ScrollController`, `FocusNode`, `AnimationController`, …), lo provee el cubit:

```dart
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogLoading()) {
    scrollController = ScrollController()..addListener(_onScroll);
    searchController = TextEditingController();
    load();
  }

  late final ScrollController scrollController;
  late final TextEditingController searchController;

  @override
  Future<void> close() {
    scrollController.dispose();
    searchController.dispose();
    return super.close();
  }
}
```

La page lee el controller del cubit:

```dart
class CatalogPage extends StatelessWidget {
  const CatalogPage({required this.cubit, super.key});
  final CatalogCubit cubit;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CatalogSearchBar(
      controller: cubit.searchController,
      onChanged: cubit.setQuery,
      onSubmit: cubit.submitSearch,
    ),
  );
}
```

Cero `initState`, cero `dispose`, cero `late final` controllers en la widget.

El **kick-off** del primer fetch se hace en el constructor del cubit (no en `initState`, que ya no existe). Como los cubits están registrados como `lazy singleton` en el IoC, su constructor corre una sola vez (la primera vez que alguien los resuelve) — equivalente a un `initState` que disparase solo una vez en la vida de la app.

**Excepción única**: widgets de terceros que retornan StatefulWidget en su builder pattern (ej. `Builder`, `AnimatedBuilder`). No los escribimos nosotros y no cuentan.
````

- [ ] **Step 4: Actualizar checklist "Cómo agregar una feature"**

Encontrar la sección existente sobre cómo agregar una feature. Reemplazar la checklist por:

````markdown
**Checklist** para agregar una feature nueva (`<feature>`):

1. Crear el package en `packages/features/<feature>/` con `pubspec.yaml` que incluya: `flutter_bloc`, `freezed_annotation`, `json_annotation`, `dartz`, `commons` (path), `core` (path); en `dev_dependencies` agregar `build_runner`, `freezed`, `json_serializable`.
2. Crear `domain/entities/` con entities Freezed (o plain) SIN `fromJson`.
3. Crear `domain/repositories/<feature>_repository.dart` con abstract class + `<Feature>Failure`.
4. Crear `data/dtos/` con un DTO por cada shape del back. Reglas: `@freezed` + `@JsonSerializable(fieldRename: FieldRename.snake)` global, defaults con `@Default(...)`, nullables explícitos.
5. Crear `data/mappers/` con extension methods `dto.toEntity()`. Defaults y derivaciones van acá, no en el DTO.
6. Crear `data/repositories/remote_<feature>_repository.dart` que implementa el contrato del dominio. Pasos: HTTP → fromJson → toEntity. Cero parsing handwritten.
7. Crear `presentation/bloc/<feature>_cubit.dart` + `<feature>_state.dart` (state Freezed sealed). El cubit es dueño de cualquier controller que la UI necesite. Disponer en `close()`.
8. Crear `presentation/pages/` y `presentation/widgets/` — **TODAS** extienden `StatelessWidget`. Leen controllers del cubit, kick-off de fetch en el constructor del cubit.
9. Crear `<feature>_feature_builder.dart` con `injectDependencies()` que registra repo + cubit en el IoC.
10. Registrar el feature en `IocManager.register(...)`.
11. Agregar tests en `test/data/mappers/<name>_mapper_test.dart` con golden JSON real del backend para garantizar que el shape no se mueve sin que nos enteremos.
12. Correr `melos run generate` para regenerar Freezed/JSON.
13. `dart analyze` clean en el package.
````

- [ ] **Step 5: Borrar referencias obsoletas**

Buscar y eliminar/actualizar:
- Referencias a "cubit dispara fetch en `initState`" (ya no es válido).
- Referencias a "parser handwritten en repo" (ya no es válido).
- Cualquier ejemplo de `StatefulWidget` en pages que ya no aplique.

```bash
grep -n "initState\|StatefulWidget" /Users/juliansanchez/SmartWarehouse/docs/ARCHITECTURE.md
```

Revisar caso por caso. Si la mención sirve como contraste ("antes se hacía así, ahora se hace así"), reformular. Si es una recomendación obsoleta, borrar.

- [ ] **Step 6: Verificar links internos**

```bash
grep -nE "\[.*\]\(" /Users/juliansanchez/SmartWarehouse/docs/ARCHITECTURE.md | head
```

Verificar que los links a archivos (`packages/features/...`) siguen apuntando a paths existentes.

### Task 5.2: Commit Fase 5

- [ ] **Step 1: Commit**

```bash
cd /Users/juliansanchez/SmartWarehouse
git add docs/ARCHITECTURE.md
git -c commit.gpgsign=false commit -m "docs(architecture): document DTO+Mapper pattern and stateless-with-cubit rule

Adds two canonical sections — 'DTO + Mapper pattern' and 'Stateless
widgets, cubit-owned controllers' — and rewrites the 'How to add a
feature' checklist to walk through the new structure step by step.
Removes obsolete mentions of initState fetch kick-off and handwritten
parsers in repos."
```

---

## Fase 6 — Verificación end-to-end

### Task 6.1: Suite completa + lints

- [ ] **Step 1: Analyze root**

```bash
cd /Users/juliansanchez/SmartWarehouse
flutter analyze
```
Expected: sin issues en lib/ y en todos los packages.

- [ ] **Step 2: Tests en todos los packages**

```bash
cd /Users/juliansanchez/SmartWarehouse
melos exec --concurrency=1 -- "flutter test"
```
Expected: todos los packages que tienen tests pasan. Si alguno falla, anotar y resolver en sub-task.

- [ ] **Step 3: Cazar StatefulWidget remanentes**

```bash
grep -rn "extends StatefulWidget" /Users/juliansanchez/SmartWarehouse/packages/features --include="*.dart" | grep -v ".freezed.dart"
```
Expected: vacío. Si aparece algo, decidir caso por caso (puede ser un widget de terceros wrapeado, o algo que se pasó por alto).

- [ ] **Step 4: Cazar parsers handwritten remanentes**

```bash
grep -rnE "as String\?\)|as num\?\)|as Map<String, dynamic>\?\)" /Users/juliansanchez/SmartWarehouse/packages/features --include="*.dart" | grep -v ".freezed.dart" | grep -v ".g.dart" | grep -v "test/"
```
Expected: idealmente vacío. Si aparecen, validar que sean usos legítimos (ej. en el HttpHelper).

### Task 6.2: Smoke test manual end-to-end

- [ ] **Step 1: Test del flujo completo**

Levantar la app y verificar manualmente:

1. **Login** con `admin@smartwarehouse.local` / `changeme`.
2. **Catálogo** muestra los 15 productos con paginación.
3. **Filtros**: tocar chip "Seguridad" filtra a 5 productos.
4. **Search**: escribir "casco" + tocar Buscar muestra solo el casco.
5. **Detail**: tocar un producto abre el detail. El carousel funciona (swipe + thumbnails clickeables).
6. **Carrito**: agregar a carrito, abrir carrito, ver el producto con imagen y total.
7. **Crear orden**: el usuario es SUPERADMIN → debe devolver 201.
8. **Logout** + matar app + reabrir → debe quedar en login.

Si todo el flujo funciona, la refactor está completa.

### Task 6.3: Commit final

- [ ] **Step 1: Commit (si hay correcciones de la verificación)**

```bash
git status -s
# Si hay cambios:
git add .
git -c commit.gpgsign=false commit -m "fix: address regressions found during end-to-end verification"
```

Si no hay cambios, terminar la fase sin commit extra.
