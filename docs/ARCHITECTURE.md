# SmartWarehouse — Guía de arquitectura

Este documento describe **cómo está organizado el código**, **qué responsabilidad tiene cada capa** y **dónde poner cada cosa** cuando agregás una feature, una ruta o un endpoint nuevo.

La idea es que cualquiera del equipo abra este archivo y entienda en 10 minutos:

- qué archivo modificar para agregar X,
- por qué los cubits se ven como se ven,
- cuándo conviene Freezed (y cuándo no),
- cómo se enchufa una nueva ruta en Beamer.

> Si encontrás algo que en la práctica se hace distinto a lo que dice este doc, **arreglá el código** para que coincida — el doc es la verdad. Si la verdad cambió por una decisión de equipo, **actualizá este doc** en el mismo PR.

## Índice

0. [Setup y comandos básicos](#0-setup-y-comandos-básicos)
1. [Estructura del monorepo](#1-estructura-del-monorepo)
2. [Capas dentro de una feature](#2-capas-dentro-de-una-feature) · [2.1 Detalle de carpetas](#21-detalle-de-cada-carpeta-clean-ish-architecture)
3. [Cubits + States](#3-cubits--states)
4. [Repositorios](#4-repositorios)
5. [Entities](#5-entities-domainentities)
6. [Feature Builders](#6-feature-builders--el-punto-de-entrada-de-cada-feature)
7. [Navegación (agregar ruta)](#7-navegación--agregar-una-ruta-nueva)
8. [Design System](#8-design-system)
9. [Checklist: nueva feature](#9-checklist-agregar-una-feature-completa-de-cero)
10. [Dependency Injection](#10-dependency-injection-injector)
11. [HttpHelper / red](#11-httphelper-y-manejo-de-red)
12. [Either / Failures](#12-either--failures-dartz)
13. [Auth, tokens y guards](#13-auth-tokens-y-guards)
14. [Persistencia local](#14-persistencia-local)
15. [Design tokens](#15-design-tokens)
16. [BlocBuilder / Listener / Consumer](#16-blocbuilder-bloclistener-blocconsumer)
17. [Naming](#17-convenciones-de-naming)
18. [Tests](#18-tests)
19. [Plans y specs](#19-plans-y-specs-antes-de-implementar)
20. [Commits y PRs](#20-convenciones-de-commits--prs)
21. [Assets y fuentes](#21-assets-y-fuentes)
22. [Inter-package dependencies](#22-inter-package-dependencies-pubspecyaml)
23. [Anti-patterns](#23-anti-patterns--qué-no-hacer)
24. [Resumen del flujo de datos](#24-resumen-del-flujo-de-datos-de-abajo-hacia-arriba)

---

## 0. Setup y comandos básicos

### Primera vez

```bash
# Activar la versión correcta de Flutter
fvm install   # usa la versión declarada en .fvmrc (3.38.0)
fvm use

# Bootstrap del monorepo (resuelve dependencias de todos los packages)
dart pub global activate melos
melos bootstrap
```

### Día a día

```bash
# Correr la app con mocks (default)
flutter run --dart-define=APP_DATA_SOURCE=mock

# Correr la app contra el backend real
flutter run --dart-define=APP_DATA_SOURCE=remote

# Análisis estático (correr dentro de cada package o desde la raíz)
dart analyze

# Tests de un package
cd packages/features/catalog && flutter test

# Regenerar archivos de Freezed / json_serializable (cuando tocás @freezed)
melos run generate    # corre build_runner build --delete-conflicting-outputs en los packages que dependen de build_runner

# Pub get en todos los packages
melos run get
```

Los scripts disponibles en `melos.yaml` son `pub_upgrade`, `get` y `generate`. `analyze` y `test` se corren manualmente por package (o agregar al `melos.yaml` si querés un alias global).

### Code generation (Freezed, json_serializable)

Cualquier archivo con `@freezed` o `@JsonSerializable` requiere correr el build runner para regenerar `*.freezed.dart` y `*.g.dart`. Si tocás esos archivos sin regenerar, la app no compila.

```bash
melos run generate
```

Los `.freezed.dart` y `.g.dart` **sí van al repo** (no se ignoran en `.gitignore`) — se commitean junto con el cambio.

---

## 1. Estructura del monorepo

```
SmartWarehouse/
├── lib/                              ← App shell (main, DI, navegación Beamer)
│   ├── main.dart
│   ├── application/
│   │   ├── application.dart
│   │   └── navigation/
│   │       ├── beamer_config_helper.dart   ← Define las rutas
│   │       └── guards/                     ← Guards de auth
│   └── config/
│       └── ioc_manager.dart                ← Registro de dependencias (DI)
│
└── packages/
    ├── commons/         ← Helpers cross-cutting (http, persistence, injector, permissions)
    ├── core/            ← Tipos compartidos: NavigationHelper, Routes, EnvironmentConfig, use cases globales
    ├── design_system/   ← Widgets y tokens reusables (SwButton, SwCard, SwColors, etc.)
    └── features/
        ├── auth/                ← Sesión persistida, refresh token, logout
        ├── bottom_navigation_bar/
        ├── cart/                ← Carrito (in-memory)
        ├── catalog/             ← Listado y detalle de productos
        ├── login/               ← Pantalla de iniciar sesión
        ├── orders/              ← Crear / cancelar pedidos
        └── repositories/
            └── token_repository/
```

**Regla general**: ninguna feature importa código de otra feature directamente. Si dos features comparten algo, ese algo sube a `core`, `commons` o `design_system`.

Excepción aceptada: `cart` depende de `catalog` (necesita el tipo `Product`) y de `orders` (necesita `OrderItem` / `OrderDestination`). Es coherente con el dominio del negocio. Si una feature nueva necesita algo de otra que no encaja en este patrón, repensar la frontera.

---

## 2. Capas dentro de una feature

Cada paquete bajo `features/` sigue **siempre** la misma estructura:

```
packages/features/<feature>/
├── lib/
│   ├── <feature>.dart                      ← Barrel: exporta lo público
│   └── src/
│       ├── <feature>_feature_builder.dart  ← DI + factories de páginas
│       ├── data/
│       │   ├── models/                     ← DTOs / serialización JSON (acá vive Freezed)
│       │   └── repositories/               ← Impls: mock + remote
│       ├── domain/
│       │   ├── entities/                   ← Datos puros del dominio, sin Flutter
│       │   └── repositories/               ← Interfaces (abstract class)
│       └── presentation/
│           ├── bloc/                       ← Cubits + States
│           ├── pages/                      ← Pantallas root de cada ruta
│           └── widgets/                    ← Subcomponentes específicos de la feature
└── pubspec.yaml
```

### Reglas de oro (¡leer!)

| Pregunta | Respuesta |
|----------|-----------|
| ¿Dónde va una decisión "si X entonces Y"? | **Cubit** |
| ¿Dónde va una llamada HTTP / acceso a disco? | **Repository (data layer)** |
| ¿Dónde se transforma JSON crudo en entidades? | **Repository remoto** (parser interno) o **model** con Freezed si la transformación es pesada |
| ¿Dónde va un cálculo derivado (`subtotal = qty * price`)? | **Entity** o **getter del State** — nunca en el widget |
| ¿Dónde se navega? | El **page/widget** dispara la navegación con `NavigationHelper`; el cubit NO conoce rutas |
| ¿Dónde va una constante de UI (color, padding)? | `design_system` (tokens). Si es one-off, inline en el widget |
| ¿Dónde se inyectan dependencias? | `FeatureBuilder.injectDependencies()` desde `IocManager` |

**Si un widget tiene un `if` con lógica de negocio, está mal.** Subilo al cubit.

**Si un cubit hace `Navigator.of(context)`, está mal.** Devolvé un state que la page lea con `BlocListener`.

---

## 2.1 Detalle de cada carpeta (Clean-ish Architecture)

Las carpetas no son decoración — cada una tiene una **responsabilidad única** y **reglas estrictas de qué puede importar**. La regla mental es: **las dependencias apuntan hacia adentro** (presentation depende de domain, data depende de domain, domain no depende de nadie).

```
┌──────────────────────────────────────────────────────────┐
│                    presentation/                         │
│                    (bloc / pages / widgets)              │
│                    ┌────────────┐                        │
│                    ▼            ▼                        │
│              ┌──────────┐  ┌──────────┐                  │
│              │  domain  │◄─│   data   │                  │
│              │ entities │  │  models  │                  │
│              │  repos   │  │  repos   │                  │
│              └──────────┘  └──────────┘                  │
└──────────────────────────────────────────────────────────┘
       ▲ domain no importa nada de data ni de presentation
```

### `domain/` — el "qué" del negocio

Tipos puros del dominio. **No depende de Flutter, ni de HTTP, ni de la persistencia.** Si mañana migramos de Beamer a GoRouter, o de Dio a http, esta carpeta no se toca.

#### `domain/entities/`
Estructuras de datos del negocio (`Product`, `Money`, `Stock`, `User`, `Order`, etc.). Pueden tener **lógica derivada**:

```dart
// domain/entities/product.dart
class Product {
  const Product({ required this.price, required this.stock, ... });
  final Money price;
  final Stock stock;

  /// Lógica del dominio: cuánto se puede pedir como máximo.
  int get maxOrderableQuantity {
    final byStock = stock.available;
    final byPolicy = orderConstraints.maxQuantityPerOrder;
    return byStock < byPolicy ? byStock : byPolicy;
  }
}
```

**Qué SÍ va acá**:
- Campos del shape de negocio.
- Getters derivados (`subtotal`, `isOutOfStock`, `maxOrderableQuantity`).
- `==`, `hashCode`, `copyWith` manual.
- Constructores `factory` para casos especiales (`Cart.empty()`, `Stock.empty`).

**Qué NO va acá**:
- ❌ `fromJson` / `toJson` — eso es serialización, va en `data/dtos/`.
- ❌ Llamadas a la red ni a `SharedPreferences`.
- ❌ Imports de `flutter/material.dart`, `dio`, `freezed_annotation` (a menos que esté justificado).
- ❌ Referencias a `BuildContext`.

#### `domain/repositories/`
**Interfaces** (abstract classes) que el dominio "necesita" para funcionar. Define el contrato; no la implementación.

```dart
// domain/repositories/catalog_repository.dart
abstract class CatalogRepository {
  Future<Either<CatalogFailure, ProductsPage>> getProducts({ ... });
  Future<Either<CatalogFailure, Product>> getProductById(String id);
}

class CatalogFailure {
  const CatalogFailure([this.message]);
  final String? message;
}
```

**Qué SÍ va acá**:
- `abstract class` con los métodos públicos.
- Tipos de `Failure` específicos del dominio (`CatalogFailure`, `OrderFailure`, `LoginFailure`).
- Sub-tipos sellados de `Failure` cuando el caller necesita diferenciar errores (`InvalidCredentialsFailure`, `NetworkFailure`, `TimeoutFailure`).

**Qué NO va acá**:
- ❌ Implementaciones concretas.
- ❌ Llamadas HTTP.
- ❌ Lógica.

### `data/` — el "cómo" lo obtenemos

Implementaciones concretas: cómo hablar con la red, con disco, con datos hardcoded. **Depende de `domain/`** pero `domain/` no depende de `data/`.

#### `data/repositories/`
Las implementaciones de las interfaces de `domain/repositories/`. Convención: **siempre dos** por interfaz.

```
data/repositories/
├── mock_catalog_repository.dart      ← datos in-memory
└── remote_catalog_repository.dart    ← HTTP contra el backend
```

**Patrón canónico**: un repo remoto reduce el HTTP a tres pasos — request, `Dto.fromJson(...)`, `dto.toEntity()`. Cero parseo manual.

```dart
@override
Future<Either<CatalogFailure, ProductsPage>> getProducts(...) async {
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
}
```

Cualquier default, fallback, o derivación va en el mapper (ver `data/mappers/`). Si encontrás un `as String?`, `as num?`, o un `?? 0` dentro de un repo, está mal ubicado — pertenece al DTO o al mapper.

**Qué SÍ va acá**:
- I/O: HTTP, persistencia, cache, mocks.
- Orquestación del flujo `request → DTO.fromJson → mapper.toEntity`.
- Manejo de errores HTTP → `Failure` del dominio.
- Validación mínima del shape de respuesta (ej. asegurar que `data` es un `Map`).

**Qué NO va acá**:
- ❌ Parsing de JSON a mano (`as String?`, `?? 0`, casts manuales) — eso va en el DTO o el mapper.
- ❌ Lógica de negocio (`if user.isAdmin then ...`) — eso va en cubit.
- ❌ Decisión de cuándo llamar al endpoint — eso lo decide el cubit.
- ❌ Estado UI (`isLoading`) — eso vive en el state del cubit.

#### `data/dtos/` — modelos de wire format

Cada DTO matchea **el JSON tal cual lo emite el backend**, no la forma ideal de la entity del dominio. Son Freezed (`@freezed`), sin lógica, sin defaults derivados — eso lo hace el mapper.

**Regla**: en `data/dtos/` solo viven Freezed classes con `factory fromJson`. Nada más.

Ejemplo (`packages/features/catalog/lib/src/data/dtos/product_dto.dart`):

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

@freezed
sealed class ProductDto with _$ProductDto {
  const factory ProductDto({
    required String id,
    required String sku,
    required String name,
    String? imageUrl,
    @Default([]) List<ProductImageDto> images,
    PriceDto? price,
    StockDto? stock,
    OrderConstraintsDto? orderConstraints,
    String? createdAt,
  }) = _ProductDto;

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);
}
```

**snake_case ↔ camelCase**: cada feature tiene un `build.yaml` que configura `json_serializable` para hacer la traducción automáticamente.

```yaml
# packages/features/<feature>/build.yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          field_rename: snake
          explicit_to_json: true
```

Con eso, un campo `String? imageUrl` mapea a la JSON key `"image_url"` sin que ningún `@JsonKey` haga falta. Si un campo del back NO sigue snake_case (raro), poné `@JsonKey(name: 'foo')` puntual.

**Importante**: NO uses `@JsonSerializable(fieldRename: ...)` en la clase Freezed — falla con campos `required` y duplica la generación. Siempre `build.yaml` a nivel package.

#### `data/mappers/` — DTO → Entity

Un mapper traduce un DTO a una entity del dominio. Vive como **extension method** sobre el DTO, en `data/mappers/`. Absorbe defaults, fallbacks, derivaciones, y cualquier conversión de tipo (ej. `String` → `DateTime`, slug → `Category`, computar `imageUrl` desde `images[]`).

**Regla**: el mapper nunca toca el dominio (no llama use cases ni repositories). Solo lee del DTO y construye la entity.

Ejemplo (`packages/features/catalog/lib/src/data/mappers/product_mapper.dart`):

```dart
extension ProductDtoMapper on ProductDto {
  Product toEntity() {
    final imgs = images.map((i) => i.toEntity()).toList();
    return Product(
      id: id,
      sku: sku,
      name: name,
      category: _categoryFromSlug(category),
      price: price?.toEntity() ?? Money.zero('ARS'),
      stock: stock?.toEntity() ?? Stock.empty,
      orderConstraints: orderConstraints?.toEntity() ?? OrderConstraints.defaults,
      imageUrl: _pickThumbUrl(imgs, imageUrl),
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
      images: imgs.isEmpty ? null : imgs,
    );
  }
}
```

Los helpers privados (`_pickThumbUrl`, `_categoryFromSlug`) viven junto al mapper.

**Por qué separamos DTOs y entities**: si el backend cambia un campo, solo se toca el DTO + mapper. El dominio (entities + repos abstractos + cubits + UI) queda intacto. Y al revés: si el dominio crece, no tenés que tocar nada del wire format.

### `presentation/` — el "cómo se muestra y se interactúa"

#### `presentation/bloc/`
Cubits + states. La **lógica de la pantalla** vive acá: orquestación, validaciones, decisiones, transformación de entities en algo que la UI pueda renderizar.

```
presentation/bloc/
├── catalog_cubit.dart
└── catalog_state.dart
```

Convenciones:
- Un cubit por feature/pantalla (no por widget).
- El state es `sealed class` (3–5 variantes) o `@freezed` (estados grandes).
- El cubit expone **métodos públicos** que la UI invoca (`load()`, `submitSearch(q)`, `selectCategory(id)`).
- El cubit NO conoce a `BuildContext`. Si necesita reaccionar a navegación, emite un state que la page intercepta con `BlocListener`.

#### `presentation/pages/`
Una página **por ruta del router**. Es el widget root que recibe el cubit por constructor y renderiza el state.

**Regla de oro**: TODA widget en `presentation/` (pages y widgets) extiende `StatelessWidget`. Sin excepciones nuestras. (Solo widgets de terceros con builders internos quedan afuera.)

Si una widget necesita un controller (`TextEditingController`, `PageController`, `ScrollController`, `FocusNode`, `AnimationController`, etc.), **el cubit es dueño del controller**:

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

Sin `initState`, sin `dispose`, sin `late final` controllers en la widget. El **kick-off** del primer fetch se hace en el constructor del cubit (no en `initState` que ya no existe). Como los cubits están registrados como `lazy singleton` en el IoC, su constructor corre una sola vez — equivalente a un `initState` que disparase solo una vez en la vida de la app.

**Estado ephemeral** (qty de un stepper, tab activo, índice de imagen del carousel, `obscurePassword` de un input de password, etc.) también vive en el cubit y se expone vía el state. Patrón:

```dart
@freezed
sealed class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState.ready({
    required Product product,
    @Default(1) int qty,
    @Default(0) int activeTab,
    @Default(0) int activeImage,
  }) = ProductDetailReady;
  // …
}
```

Con métodos `setQty`, `setActiveTab`, etc. que hacen `emit(state.copyWith(...))`.

**Regla**: si una page tiene más de ~300 líneas, sacar subcomponentes a `presentation/widgets/`.

#### `presentation/widgets/`
Subcomponentes específicos de la feature (no del design system). Ejemplos en catalog:

```
presentation/widgets/
├── catalog_search_bar.dart
├── product_card.dart
├── product_card_skeleton.dart
└── stock_badge.dart
```

**Cuándo un widget se queda acá vs sube al design_system**:
- Se queda si depende de un **tipo de la feature** (`ProductCard(product: ...)`).
- Sube al design_system si es **genérico y reusable** (`SwButton`, `SwCard`, `SwIconButton`).

---

## 3. Cubits + States

Los cubits **concentran toda la lógica** de la pantalla: orquestación, validaciones, decisiones, transformaciones, control de paginación, debounce de input, manejo de errores. La page **dispara** acciones y **renderiza** estado, nada más.

### Anatomía de un cubit (catalog como referencia)

```dart
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogLoading()) {
    scrollController = ScrollController()..addListener(_onScroll);
  }

  final CatalogRepository _repository;
  late final ScrollController scrollController;

  // ── Estado interno (no se emite, solo coordina) ─────────────
  int _requestSeq = 0;
  String _query = '';
  String? _categoryId;
  List<Category> _categoriesCache = const [];

  // ── Acciones públicas que la UI puede invocar ───────────────
  Future<void> load() async { /* ... */ }
  Future<void> loadMore() async { /* ... */ }
  Future<void> submitSearch(String q) async { /* ... */ }
  void setQuery(String q) => _query = q;
  void selectCategory(String? id) { _categoryId = id; load(); }

  // ── Helpers privados (decisión de cuándo cargar más) ────────
  void _onScroll() { /* ... */ }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
```

### Estados — patrón sealed class

Para estados con pocas variantes (3–5), usamos `sealed class` de Dart 3 + pattern matching. No requiere codegen y se ve nativo:

```dart
sealed class CatalogState {
  const CatalogState();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogError extends CatalogState {
  const CatalogError(this.message);
  final String message;
}

class CatalogReady extends CatalogState {
  const CatalogReady({
    required this.products,
    required this.categories,
    required this.query,
    required this.total,
    required this.hasNext,
    required this.isLoadingMore,
    required this.loadMoreError,
    // ...
  });
  // ...
  CatalogReady copyWith({ /* ... */ }) { /* ... */ }
}
```

En la UI:

```dart
return switch (state) {
  CatalogLoading() => const SwLoadingSpinner(),
  CatalogError(:final message) => ErrorView(message: message),
  CatalogReady() => ProductsGrid(state: state),
};
```

### Cuándo usar Freezed

Usamos **Freezed** cuando:

1. El state tiene **muchos campos** (más de ~6) y el `copyWith` manual se vuelve verboso.
2. Necesitamos **serialización JSON** (`fromJson` / `toJson`) — todos los DTOs viven en `data/dtos/` y usan Freezed + `json_serializable` (ver sección `data/dtos/` arriba).
3. Queremos `when` / `maybeWhen` exhaustivo automático (sin escribir el switch a mano).

Ejemplo con Freezed (`AuthState` ya existe):

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.empty() = EmptyAuthState;
  const factory AuthState.data(AuthData authData, {required bool hasUpdated}) = SuccessAuthState;
}
```

Y la UI:

```dart
state.whenOrNull(
  empty: () => /* ... */,
  data: (auth, hasUpdated) => /* ... */,
);
```

**Cuándo NO usar Freezed**:

- Para entidades de dominio simples (Product, Money, User) — un constructor const + `==`/`hashCode` manual sirve y no agrega un archivo `.freezed.dart` al control de versiones.
- Para estados con 2–3 variantes — `sealed class` es más liviano.

### Pendiente de refactor

> Los cubits actuales mezclan estilos (algunos sealed, algunos Freezed). En el próximo refactor unificamos:
> - Estados con **>5 campos** o que necesiten JSON → Freezed.
> - Estados simples (loading/error/ready) → sealed class.
> - Todas las entities de dominio → POD class manual (sin Freezed).

---

## 4. Repositorios

### Interfaz en `domain/repositories/`

Define solo el contrato. Nada de imports de paquetes externos.

```dart
// domain/repositories/catalog_repository.dart
abstract class CatalogRepository {
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  });

  Future<Either<CatalogFailure, List<Category>>> getCategories();
  Future<Either<CatalogFailure, Product>> getProductById(String id);
}
```

Usamos `Either<Failure, Success>` de `dartz` para errores recuperables (no usamos throw para errores de negocio). `Failure` es una clase del dominio con un `message` legible.

### Implementaciones en `data/repositories/`

Convención: siempre **dos** impls por repositorio.

- **`Mock<Feature>Repository`**: datos hardcoded en memoria. Sirve para demo, tests y para trabajar sin backend.
- **`Remote<Feature>Repository`**: pega contra la API real con `HttpHelper`.

```dart
class MockCatalogRepository implements CatalogRepository { /* ... */ }
class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository({required this.httpHelper});
  final HttpHelper httpHelper;
  // request → ProductsPageDto.fromJson(...) → dto.toEntity()
}
```

El **toggle mock ↔ remote** lo hace el `FeatureBuilder` leyendo `AppDataSource.isMock`:

```dart
Injector.i.registerLazySingleton<CatalogRepository>(
  () => Injector.i.resolve<AppDataSource>().isMock
      ? MockCatalogRepository()
      : RemoteCatalogRepository(httpHelper: Injector.i.resolve<HttpHelper>()),
);
```

Se activa al correr la app con `--dart-define=APP_DATA_SOURCE=mock`.

### Parsing de JSON

Se hace con **Freezed DTOs + `build_runner` + `json_serializable`** (ver `data/dtos/` arriba). Nunca a mano. Si encontrás un `as String?`, un cast manual, o un `if (json[...] is...)` en un repo, está mal — mové eso a un DTO o al mapper.

Para regenerar después de cambiar un DTO:

```bash
melos run generate
```

(O `dart run build_runner build --delete-conflicting-outputs` desde la raíz del package.)

### Tests de repos

Los mocks tienen tests de pagination/filter (`mock_catalog_repository_test.dart`). Los remote tests usan un fake de `HttpHelper` (`remote_catalog_repository_test.dart`). Cualquier cambio en parsing debe ir acompañado de un test que asegure el shape del contrato.

---

## 5. Entities (domain/entities/)

Tipos puros del negocio. **Sin dependencias** de Flutter, dartz, freezed (a menos que esté justificado).

```dart
// domain/entities/product.dart
class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.orderConstraints,
    // ...
  });

  final String id;
  final Money price;
  final Stock stock;
  // ...

  /// Lógica derivada va acá, no en el widget ni en el cubit.
  int get maxOrderableQuantity {
    final byStock = stock.available;
    final byPolicy = orderConstraints.maxQuantityPerOrder;
    return byStock < byPolicy ? byStock : byPolicy;
  }

  @override
  bool operator ==(Object other) => identical(this, other) ||
      other is Product && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

**Value objects** (Money, Stock, OrderConstraints, ProductImage, etc.) viven al mismo nivel — uno por archivo.

---

## 6. Feature Builders — el "punto de entrada" de cada feature

Cada feature expone un `FeatureBuilder` estático con dos responsabilidades:

### a) `injectDependencies()` — registro de DI

```dart
class CatalogFeatureBuilder {
  static void injectDependencies() {
    Injector.i
      ..registerLazySingleton<CatalogRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockCatalogRepository()
            : RemoteCatalogRepository(httpHelper: Injector.i.resolve<HttpHelper>()),
      )
      ..registerLazySingleton<CatalogCubit>(
        () => CatalogCubit(Injector.i.resolve<CatalogRepository>()),
      );
  }
  // ...
}
```

Se llama una sola vez en `IocManager.register()`.

### b) Factories de UI — `build<Page>()`

Resuelven dependencias y arman el widget root para que el router solo tenga que invocar un método:

```dart
static Widget buildCatalogPage() {
  return CatalogPage(cubit: Injector.i.resolve<CatalogCubit>());
}

static Widget buildProductDetailPage(
  String productId, {
  required void Function(Product product) onAddToCart,
}) {
  return ProductDetailPage(
    productId: productId,
    repository: Injector.i.resolve<CatalogRepository>(),
    onAddToCart: onAddToCart,
  );
}
```

### Qué SÍ va en un FeatureBuilder

- Registro de repos, cubits y otros services en el Injector.
- Factories que devuelven `Widget` para cada page de la feature.
- Acciones imperativas exposed (ej. `CartFeatureBuilder.addToCart(product)` para que detail page pueda agregar sin importar el cart cubit directamente).
- Wrappers de auth/login (ej. `AuthFeatureBuilder.login(...)` que coordina guardar tokens + emitir state).

### Qué NO va en un FeatureBuilder

- Lógica de UI (eso vive en widgets).
- Lógica de negocio o decisiones (eso vive en cubits).
- Llamadas HTTP directas (eso vive en repos).
- Definición de rutas (eso vive en `BeamerConfigHelper`).

> El FeatureBuilder es la **fachada pública** del paquete. Si una feature externa necesita algo, lo pide vía FeatureBuilder — nunca importando archivos de `src/` directamente.

---

## 7. Navegación — agregar una ruta nueva

Stack de navegación: **Beamer** + un `NavigationHelper` con métodos `pushNamed`, `replaceNamed`, etc.

### Paso a paso para agregar una ruta `/profile`

**1. Declarar la ruta en `core/navigation/routes.dart`**

```dart
class Routes {
  static const String login = '/login';
  static const String catalog = '/catalog';
  static const String cart = '/cart';
  static const String profile = '/profile';                    // ← nueva

  // Si la ruta tiene parámetros:
  static const String profileEditPattern = '/profile/edit/:section';
  static String profileEdit(String section) => '/profile/edit/$section';
}
```

**Convención**:
- Rutas estáticas → `static const String foo = '/foo';`
- Rutas con parámetros → declarar el **pattern** (`/foo/:id`) Y un **builder** (`static String foo(String id) => '/foo/$id';`).

**2. Crear (o ubicar) el FeatureBuilder**

Si la pantalla pertenece a una feature nueva, crear `packages/features/profile/` con la estructura de la sección 2 y exponer un `ProfileFeatureBuilder.buildProfilePage()`.

Si pertenece a una feature existente, agregar el factory ahí:

```dart
static Widget buildProfilePage() => ProfilePage(cubit: Injector.i.resolve<ProfileCubit>());
```

**3. Registrar dependencias en `IocManager`**

```dart
// lib/config/ioc_manager.dart
AuthFeatureBuilder.injectDependencies();
CatalogFeatureBuilder.injectDependencies();
ProfileFeatureBuilder.injectDependencies();   // ← nueva línea
```

**4. Mapear la ruta en `BeamerConfigHelper._buildRoutes()`**

```dart
// lib/application/navigation/beamer_config_helper.dart
Routes.profile: (_, __, ___) {
  return _beamerPage(
    title: 'Perfil',
    key: 'profile',
    child: ProfileFeatureBuilder.buildProfilePage(),
  );
},

// Con parámetro:
Routes.profileEditPattern: (_, state, __) {
  final section = state.pathParameters['section'] ?? '';
  return _beamerPage(
    title: 'Editar perfil',
    key: 'profile-edit-$section',
    child: ProfileFeatureBuilder.buildProfileEditPage(section),
  );
},
```

**5. Navegar a la ruta desde donde la necesites**

```dart
Injector.i.resolve<NavigationHelper>().pushNamed(
  context,
  routeName: Routes.profile,
);

// Con parámetro:
Injector.i.resolve<NavigationHelper>().pushNamed(
  context,
  routeName: Routes.profileEdit('email'),
);

// Replace (no permite back):
Injector.i.resolve<NavigationHelper>().pushNamed(
  context,
  routeName: Routes.catalog,
  replace: true,
);
```

**6. (Opcional) Proteger con guard**

Si la ruta requiere estar autenticado, listarla en `AuthenticatedGuard` (en `lib/application/navigation/guards/auth/`). Si es lo opuesto (login, registro) — en `NotAuthenticatedGuard`.

### Cómo NO navegar

- ❌ `Navigator.of(context).push(MaterialPageRoute(...))` — no respeta Beamer.
- ❌ Hardcodear el string `'/profile'` en el lugar del push — usar `Routes.profile`.
- ❌ Llamar `pushNamed` desde el cubit — la decisión es de la page (típicamente vía `BlocListener`).

---

## 8. Design System

Cuándo subir un widget a `design_system`:

- **Sí**: si tiene prefijo `Sw*` (es brandeado) o si lo usa más de una feature.
- **Sí**: si encapsula un token visual del design (`SwCard`, `SwButton`, `SwIconButton`, `SwImgPlaceholder`).
- **No**: si depende de un tipo de feature (`ProductCard` se queda en catalog porque depende de `Product`).

Cuando subís un widget al DS:

1. Crear el archivo en `packages/design_system/lib/<categoría>/`.
2. Exportarlo en `packages/design_system/lib/design_system.dart`.
3. Borrar el archivo viejo de la feature.
4. Reemplazar los imports en los consumers.

Si dos features tenían copias diferentes del mismo widget (ej. `SwLogo` que estaba duplicado en `catalog` y `login`), **unificar al subir** — no dejar dos versiones.

---

## 9. Checklist: agregar una feature completa de cero

1. Crear el package en `packages/features/<feature>/` con `pubspec.yaml` que incluya:
   - `dependencies`: `flutter_bloc`, `freezed_annotation`, `json_annotation`, `dartz`, `commons` (path), `core` (path), `design_system` (path).
   - `dev_dependencies`: `build_runner`, `freezed`, `json_serializable`, `flutter_test` (sdk: flutter).
2. Crear `build.yaml` en la raíz del package con `field_rename: snake` (ver "data/dtos/" arriba).
3. Crear `domain/entities/` con entities Freezed (o plain) **SIN** `fromJson`.
4. Crear `domain/repositories/<feature>_repository.dart` con `abstract class` + `<Feature>Failure`.
5. Crear `data/dtos/` con un DTO por cada shape del back. `@freezed` solo, NO `@JsonSerializable`.
6. Crear `data/mappers/` con extension methods `dto.toEntity()`. Defaults y derivaciones van acá.
7. Crear `data/repositories/remote_<feature>_repository.dart` que implementa el contrato del dominio. Pasos: HTTP → `Dto.fromJson(...)` → `dto.toEntity()`. Cero parsing handwritten.
8. Crear `presentation/bloc/<feature>_cubit.dart` + `<feature>_state.dart` (state Freezed sealed). El cubit es dueño de cualquier controller que la UI necesite; dispose en `close()`.
9. Crear `presentation/pages/` y `presentation/widgets/` — **TODAS** extienden `StatelessWidget`. Leen controllers del cubit, no instancian propios.
10. Crear `<feature>_feature_builder.dart` con `injectDependencies()` que registra repo + cubit en el IoC.
11. Registrar el feature en `IocManager.register(...)`.
12. Agregar al menos un test en `test/data/mappers/<name>_mapper_test.dart` con golden JSON real del backend.
13. Correr `melos run generate` para regenerar Freezed/JSON.
14. `dart analyze` clean en el package.

---

## 10. Dependency Injection (`Injector`)

Usamos un wrapper sobre `get_it` que vive en `commons/helpers/injector/`. Acceso global vía `Injector.i`.

### Tipos de registro

| Método | Cuándo usarlo |
|--------|---------------|
| `registerSingleton<T>(instance)` | Cuando ya tenés la instancia construida y querés que el container la guarde. Ejemplo: `EnvironmentConfig`, `AppDataSource`. |
| `registerLazySingleton<T>(factory)` | Cuando la instancia es cara de crear y querés diferir hasta el primer `resolve<T>()`. Es lo que usamos para repos y cubits. |
| `registerFactory<T>(factory)` | Cuando querés una **instancia nueva** cada vez que se hace `resolve<T>()`. Casi no se usa — los cubits son singletons para que el state sobreviva entre pantallas. |

### Uso

```dart
// Registro (típicamente desde un FeatureBuilder.injectDependencies)
Injector.i.registerLazySingleton<CatalogCubit>(
  () => CatalogCubit(Injector.i.resolve<CatalogRepository>()),
);

// Resolución (típicamente desde un FeatureBuilder factory o desde una page)
final cubit = Injector.i.resolve<CatalogCubit>();

// Resolver "si existe" (sin tirar excepción)
final cubit = Injector.i.resolveOrNull<CatalogCubit>();
```

### Reglas

- **Registrar tipos por interfaz**, no por implementación: `registerLazySingleton<CatalogRepository>(...)`, no `registerLazySingleton<MockCatalogRepository>(...)`. Eso permite swapear mock ↔ remote sin tocar consumers.
- **El registro se hace una sola vez** en `IocManager.register()` al arrancar la app.
- **Resolver siempre desde el FeatureBuilder o desde el constructor de la page**. Evitar `Injector.i.resolve()` dentro de un widget profundo — pasar la instancia por constructor.
- **Cubits = singletons** (lazy). Si un cubit necesita reset entre invocaciones, exponé un método `reset()` (como `LoginCubit.reset()` o `CreateOrderCubit.reset()`).

---

## 11. HttpHelper y manejo de red

El contrato vive en `commons/helpers/http/http_helper.dart`. La implementación por defecto es `DioHttpHelper`.

### Firma

```dart
abstract class HttpHelper {
  Future<Either<HttpResponseError, HttpResponse>> get(String path, { Map<String, dynamic>? queryParameters, ... });
  Future<Either<HttpResponseError, HttpResponse>> post(String path, { dynamic data, bool retryOnTokenExpired = true, ... });
  Future<Either<HttpResponseError, HttpResponse>> patch(...);
  Future<Either<HttpResponseError, HttpResponse>> put(...);
  Future<Either<HttpResponseError, HttpResponse>> delete(...);
  Future<Either<HttpResponseError, HttpResponse>> postImages(...);
}
```

### Uso típico desde un Remote repo

```dart
final result = await httpHelper.get('/products', queryParameters: {
  'page': 1,
  'page_size': 20,
  if (search != null && search.isNotEmpty) 'search': search,
});

return result.fold(
  (error) => Left(CatalogFailure(error.message ?? 'Error obteniendo productos')),
  (response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return const Left(CatalogFailure('Respuesta inválida'));
    }
    // parsear data y devolver Right(...)
  },
);
```

### Interceptors registrados

Configurados en `IocManager` cuando se crea el `DioHttpHelper`:

- **`LoggingInterceptor`** (solo en debug): loguea requests/responses a la consola.
- **`AuthInterceptor`**: agrega `Authorization: Bearer <token>` a cada request a partir del `TokenRepository`.
- **Refresh automático**: si una request devuelve 401, `DioHttpHelper` llama a `AuthFeatureBuilder.refreshToken` y reintenta. Para evitar loops en el endpoint de login, ese llamado pasa `retryOnTokenExpired: false`.

### Convención de paths

- Paths siempre arrancan con `/` y son **relativos** al `baseUrl` (definido en `IocManager` por environment).
- Nunca hardcodear el host en el repo. Si necesitás pegarle a un servicio externo, usar `external: true`.

---

## 12. Either / Failures (dartz)

Usamos `Either<L, R>` de `dartz` para representar resultados que pueden fallar de forma **esperada** (red caída, credenciales inválidas, recurso no encontrado).

```dart
Future<Either<CatalogFailure, Product>> getProductById(String id);
```

- **`Left`** = error
- **`Right`** = éxito

### Cómo consumir

```dart
final result = await repo.getProductById('p1');
result.fold(
  (failure) => emit(CatalogError(failure.message ?? 'Error')),
  (product) => emit(CatalogReady(product: product)),
);
```

### Failures vs Exceptions

- **Failures (`Either.Left`)**: errores esperados de negocio (404, 401, validación, timeout). El caller los maneja.
- **Exceptions (`throw`)**: bugs (null inesperado, cast fallido). El caller no las maneja; las captura el `try/catch` del repo y devuelve un `Failure` genérico.

```dart
try {
  final result = await httpHelper.get(...);
  return result.fold(/* ... */);
} catch (e, st) {
  log('error', error: e, stackTrace: st);
  return const Left(CatalogFailure('Error de red'));
}
```

### Tipado de Failures

Para errores que el caller necesita **diferenciar** (mostrar copy distinto, decidir si reintentar), usar **sealed classes** dentro del feature:

```dart
sealed class LoginFailure {
  const LoginFailure(this.message);
  final String message;
}

class InvalidCredentialsFailure extends LoginFailure {
  const InvalidCredentialsFailure() : super('Credenciales inválidas...');
}

class NetworkFailure extends LoginFailure {
  const NetworkFailure() : super('Sin conexión...');
}
```

Cuando el caller no necesita diferenciar, basta una `class Failure { final String? message; }` plana (como `CatalogFailure`, `OrderFailure`).

---

## 13. Auth, tokens y guards

### Flujo de login

```
LoginPage → LoginCubit.submit(email, password)
            → LoginRepository.login(creds)
              → POST /auth/login
            ← Either<LoginFailure, AuthTokens>
         emit LoginSuccess(tokens)
←─ BlocListener (LoginPage) detecta success
   → AuthFeatureBuilder.login(token, refreshToken)
     → AuthCubit.save(...)
       → LocalAuthRepository.save(AuthData)
         → PersistenceHelper (Hive)
   → NavigationHelper.pushNamed(Routes.catalog, replace: true)
```

Las piezas:

- **`LoginRepository`** (feature `login`): habla con `/auth/login`. Devuelve `AuthTokens` (con el `User` embebido).
- **`AuthCubit`** (feature `auth`): mantiene el state global de sesión (`AuthState.empty` / `AuthState.data(authData)`).
- **`LocalAuthRepository`** (feature `auth`): persiste `AuthData` (token + refreshToken) en Hive vía `PersistenceHelper`.
- **`TokenRepository`** (feature `repositories/token_repository`): expone el access token al `AuthInterceptor` para que cada request HTTP lo incluya en el header.

### Refresh token

`DioHttpHelper` está configurado con `onRefreshToken: AuthFeatureBuilder.refreshToken`. Cuando una respuesta es 401 y `retryOnTokenExpired = true`, se llama a esa función. Si refrescar falla, se hace logout y se navega al login.

### Logout

```dart
AuthFeatureBuilder.logout();   // borra el AuthData persistido + emite AuthState.empty
```

El `NotAuthenticatedGuard` detecta el cambio de state y empuja al usuario a `Routes.login`.

### Guards de navegación

Los guards de Beamer son la única forma legítima de **bloquear acceso** a una ruta según el state de la app.

```dart
// lib/application/navigation/guards/auth/authenticated_guard.dart
class AuthenticatedGuard implements CustomBeamerGuard {
  @override
  BeamGuard get guard => BeamGuard(
        pathPatterns: [Routes.login],
        check: (context, __) {
          final authCubit = Injector.i.resolve<AuthCubit>();
          // true = puede acceder; false = redirige a onCheckFailed
          return authCubit.state.maybeWhen(orElse: () => true, data: (_, __) => false);
        },
        onCheckFailed: (context, __) {
          Injector.i.resolve<NavigationHelper>().pushNamed(
            context, routeName: Routes.catalog, replace: true,
          );
        },
      );
}
```

**Cómo se lee este guard**: aplica a `Routes.login`; si el usuario ya tiene sesión (`AuthState.data`), no puede entrar a `/login` → lo manda a `/catalog`.

Existe el espejo: **`NotAuthenticatedGuard`**, que protege las rutas privadas (`catalog`, `cart`, etc.) y manda al `/login` si no hay sesión.

### Cuándo agregar un guard nuevo

Si una ruta requiere algo más que "estar logueado" (ej. ser admin, tener un permiso), creá un guard nuevo en `lib/application/navigation/guards/<categoria>/` y registralo en `BeamerConfigHelper.guards`.

---

## 14. Persistencia local

`PersistenceHelper` (vive en `commons/helpers/persistence_helper/`) es la abstracción sobre Hive. Se inyecta como singleton en `IocManager`.

```dart
abstract class PersistenceHelper {
  Future<bool> exists(String key);
  Future<Either<Failure, T>> get<T>(String key, T Function(Map<String, dynamic>) fromJson);
  Future<Option<Failure>> set<T extends Persistable>(String key, T value);
  Future<Option<Failure>> remove(String key);
}
```

### Cuándo usarlo

- Persistir sesión: lo hace `LocalAuthRepository` para guardar `AuthData`.
- Cualquier dato que tenga que sobrevivir cierres de la app (preferencias del usuario, cache local).

### Cuándo NO

- Para estado de UI temporal (filtros, scroll, tabs activas) → eso vive en el cubit y se pierde al cerrar.

---

## 15. Design tokens

Los tokens viven en `design_system/lib/theme/sw_tokens.dart`. **Siempre usar tokens, nunca colores hardcoded**.

### Tokens disponibles

```dart
SwColors.yellow            SwColors.yellowDark      SwColors.yellowSoft
SwColors.text              SwColors.text2           SwColors.text3
SwColors.white             SwColors.surface         SwColors.border
SwColors.stockIn           SwColors.stockOut        SwColors.link
// + alias: SwColors.infoBg, SwColors.infoBorder, etc.

SwRadii.input              SwRadii.card             SwRadii.image
SwShadows.card             // List<BoxShadow>

SwText.display(size: ...)  // wordmark / títulos
SwText.body(size: ..., weight: ..., color: ...)
SwText.mono(size: ..., letterSpacing: ...)
```

### Regla

```dart
// ❌ Mal
Container(color: const Color(0xFFFFD400), ...)
Text('Hola', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))

// ✅ Bien
Container(color: SwColors.yellow, ...)
Text('Hola', style: SwText.body(size: 16, weight: FontWeight.w700))
```

Si necesitás un color o tipografía que no está en los tokens, **agregalo al `sw_tokens.dart`** primero (con un nombre semántico) y después usalo.

---

## 16. BlocBuilder, BlocListener, BlocConsumer

Tres formas distintas de conectar la UI al cubit. Usar la correcta evita rebuilds innecesarios y bugs sutiles.

| Widget | Cuándo |
|--------|--------|
| **`BlocBuilder`** | Renderizar UI a partir del state. Solo rebuild. |
| **`BlocListener`** | Side-effects (navegación, snackbar, dialogs). NO rebuild. |
| **`BlocConsumer`** | Las dos cosas juntas: render + side effects. |

### Patrón típico: success/failure → side effect

```dart
BlocListener<CreateOrderCubit, CreateOrderState>(
  bloc: createOrderCubit,
  listener: (ctx, state) {
    switch (state) {
      case CreateOrderSuccess(:final order):
        Injector.i.resolve<NavigationHelper>().pushNamed(
          ctx, routeName: Routes.orderSuccess(order.id), replace: true,
        );
      case CreateOrderFailure(:final message):
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
      case _:
        break;
    }
  },
  child: BlocBuilder<CartCubit, Cart>(
    bloc: cartCubit,
    builder: (context, cart) => /* renderizar cart */,
  ),
)
```

### Reglas

- **El `listener` no debe llamar `setState`** ni emitir nuevos states.
- **El `builder` debe ser idempotente**: el mismo state → la misma UI. Nada de `Navigator.of(context)` ahí.
- Pasar siempre `bloc: cubit` explícitamente (en este proyecto los cubits son resueltos del injector, no provistos por `BlocProvider`).

---

## 17. Convenciones de naming

| Cosa | Patrón | Ejemplo |
|------|--------|---------|
| Archivo Dart | `snake_case.dart` | `catalog_cubit.dart`, `mock_catalog_repository.dart` |
| Clase | `PascalCase` | `CatalogCubit`, `Product`, `SwButton` |
| Variable / método / param | `lowerCamelCase` | `productId`, `onAddToCart`, `imageUrl` |
| Constante top-level | `lowerCamelCase` (idiomático Dart) | `defaultPageSize` |
| Private | prefix `_` | `_pickThumbUrl`, `_StripePainter` |
| Cubit | `<Feature>Cubit` | `CatalogCubit`, `CartCubit`, `LoginCubit` |
| State | `<Feature>State` (sealed) o variantes | `CatalogLoading`, `CatalogReady` |
| Repository interface | `<Feature>Repository` | `CatalogRepository` |
| Repository impl | `<Source><Feature>Repository` | `MockCatalogRepository`, `RemoteCatalogRepository` |
| Page (root de ruta) | `<Feature>Page` o `<Concept>Page` | `CatalogPage`, `ProductDetailPage` |
| Feature builder | `<Feature>FeatureBuilder` | `CatalogFeatureBuilder` |
| Failure | `<Concept>Failure` | `CatalogFailure`, `InvalidCredentialsFailure` |
| Widget del DS | prefix `Sw` | `SwButton`, `SwCard`, `SwIconButton` |
| Asset | `snake_case.{png,svg}` | `sw_logo_mark.png`, `eye_closed.svg` |
| Route key (Beamer) | `kebab-case` | `'catalog-detail-$id'`, `'order-success-$id'` |
| Branch git | `<tipo>/<resumen-corto>` | `feat/catalog-pagination`, `fix/cart-tax-calc` |

### Sufijos por capa

- `_cubit.dart` / `_state.dart` → presentation/bloc
- `_page.dart` → presentation/pages
- `_repository.dart` → domain/repositories o data/repositories (la implementación lleva prefijo `mock_` / `remote_`)
- `_feature_builder.dart` → raíz del package

---

## 18. Tests

### Estructura

```
packages/features/<feature>/test/
├── data/
│   ├── mock_<feature>_repository_test.dart
│   └── remote_<feature>_repository_test.dart   ← usa fake HttpHelper
├── presentation/
│   └── bloc/
│       └── <feature>_cubit_test.dart           ← usa fake Repository
└── ...
```

### Fakes vs mocks

No usamos `mockito` por default — escribimos **fakes** manuales que implementan la interfaz. Es más explícito y no requiere codegen.

```dart
class _FakeRepo implements CatalogRepository {
  final List<({int page, int pageSize, String? search, String? categoryId})> calls = [];
  Future<Either<CatalogFailure, ProductsPage>> Function(int page, String? search, String? categoryId) handler =
      (page, _, __) async => Right(_emptyPage(page));

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1, int pageSize = 20, String? search, String? categoryId,
  }) async {
    calls.add((page: page, pageSize: pageSize, search: search, categoryId: categoryId));
    return handler(page, search, categoryId);
  }
  // resto de métodos: throw UnimplementedError o stub vacío
}
```

### Qué se testea

- **Repos mock**: pagination, filter, edge cases (página vacía, fuera de rango).
- **Repos remote**: parsing del JSON del contrato + manejo de errores HTTP. Usar fake `HttpHelper`.
- **Cubits**: cada acción pública dispara los states esperados; pagination acumula; stale responses se descartan.
- **Widget tests**: opcional para componentes complejos del design system.

### Patrón típico de test de cubit

```dart
test('emits Loading then Ready with first page', () async {
  final repo = _FakeRepo()
    ..handler = (page, _, __) async =>
        Right(_page(1, [_p('1'), _p('2')], total: 30, hasNext: true));
  final cubit = CatalogCubit(repo);
  final emitted = <CatalogState>[];
  final sub = cubit.stream.listen(emitted.add);

  await cubit.load();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();

  expect(emitted.first, isA<CatalogLoading>());
  expect(emitted.last, isA<CatalogReady>());
});
```

### Antes de pushear

```bash
cd packages/features/<feature>
dart analyze     # no issues
flutter test     # all tests passed
```

---

## 19. Plans y specs antes de implementar

Para features de tamaño medio/grande (más de un par de archivos), **antes de escribir código** dejamos un doc breve en `docs/superpowers/`:

```
docs/superpowers/
├── specs/   ← "qué" y "por qué" (1-2 páginas, decisiones de diseño)
└── plans/   ← "cómo" (lista de pasos accionables con archivos y comandos exactos)
```

Convención de nombre: `YYYY-MM-DD-<nombre>.md` (ej. `2026-05-19-api-contracts-design.md`, `2026-05-20-catalog-pagination.md`).

El spec viaja con el código en el mismo PR. Funciona como ADR (Architecture Decision Record): en 3 meses, abrir el spec explica el "por qué" mejor que el commit.

---

## 20. Convenciones de commits / PRs

### Formato

Conventional Commits con scope opcional:

```
<tipo>(<scope>): <resumen en imperativo, ≤72 chars>

<cuerpo opcional explicando "por qué" — no "qué">

Co-Authored-By: ...  (cuando aplique)
```

Tipos comunes en uso: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`. Scopes vistos: `catalog`, `cart`, `auth`, `api`, `env`, `ui`, `design_system`, `domain`.

### Ejemplos del repo

```
feat(catalog): paginate grid with cubit-owned scroll and skeleton footer
refactor(env): drive mock/remote toggle from AppDataSource (dart-define)
fix(catalog): product detail price overflow and add-to-order button truncation
docs(catalog): add pagination implementation plan
```

### Flujo de PR

1. Branch desde main: `git checkout -b feat/<resumen-corto>`.
2. Spec/plan en `docs/superpowers/` si el cambio es no trivial.
3. Commitear en chunks lógicos (entity → repo → UI → tests). Evitar un commit gigante.
4. `dart analyze` + `flutter test` antes de pushear.
5. Push y abrir PR en GitHub apuntando a `main`.
6. Para conflictos con main: **rebase** sobre `origin/main`, no merge.
7. Force-push con `--force-with-lease` solo después de rebase (nunca a `main`).

---

## 21. Assets y fuentes

Los assets (imágenes, íconos SVG, fuentes) viven en `/assets` en la raíz del repo y se declaran una sola vez en `pubspec.yaml` raíz:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/
  fonts:
    - family: Satoshi
      fonts:
        - asset: assets/fonts/Satoshi-Regular.otf
        # ...
```

### Para agregar una imagen / ícono

1. Tirar el archivo en `assets/images/` (PNG/JPG/WebP) o `assets/icons/` (SVG).
2. Nombre en `snake_case.{png,svg}`.
3. Si la imagen es brand (logo, hero), exponela vía un widget del design system (`SwLogo`). Si es feature-specific, usala directo desde el widget de la feature con `Image.asset('assets/images/foo.png')`.
4. SVGs: usar `flutter_svg` (`SvgPicture.asset('assets/icons/foo.svg')`).

### Fuentes

La familia activa es **Satoshi** (declarada en `pubspec.yaml`). El acceso idiomático es vía `SwText.*` del design system, no `TextStyle(fontFamily: 'Satoshi', ...)` directo.

Si necesitás agregar una fuente nueva, declarala en `pubspec.yaml` y exponé un helper en `design_system/lib/theme/themes/smartwarehouse/smart_warehouse_text_styles.dart`.

---

## 22. Inter-package dependencies (pubspec.yaml)

Cuando una feature nueva necesita usar tipos de **otra feature**, agregás la dependencia como `path:` en el `pubspec.yaml` del package.

### Pubspec típico de un feature

```yaml
# packages/features/order_history/pubspec.yaml
name: order_history
description: "Order history: list past orders with filter and detail."
version: 0.0.1
publish_to: none

environment:
  sdk: '>=3.8.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  commons:
    path: ../../commons
  core:
    path: ../../core
  design_system:
    path: ../../design_system
  orders:               # ← si necesita reusar Order / OrderItem
    path: ../orders
  dartz: ^0.10.1
  flutter_bloc: ^9.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Reglas

- **`core`** ya re-exporta `auth`, `cart`, `catalog`, `commons`, `login`, `orders` y `token_repository`. Si tu feature ya importa `core`, no necesita importarlas individualmente (a menos que el lint `depend_on_referenced_packages` te lo pida).
- Si tu feature va a ser **consumida por la app** (la usa el `BeamerConfigHelper`), agregala también como dependencia en `pubspec.yaml` raíz **y** en `packages/core/pubspec.yaml` si querés que `core` la re-exporte.
- Después de cambiar un `pubspec.yaml`, correr `dart pub get` en ese package (o `melos bootstrap` para todo).

### Evitar ciclos

`core` puede depender de las features, pero ninguna feature puede depender de `core` **si causa un ciclo**. En la práctica, `core` solo expone `Routes`, `NavigationHelper`, `EnvironmentConfig`, `AppDataSource` y use-cases globales. Las features importan esos desde `core`, pero `core` no importa lógica de features (solo re-exporta sus barrels).

---

## 23. Anti-patterns — qué NO hacer

Lista corta de cosas que se vieron en review y vamos a rechazar:

### Lógica en widgets

```dart
// ❌ Mal
class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (product.stock.available <= 0 && user.isAdmin) {
      // decisión de negocio en el widget
    }
  }
}

// ✅ Bien
// El cubit decide y emite un state que la UI renderiza tal cual.
```

### Cubit con `BuildContext`

```dart
// ❌ Mal
class LoginCubit {
  Future<void> submit(BuildContext context, ...) async {
    // ...
    Navigator.of(context).pushReplacementNamed('/catalog');
  }
}

// ✅ Bien
// El cubit emite LoginSuccess(...); la page lo intercepta con BlocListener
// y dispara la navegación.
```

### Imports cruzados entre features

```dart
// ❌ Mal — login importa código interno de catalog
import 'package:catalog/src/data/repositories/mock_catalog_repository.dart';

// ✅ Bien — usar el barrel público (`catalog.dart`) o el FeatureBuilder
import 'package:catalog/catalog.dart';
```

### `Navigator.push` directo

```dart
// ❌ Mal — bypassea Beamer + guards
Navigator.of(context).push(MaterialPageRoute(builder: (_) => SomePage()));

// ✅ Bien
Injector.i.resolve<NavigationHelper>().pushNamed(
  context, routeName: Routes.somePage,
);
```

### Strings de rutas hardcoded

```dart
// ❌ Mal
Injector.i.resolve<NavigationHelper>().pushNamed(context, routeName: '/catalog');

// ✅ Bien
Injector.i.resolve<NavigationHelper>().pushNamed(context, routeName: Routes.catalog);
```

### Colores y fonts hardcoded

```dart
// ❌ Mal
Container(color: const Color(0xFFFFD400))
Text('Hola', style: TextStyle(fontSize: 16, color: Colors.grey))

// ✅ Bien
Container(color: SwColors.yellow)
Text('Hola', style: SwText.body(size: 16, color: SwColors.text3))
```

### `throw` para errores esperables

```dart
// ❌ Mal
Future<Product> getProductById(String id) async {
  final response = await http.get(...);
  if (response.statusCode == 404) throw ProductNotFound();
  return Product.fromJson(response.data);
}

// ✅ Bien
Future<Either<CatalogFailure, Product>> getProductById(String id) async {
  // devolver Left(CatalogFailure('Producto no encontrado')) ante 404
}
```

### Llamar `Injector.i.resolve` adentro de un widget profundo

```dart
// ❌ Mal — acopla el widget al injector y rompe los widget tests
class ProductTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Injector.i.resolve<CartCubit>();
    // ...
  }
}

// ✅ Bien — el widget recibe callbacks por constructor
class ProductTile extends StatelessWidget {
  const ProductTile({required this.onAdd, ...});
  final VoidCallback onAdd;
}
```

### `setState` para datos que ya están en el cubit

```dart
// ❌ Mal — el cubit ya maneja products, no dupliques en local state
class _CatalogPageState extends State<CatalogPage> {
  List<Product> _filteredProducts = [];
  // ...
}

// ✅ Bien — leer del state del cubit directamente.
// Solo usar setState para state puramente local de UI (controllers, focus, tab activa).
```

### Lógica fuerte en `FeatureBuilder`

```dart
// ❌ Mal — el FeatureBuilder es una fachada, no un servicio
class CatalogFeatureBuilder {
  static Future<Product?> getProductByIdIfActive(String id) async {
    final repo = Injector.i.resolve<CatalogRepository>();
    final result = await repo.getProductById(id);
    return result.fold((_) => null, (p) => p.stock.available > 0 ? p : null);
  }
}

// ✅ Bien — eso es lógica de negocio, va a un cubit o a un use case en `core`.
```

---

## 24. Resumen del flujo de datos (de abajo hacia arriba)

```
┌─────────────────────────────────────────┐
│ Page / Widget                           │  → renderiza state, dispara acciones
│   BlocBuilder<Cubit, State>             │
└──────────────┬──────────────────────────┘
               │ cubit.someAction()
               ▼
┌─────────────────────────────────────────┐
│ Cubit                                   │  → lógica, decisiones, orquestación
│   emit(SomeState(...))                  │
└──────────────┬──────────────────────────┘
               │ repository.method(...)
               ▼
┌─────────────────────────────────────────┐
│ Repository (interface en domain)        │  → contrato
│   ├── MockImpl (data)                   │  → datos in-memory para demo/tests
│   └── RemoteImpl (data)                 │  → HTTP + parsing JSON
└──────────────┬──────────────────────────┘
               │ httpHelper.get(...)
               ▼
┌─────────────────────────────────────────┐
│ HttpHelper (commons)                    │  → red, retries, interceptors
└─────────────────────────────────────────┘
```

Las **entities** atraviesan todas las capas sin transformarse. Los **DTOs** viven en `data/dtos/` y solo existen entre el Remote repo y el backend; los **mappers** (en `data/mappers/`) los convierten en entities antes de cruzar a `domain/`.

---

## Anexos

- **API contracts**: `docs/superpowers/specs/2026-05-19-api-contracts-design.md`
- **Backlog & sprints**: `docs/superpowers/specs/2026-05-06-mobile-backlog-design.md`
- **Plan del catalog paginado**: `docs/superpowers/plans/2026-05-20-catalog-pagination.md`

> Si algo en este doc te parece confuso, no dudes en proponer una mejora en el mismo PR donde te trabaste. La doc es del equipo, no de quien la escribió originalmente.
