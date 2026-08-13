# Patrol e2e testing — design

Date: 2026-08-12
Status: approved by Julian (chat)

## Goal

End-to-end tests for all main flows of Smart Warehouse using Patrol, running on
Android emulator and iOS simulator against a **live local API**. Special focus:
price/currency consistency across catalog → detail → cart → checkout, because a
real bug once showed a different currency on products added to the cart.

## Decisions

- Backend: live local API. Default base URL `http://10.0.2.2:8080` (Android) /
  `http://localhost:8080` (iOS); overridable with `--dart-define=API_BASE_URL`.
- Credentials: default `admin@smartwarehouse.local` / `changeme` (backend seed,
  same as scripts/*.py), overridable with `--dart-define=E2E_EMAIL` / `E2E_PASSWORD`.
- Platforms: Android + iOS native Patrol scaffolding.
- Scope: all main flows.

## Tooling

- Root `pubspec.yaml`: add `patrol` and `integration_test` (sdk) to
  dev_dependencies plus the `patrol:` config block (app name, Android package
  `com.smartwarehouse.smart_warehouse`, iOS bundle id
  `com.smartwarehouse.smartWarehouse`).
- `patrol_cli` installed globally (`dart pub global activate patrol_cli`).
- Android: `android/app/src/androidTest/java/com/smartwarehouse/smart_warehouse/MainActivityTest.java`,
  Gradle `testInstrumentationRunner` + androidx.test dependencies.
- iOS: `RunnerUITests` target with `RunnerUITests.m`. If pbxproj wiring is not
  automatable cleanly, document the manual Xcode steps in the README.

## Test structure

```
integration_test/
  common/config.dart          # dart-define backed E2E config
  common/patrol_helpers.dart  # app boot, splash wait (3s timer), login/logout,
                              # price-string extraction helpers
  login_test.dart             # valid + invalid credentials
  catalog_test.dart           # browse, search, filter, product detail
  cart_checkout_test.dart     # add to cart, qty stepper, price consistency,
                              # confirm order → order success
  orders_test.dart            # orders list + order detail
  profile_test.dart           # profile view + logout
```

## Price/currency consistency (regression guard)

The app formats prices only through `Money.formatted` (catalog package), but the
API exposes two price shapes (`amount` on /products vs `amount_cents` on
/products/{id}), which is the likely source of the past currency/amount bug.
Tests assert:

1. The price string on the catalog `ProductCard` equals the price on the
   product detail page for the same product.
2. The unit price on the cart line equals the catalog/detail price.
3. Line subtotal = unit price × quantity (recomputed from parsed values).
4. Cart total = sum of line subtotals; same currency symbol everywhere.
5. Order confirmation dialog total equals cart total.

A helper parses the app's `$1.234,56` format into (symbol, minor units) so the
assertions compare numbers, not just strings.

## Stable finders

The codebase has almost no widget `Key`s. Add a minimal set of keys (exposed as
constants in a shared `WidgetKeys`-style file in `packages/core`) to:
login email/password fields and submit button, product cards and their price
text, detail price + add-to-cart button, cart line price/subtotal, cart total,
checkout confirm/cancel, logout button, bottom-nav tabs. Text finders elsewhere.

## Test isolation

Each test boots the app fresh via `main()`-equivalent bootstrap and logs out (or
clears the Hive auth box) in setup, so persisted sessions don't leak between
tests. Waits account for the 3-second splash timer and dismiss any WebSocket
notification snackbars before tapping.

## Run ergonomics

- `make e2e` → `patrol test` with pass-through of `API_BASE_URL`, `E2E_EMAIL`,
  `E2E_PASSWORD`, plus `make e2e-android` / `e2e-ios` device-targeted variants.
- README section: prerequisites (backend running + seeded, emulator/simulator
  booted, patrol_cli installed) and commands.

## Out of scope

- CI wiring (can be added later once the suite is stable locally).
- Mock-mode e2e runs.
- Native permission-dialog flows (avatar/image picker) — later iteration.

## Addendum (same day): hardening de la app

A pedido de Julian ("endurecer todo, no solo lo que te digo"), además de los
tests se corrigieron las causas raíz y fallas frágiles detectadas por auditoría:

- PriceDto: parsing manual de `amount`/`amount_cents`, rechaza precio sin
  monto o sin moneda (antes: $0/ARS silencioso).
- Producto sin precio: fila salteada con log (no rompe la página ni muestra $0).
- Cart: `hasMixedCurrencies`, total null en vez de crash, checkout bloqueado
  con snackbar.
- Profile: se eliminó el formateador de dinero duplicado (US-style); historial
  y "gastado este mes" con `Money` real, filtrado por mes, "—" si no confiable.
- Order list/detail: total solo si hidratación completa y moneda única; "—"
  si no.
- order_mapper: suma defensiva (sin crash por monedas mezcladas), fechas
  ilegibles → epoch (al final de la lista).
- Cubits: guards `isClosed` post-await; streams WS con `onError`.
- Orden creada: persistencia del id await-eada con log de fallo (antes podía
  desaparecer de "Mis órdenes").
- Carrito: clamp de cantidad a stock/máximo al agregar.
- Checkout "Guardar en mi perfil": carga perfil si hace falta + snackbar si
  falla (antes no-op silencioso).
- Login: payload con user sin email → rechazado.

Pendientes (requieren build_runner regen): `stock` requerido en DTO,
paginación faltante tratada como error de contrato.
