# SmartWarehouse Flutter — Refactor arquitectónico

**Fecha**: 2026-06-03
**Estado**: Diseño aprobado, listo para plan de implementación.

## Contexto

El proyecto SmartWarehouse es una app Flutter monorepo (Melos) que sigue Clean Architecture con `flutter_bloc` (Cubit + sealed states) y `freezed`. Hoy hay dos patrones que se quieren cambiar globalmente:

1. **Parsers handwritten en cada repo remoto** — `RemoteCatalogRepository`, `RemoteOrderRepository`, etc. tienen métodos privados (`_parseProduct`, `_parseMoney`, `_parseStock`, `_parseImages`, …) llenos de casts manuales (`as String?`, `as num?`, `?? 0`). El código es frágil ante cambios del backend y mezcla parseo + lógica de dominio.
2. **`StatefulWidget` en presentación** — varias páginas (`catalog_page.dart`, `product_detail_page.dart`, `login_page.dart`) son `StatefulWidget` porque tienen controllers (`TextEditingController`, `PageController`, etc.). Mezclan ciclo de vida UI con estado ephemeral que debería vivir en el cubit.

Se quiere alinear todo el código a un único patrón canónico y dejar las reglas escritas en `docs/ARCHITECTURE.md` para que cualquier feature nueva las siga.

## Decisiones de diseño

| Decisión | Elección | Por qué |
|---|---|---|
| Dónde vive la serialización | **DTOs separados en `data/dtos/`, Entities puros en `domain/`** | Mantiene el dominio limpio de infra. Si el back cambia el wire format, solo se tocan DTOs + mappers. |
| Cómo eliminar `StatefulWidget` | **Cubit dueño de TODOS los controllers** | Patrón ya existente en `CatalogCubit` (que tiene `scrollController`). Cero deps nuevas, consistencia con lo escrito. |
| Orden del refactor | **Por feature end-to-end** | Cada fase queda funcional. La primera feature establece el patrón canónico, las siguientes lo copian. |
| snake_case ↔ camelCase | **Global con `@JsonSerializable(fieldRename: FieldRename.snake)`** | Una línea por DTO en vez de `@JsonKey` por cada campo. Excepciones puntuales con `@JsonKey` cuando un campo no matchea la convención. |

## Arquitectura objetivo por feature

```
packages/features/<feature>/
  lib/src/
    data/
      dtos/                  ← NUEVO. @freezed + fromJson generado.
      mappers/               ← NUEVO. Extension methods dto.toEntity().
      repositories/          ← Solo HTTP + parse DTO + map a entity.
    domain/
      entities/              ← Entities Freezed (o plain) SIN fromJson.
      repositories/
    presentation/
      bloc/                  ← Cubit dueño de controllers.
      pages/                 ← 100% StatelessWidget.
      widgets/               ← 100% StatelessWidget.
```

## Patrón 1 — DTO + Mapper

### Reglas

1. Un DTO **matchea el JSON** del back, no la forma ideal de la entity.
2. Un DTO **no tiene lógica**, solo campos.
3. El DTO usa `@JsonSerializable(fieldRename: FieldRename.snake)` global. Solo `@JsonKey` puntual cuando un campo no sigue snake_case.
4. Defaults para campos opcionales se ponen como `@Default(...)` o el field se marca nullable en el DTO. Los fallbacks de "valor por defecto cuando viene null" se hacen en el mapper, no en el DTO.
5. Un Mapper es un **extension method** sobre el DTO, vive en `data/mappers/`.
6. El Mapper traduce shapes y absorbe derivaciones (parsear `DateTime`, calcular `imageUrl` desde `images[]`, mapear slug → `Category`, etc.).
7. El Mapper **nunca** toca el dominio (no toca `Product`, no toca casos de uso) — solo lee del DTO y construye la entity.

### Snippet canónico — DTO

```dart
// packages/features/catalog/lib/src/data/dtos/product_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
sealed class ProductDto with _$ProductDto {
  const factory ProductDto({
    required String id,
    required String sku,
    required String name,
    String? description,
    required String category,
    String? imageUrl,
    @Default([]) List<ProductImageDto> images,
    PriceDto? price,
    @Default([]) List<SpecDto> specs,
    StockDto? stock,
    OrderConstraintsDto? orderConstraints,
    String? createdAt,
  }) = _ProductDto;

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);
}
```

### Snippet canónico — Mapper

```dart
// packages/features/catalog/lib/src/data/mappers/product_mapper.dart
extension ProductDtoMapper on ProductDto {
  Product toEntity() => Product(
    id: id,
    sku: sku,
    name: name,
    description: description,
    category: _categoryFromSlug(category),
    imageUrl: _pickThumb(images, imageUrl),
    images: images.map((i) => i.toEntity()).toList(),
    price: price?.toEntity() ?? Money.zero('ARS'),
    specs: specs.map((s) => s.toEntity()).toList(),
    stock: stock?.toEntity() ?? Stock.empty,
    orderConstraints: orderConstraints?.toEntity() ?? OrderConstraints.defaults,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
  );
}

Category _categoryFromSlug(String slug) { /* … */ }
String? _pickThumb(List<ProductImageDto> imgs, String? flat) { /* … */ }
```

### Snippet canónico — Repository

```dart
@override
Future<Either<CatalogFailure, ProductsPage>> getProducts(...) async {
  final result = await httpHelper.get('/products', queryParameters: query);
  return result.fold(
    (error) => Left(CatalogFailure(error.message ?? 'Error obteniendo productos')),
    (response) {
      final dto = ProductsPageDto.fromJson(response.data as Map<String, dynamic>);
      return Right(dto.toEntity());
    },
  );
}
```

**Resultado**: cero `as String?`, cero `?? 0`, cero parseo manual en el repo.

## Patrón 2 — StatelessWidget + Cubit dueño de controllers

### Reglas

1. Toda widget en `presentation/` (pages y widgets) extiende `StatelessWidget`.
2. Si una widget necesita un controller (`TextEditingController`, `PageController`, `ScrollController`, `FocusNode`, `AnimationController`, etc.), lo provee el cubit.
3. El cubit instancia el controller en su constructor con `late final controller`, lo expone como property, y lo dispone en `close()`.
4. Excepción única: widgets de terceros que retornan StatefulWidget en su builder pattern (ej. `Builder`, `AnimatedBuilder`). Eso no cuenta porque no lo escribimos nosotros.
5. El kick-off del primer fetch se hace en el constructor del cubit, no en `initState` (que ya no existe). Como los cubits están registrados como `lazy singleton` en el IoC, su constructor corre una sola vez (la primera vez que alguien los resuelve) — equivalente a un `initState` que disparase solo una vez en la vida de la app.

### Snippet canónico — Cubit con controllers

```dart
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogLoading()) {
    scrollController = ScrollController()..addListener(_onScroll);
    searchController = TextEditingController();
    load();
  }

  final CatalogRepository _repository;
  late final ScrollController scrollController;
  late final TextEditingController searchController;

  Future<void> load() async { /* … */ }

  @override
  Future<void> close() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    return super.close();
  }
}
```

### Snippet canónico — Page como StatelessWidget

```dart
class CatalogPage extends StatelessWidget {
  const CatalogPage({required this.cubit, super.key});
  final CatalogCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CatalogCubit, CatalogState>(
        bloc: cubit,
        builder: (context, state) => Column(
          children: [
            _CatalogAppBar(state: state),
            CatalogSearchBar(
              controller: cubit.searchController,  // ← del cubit
              onChanged: cubit.setQuery,
              onSubmit: cubit.submitSearch,
            ),
            Expanded(child: _Results(/* … */)),
          ],
        ),
      ),
    );
  }
}
```

**Sin `initState`, sin `dispose`, sin `late final` controllers en la page.**

## Mapeo de controllers actuales

| Page | Controllers hoy | Destino |
|---|---|---|
| `catalog_page.dart` | `TextEditingController` (search) | `CatalogCubit.searchController` |
| `product_detail_page.dart` | `PageController` (carousel) | nuevo `ProductDetailCubit.pageController` |
| `cart_page.dart` | (ninguno — ya es `StatelessWidget` sin controllers) | n/a |
| `login_page.dart` | email + password controllers | `LoginCubit.emailController`, `LoginCubit.passwordController` |

`ProductDetailPage` hoy no tiene cubit propio (recibe el repository directo). Se crea `ProductDetailCubit(repository, productId)` con estado `{loading, ready(product), error}`.

## Fases

### Fase 0 — Tooling

- Agregar a `pubspec.yaml` de `catalog`, `orders`, `cart`:
  - `dev_dependencies`: `build_runner ^2.x`, `json_serializable ^6.x`, `freezed ^3.x`
  - `dependencies`: `json_annotation ^4.x`, `freezed_annotation ^3.x`
- `core` y `auth` ya tienen las deps necesarias.
- Agregar script `gen` a `melos.yaml` que corre `dart run build_runner build --delete-conflicting-outputs` en todos los packages.
- Smoke test: correr `melos run gen` y verificar que regenera los archivos `.freezed.dart`/`.g.dart` existentes sin errores.

### Fase 1 — Catalog (feature canónica)

Estructura nueva en `data/`:

- `dtos/`:
  - `product_dto.dart` (con `PriceDto`, `StockDto`, `OrderConstraintsDto`, `ProductImageDto`, `SpecDto`)
  - `products_page_dto.dart`
  - `pagination_dto.dart`
- `mappers/`:
  - `product_mapper.dart`
  - `products_page_mapper.dart` (traduce 0-indexed back → 1-indexed cliente)

Cambios en `RemoteCatalogRepository`:
- Borrar `_parseProduct`, `_parseMoney`, `_parseStock`, `_parseImages`, `_parseSpecs`, `_parseDate`, `_parseCategory`, `_pickThumbUrl`, `_parseOrderConstraints`.
- `getCategories()` queda igual (sigue mockeada).

Cambios en `CatalogCubit`:
- Mover `TextEditingController` del widget al cubit.
- Disparar `load()` en constructor (ya hay precedente con `AuthCubit..load()` en featureBuilder).
- Disponer controllers en `close()`.

Cambios en `CatalogPage` y `ProductDetailPage`:
- Pasar de `StatefulWidget` → `StatelessWidget`.
- Borrar `initState`/`dispose`.
- Crear `ProductDetailCubit` con `PageController` y estado `{loading, ready, error}`.

Tests:
- Verificar `catalog_cubit_test.dart` sigue verde.
- Agregar `product_mapper_test.dart` con golden JSON real del backend.
- Borrar tests obsoletos del parser handwritten.

### Fase 2 — Orders

Mismo patrón:
- `OrderDto`, `OrderItemDto`, `TimestampsDto`, `OrderResponseDto` en `data/dtos/`.
- `CreateOrderRequestDto` para el POST body (Freezed con `toJson` también).
- `order_mapper.dart` con extension `toEntity`.
- `RemoteOrderRepository` se reduce a HTTP + parse + map.

### Fase 3 — Cart

- Cart no tiene JSON parsing (`InMemoryCartRepository`). Sin DTOs.
- `CartPage` ya es `StatelessWidget` y el `CartCubit` no tiene controllers — la fase es prácticamente un no-op de refactor. Se mantiene en el plan para auditar contra el patrón (chequear que widgets internos como `CartItemTile`, `_Footer`, etc. también sean `StatelessWidget`) y para que el orden de fases quede explícito.

### Fase 4 — Auth + Login

- `LoginRequestDto`, `LoginResponseDto`, `UserDto` en `auth`.
- **`PersistableAuthData`** se reescribe como Freezed con `toJson/fromJson` (hoy es handwritten).
- `LoginPage` → `StatelessWidget`.
- Email/password controllers → `LoginCubit`.

### Fase 5 — ARCHITECTURE.md

Agregar / actualizar secciones:

1. **"DTO + Mapper pattern"** — qué es un DTO, dónde vive, snippet canónico, regla "no lógica en DTO", cómo se escribe un mapper, qué va en el mapper (defaults, derivaciones, parseo).

2. **"Stateless widgets, cubit owns controllers"** — regla, snippets canónicos del cubit y de la page.

3. **"Cómo agregar una feature"** — checklist actualizada:
   1. Crear el package en `packages/features/<feature>/`.
   2. Crear `domain/entities/`, `domain/repositories/`.
   3. Crear `data/dtos/`, `data/mappers/`, `data/repositories/`.
   4. Crear `presentation/bloc/<feature>_cubit.dart`.
   5. Crear `presentation/pages/` y `presentation/widgets/` — TODO StatelessWidget.
   6. Crear `<feature>_feature_builder.dart` con `injectDependencies()`.
   7. Registrar en `IocManager`.

4. Borrar referencias a "cubit dispara fetch en `initState`" y a "parser handwritten en repo".

## Riesgos y mitigación

| Riesgo | Mitigación |
|---|---|
| Tests existentes que mockean entities con shape vieja podrían romper. | Mantener la shape pública de las entities. Solo cambia el parser. |
| Cubits singleton con controllers no se disponen nunca en hot restart (dev). | Aceptable en dev. En producción el proceso muere y libera todo. |
| Cambios atómicos por fase requieren regenerar Freezed cada vez. | Script `melos run gen` lo automatiza. Documentar en CONTRIBUTING. |
| `flutter_native_splash` interacción con cubits que ya cargan en constructor. | El splash es independiente del cubit (timer en `application.dart`). Sin impacto. |
| Si el back devuelve un campo nuevo, `json_serializable` lo ignora silenciosamente. Si renombra uno, falla en runtime. | Tests de mapper con golden JSON capturan la regresión. |

## Fuera de alcance

- No tocar `bottom_navigation_bar`, `design_system`, `commons`, `core`, `token_repository` salvo lo mínimo necesario.
- No agregar tests nuevos para widgets (solo para mappers y cubits).
- No introducir `flutter_hooks`.
- No migrar `MockCatalogRepository` ni `AppDataSource`.
- No refactor del backend.

## Criterios de aceptación

- [ ] Todos los repos remotos usan `Dto.fromJson(...)` + `dto.toEntity()`. Cero parsers handwritten.
- [ ] Todas las pages y widgets en `presentation/` son `StatelessWidget`.
- [ ] Todos los controllers (UI) viven en cubits, con `dispose` en `close()`.
- [ ] `melos run gen` regenera todo sin errores.
- [ ] `dart analyze` clean en todos los packages.
- [ ] Tests existentes siguen verdes. Nuevos tests de mapper agregados.
- [ ] `docs/ARCHITECTURE.md` refleja los dos patrones nuevos y la checklist de "cómo agregar una feature" actualizada.
- [ ] La app funciona end-to-end: login + catalog + paginación + filtros + carrito + crear orden.
