# Widget tests de `design_system` (Fase 3) — Design

**Fecha**: 2026-08-26
**Issue**: #169 (E8.2.15), bajo el epic #129
**Estado**: pendiente de aprobación

---

## 0. Autoridad y alcance de este documento

El spec de `2026-08-12-test-strategy-design.md` **sigue siendo la autoridad**: define
los targets por package, las convenciones (`mocktail` + `bloc_test`), el ratchet de
floors y qué no se testea. Ante una contradicción, gana ese documento.

Este spec existe porque la medición previa a #169 encontró tres cosas que el spec
original no podía saber el 12 de agosto, y que cambian el trabajo:

1. El denominador real de `design_system` es **894 líneas ejecutables**, no 3.190 LOC.
2. Hay **11 archivos que nadie referencia**, que aportan 221 de esas líneas.
3. La mitad de la superficie "con lógica" del package es la familia legacy `Custom*`,
   que está viva solo porque `login` usa tres de sus componentes.

No cubre #168 (`bottom_navigation_bar`), la otra mitad de la Fase 3.

---

## 1. Contexto

`design_system` es el único package del monorepo **sin carpeta `test/`**. Su floor en
`coverage_thresholds.yaml` es 0 y su cobertura medida es 0,7%.

El package contiene dos generaciones de componentes que conviven:

| Familia | Componentes | Call sites fuera de `design_system` |
|---|---|---|
| `Sw*` (actual) | `SwButton`, `SwCard`, `SwIconButton`, `SwEmptyView`, `SwErrorView`, `SwLoadingSpinner`, `SwImgPlaceholder`, `SwTextField`, `SwBottomNav`, `SwLoadingSkeleton`, `SwLogo` | 1 a 9 cada uno |
| `Custom*` (legacy) | `CustomIcon`, `CustomTextInput`, `PrimaryButton`, `CustomTabBar`, `CustomDropdown`, `CircularImage`, `OtpLayout`, … | 0, salvo tres casos |

Los tres casos: `AccessLayout`, `CustomAppBar` y `CustomText`, los tres usados solo
desde `login`. Alcanzan para mantener viva, por transitividad, buena parte de la
familia legacy — `AccessLayout` importa `PrimaryButton`, `CustomTextInput` y
`CustomIcon`.

### 1.1 Baseline medido (2026-08-26)

Medido con `melos bootstrap`, generando el archivo de imports de cobertura y corriendo
`flutter test --coverage --no-pub` sobre el package.

**Total: 6 / 894 líneas = 0,7%.**

Esa cifra coincide con la que registra `E8.2-ESTADO.md` §2 para `design_system`, lo que
confirma que 894 es el denominador que ve CI hoy.

De esas 894, **221 corresponden a los 11 archivos huérfanos** de §5.1. Quitándolos
quedan 673, y estos son los archivos más pesados de ese resto:

| Archivo | LF | LOC | Nota |
|---|---|---|---|
| `theme/themes/smartwarehouse/smart_warehouse_text_styles.dart` | 64 | 271 | getters que devuelven `TextStyle` |
| `buttons/primary_button.dart` | 62 | 159 | |
| `inputs/custom_text_input.dart` | 58 | 165 | |
| `theme/extensions/custom_theme_extension.dart` | 48 | 129 | `lerp` / `copyWith` |
| `inputs/sw_text_field.dart` | 47 | 124 | |
| `widgets/sw_img_placeholder.dart` | 41 | 96 | incluye `CustomPainter` |
| `navigation_bar/sw_bottom_nav.dart` | 35 | 98 | |
| `buttons/sw_button.dart` | 33 | 96 | |
| `navigation_bar/custom_app_bar.dart` | 32 | 82 | |
| `layouts/access_layout.dart` | 30 | 93 | |
| `theme/theme_data/custom_text_styles.dart` | 26 | 82 | `lerp` |
| resto (18 archivos) | 197 | | |

> **LOC y LF no son la misma métrica, y en este package divergen fuerte.**
> `icon/custom_icon.dart` son 359 LOC y **9 líneas ejecutables**: es un widget de
> cinco líneas más un blob de SVGs inline en `static const`. Cualquier estimación de
> esfuerzo hecha sobre los 3.190 LOC de la tabla del spec original sobreestima el
> trabajo por un factor grande.

---

## 2. Objetivos

- `design_system` ≥ 40% de cobertura de líneas, con el floor rachetado en CI.
- Los tests cubren **comportamiento**: estado interno, callbacks y renderizado
  condicional. Nada de layout puro.
- Sacar del package la dependencia muerta `vibration`, que hoy se resuelve y se
  registra como plugin sin que nadie la use (§4).

## 3. No objetivos

- **No** se borran los 10 componentes de UI no referenciados. Se excluyen y se documenta
  por qué. SmartWarehouse es un repo compartido y puede haber ramas sin mergear que los
  usen. La única excepción es `mixins/vibration.dart`, que sí se borra: ver §4.
- **No** se testea layout: padding, spacing, radios, hex. Ese es el motivo explícito
  por el que el target es 40% y no 80% (#169).
- **No** golden tests.
- **No** se toca `bottom_navigation_bar` (#168).
- **No** se refactorea la familia legacy `Custom*` ni se migra `login` a la familia `Sw*`.

---

## 4. La dependencia muerta `vibration`

> **Esta sección se reescribió tras verificar contra el workspace bootstrapeado.**
> Una versión anterior de este spec la titulaba "hallazgo bloqueante" y afirmaba que
> el package no compilaba bajo test. Ese diagnóstico era **incorrecto**: ver §4.3.
> El contenido de §4.1 y §4.2 se sostiene; la urgencia, no.

### 4.1 La dependencia está muerta en todo el monorepo

Verificado con `grep` sobre `lib/` y `packages/` completos:

| Hecho | Estado |
|---|---|
| Quién declara `vibration: ^2.0.0` | solo `packages/design_system/pubspec.yaml` |
| Quién importa `package:vibration` | solo `lib/mixins/vibration.dart` |
| Quién mixea `VibrationMixin` | **nadie**: se declara y no se usa |
| `hasVibration` de `PressableWidget` | se declara y **nunca se lee** — vestigio de la feature removida |

### 4.2 Corrección: borrar, no excluir

`mixins/vibration.dart` se **borra**, junto con la línea `vibration: ^2.0.0` del
pubspec del package. Es la única excepción al criterio de §5.1, y se separa del resto
de los huérfanos porque es distinto en naturaleza:

- Los otros 10 son componentes de UI (`CustomTabBar`, `CustomDropdown`,
  `CircularImage`) que alguien podría estar renderizando en una rama sin mergear.
  `vibration.dart` es un mixin que **nada mixea**.
- Excluirlo del denominador lo saca de la métrica, pero deja `vibration` y su cadena
  transitiva adentro del grafo de resolución: se sigue bajando en cada
  `melos bootstrap` y se sigue registrando como plugin en los builds de Android e iOS,
  para un mixin que nadie usa.

Son dos líneas, con cero referencias confirmadas por grep sobre `lib/` y `packages/`
completos. Si alguien tuviera una rama usando `VibrationMixin`, al mergear le falla la
compilación con un error explícito y revertir son esas mismas dos líneas.

**Es limpieza, no desbloqueo.** No es precondición de nada: si se prefiere un diff
100% test-only para #169, excluirlo junto a los otros 10 es una alternativa válida y
el resto del spec no cambia.

**Fuera de alcance**: el parámetro muerto `hasVibration` de `PressableWidget` se deja
como está. Sacarlo es un cambio de API pública del design system.

### 4.3 Falsa alarma: una caché de pub corrupta

La primera medición de este spec se hizo con `flutter pub get` sobre el package, sin
bootstrapear el workspace, y falló al compilar los 42 archivos:

```
vibration_platform_interface-0.0.3/lib/src/method_channel_vibration.dart:8:9:
  Error: Type 'DeviceInfoPlugin' not found.
```

Se interpretó como una incompatibilidad del paquete publicado, y sobre esa lectura se
declaró un "hallazgo bloqueante". **Era un diagnóstico equivocado.**

`vibration_platform_interface 0.0.3` declara correctamente
`device_info_plus: ">=9.0.2 <12.0.0"`. Lo que estaba roto era la caché local de pub:
el directorio `device_info_plus-11.5.0` existía **vacío**, con cero archivos. Por eso
el tipo no aparecía.

Corriendo `melos run test:coverage` sobre el workspace bootstrapeado, el error real
salió a la luz con otra forma —
`Could not find a file named "pubspec.yaml" in ...device_info_plus-11.5.0` — que
apunta a la caché y no al paquete. Tras borrar ese directorio y re-hacer
`flutter pub get`, **los 42 archivos compilan, `vibration.dart` incluido**, y el
package emite `lcov.info` sin problemas.

**Consecuencias para el plan**: ninguna sobre los números —los 894 de §1.1 se midieron
después de la reparación, y coinciden con `E8.2-ESTADO.md`—, y ninguna sobre CI, que
está sano hoy en `develop`. Lo único que cambia es el estatus de §4.2: pasa de
precondición a limpieza opcional.

Si alguien vuelve a ver ese error de `DeviceInfoPlugin`, la solución es
`dart pub cache repair`, o borrar el directorio vacío y re-fetchear.

---

## 5. Exclusiones

Las dos exclusiones van en el bloque `packages.design_system.exclude` de
`coverage_thresholds.yaml`, cada una con su comentario. El gate aplica los globs sobre
los registros `SF:` del lcov (`tool/coverage/lcov_parser.dart`), así que la exclusión
saca los archivos del denominador aunque queden instrumentados por transitividad.

### 5.1 Archivos no referenciados (10 archivos, 635 LOC)

Calculados por alcanzabilidad transitiva desde los cinco roots reales del package: el
barrel `design_system.dart`, `smart_warehouse_theme.dart` (que importa
`lib/application/application.dart` del app shell), y los tres componentes que usa
`login` (`AccessLayout`, `CustomAppBar`, `CustomText`).

```
buttons/custom_icon_button.dart            navigation_bar/navigation_item.dart
buttons/icon_text_button.dart              widgets/base_custom_list.dart
dropdown/custom_dropdown.dart              widgets/circular_image.dart
layouts/otp_layout.dart                    widgets/custom_tab_bar.dart
navigation_bar/custom_navigation_bar.dart  widgets/custom_tab_bar_list.dart
```

Son 31 archivos alcanzables (2.601 LOC) contra 11 huérfanos (643 LOC). De esos 11, diez
se excluyen —los de la lista— y el restante, `mixins/vibration.dart` (8 LOC), se borra
por el motivo de §4.2.

**Por qué excluir y no testear**: `CustomTabBar` y `CustomDropdown` son exactamente los
componentes "con estado interno y callbacks" que el enunciado de #169 señala.
Testearlos fija el comportamiento de código que ninguna pantalla renderiza, y consume
el presupuesto de la fase sin proteger nada.

**Por qué excluir y no borrar**: es un repo compartido con ramas sin mergear. El
comentario en el YAML deja la deuda anotada y visible para quien decida borrarlos.

### 5.2 Declaraciones puras (1 archivo con peso, 64 líneas)

- `theme/themes/smartwarehouse/smart_warehouse_text_styles.dart` — 64 LF, 271 LOC de
  getters que devuelven un `TextStyle` literal.
- `theme/themes/smartwarehouse/smart_warehouse_colors.dart` — 0 líneas ejecutables; se
  excluye por consistencia, sin efecto sobre el número.

Afirmar `SwColors.yellow == const Color(0xFFFBC400)` es una constante igual a sí misma.
Es el mismo razonamiento que el spec original aplicó en §5.1 a los adaptadores finos
("testearlos equivale a afirmar 'se llamó a Hive'").

### 5.3 Lo que **no** se excluye, aunque lo parezca

`theme/sw_tokens.dart` (11 LF) y `theme/theme_data/custom_text_styles.dart` (26 LF) se
leen como archivos de declaraciones, pero sus líneas ejecutables no son las constantes:
son los builders `SwText.display/body/label/mono` y `CustomTextStyles.lerp`. Los
ejercita cualquier test de widget real. Excluirlos sería inflar el porcentaje en la
dirección contraria.

### 5.4 Denominador resultante

| | Líneas |
|---|---|
| Denominador medido, todos los archivos (§1.1) | 894 |
| menos los 11 huérfanos de §5.1 | −221 |
| menos `smart_warehouse_text_styles.dart` de §5.2 | −64 |
| **Denominador del gate** | **609** |
| **40% ⇒ líneas a cubrir** | **244** |

> Borrar `mixins/vibration.dart` (§4.2) en lugar de excluirlo **no mueve estos
> números**: sale del denominador de las dos formas. Borrar contra excluir cambia el
> grafo de dependencias, no la métrica.

---

## 6. Qué se testea

Comportamiento observable únicamente: qué callback se dispara, con qué argumento, y qué
se renderiza o deja de renderizarse según los inputs.

| Componente | Aserciones |
|---|---|
| `CustomThemeExtension` | `lerp` en t=0 / 0,5 / 1; `copyWith` pisa un campo y preserva los otros 18; `of()` cae a `SmartWarehouseTheme` cuando no hay extension registrada |
| `SwButton` | `onPressed` se dispara; `isLoading` cambia label→spinner **y** bloquea el tap; `onPressed: null` deshabilita; las tres variantes; `compact` |
| `SwTextField` | el foco cambia el color del borde; `error` renderiza el mensaje y gana sobre el estilo de foco; `obscure`; `trailingAction` |
| `SwBottomNav` | `onTabSelected` reporta el `id` correcto; color activo vs inactivo; badge oculto en 0, `99+` por encima de 99 |
| `SwIconButton` / `SwBadge` | callback del tap; `SwBadge` renderiza `SizedBox.shrink` con `count <= 0`; clamp a `99+` |
| `SwImgPlaceholder` | `imageUrl` null o vacío → rayas; `errorBuilder` → rayas; `label` en mayúsculas; `_StripePainter.shouldRepaint` |
| `SwEmptyView` | el CTA aparece solo si `ctaLabel` **y** `onCtaPressed` son no-null (el `&&` es una rama real); el callback se dispara |
| `SwErrorView` | "Reintentar" invoca `onRetry` |
| `SwLoadingSkeleton` | anima sin filtrar el `AnimationController`; `.circle` fija `borderRadius = size / 2` |
| `CustomText` | el `assert` salta si `style` y `styleBuilder` son ambos null; `useLineHeight: false` fuerza `height: 1` |
| `PressableWidget` | `onPressed: null` ⇒ `onTap` null (deshabilitado) y se aplica `disabledColor` |
| `CustomTextInput` | `_getStyle` pinta de rojo con error; formatters de `number` y `phone`; `PercentageFormatter` (lógica pura: rechaza >100, saca el `%`, posiciona el cursor) |
| `PrimaryButton`, `CustomAppBar`, `AccessLayout`, `CustomDialog`, `SwCard`, `SwLogo` | solo callbacks y renderizado condicional |

### 6.1 Qué **no** se testea, a propósito

- Padding, spacing, radios, sombras, colores hardcodeados. Rompen con cada cambio de
  diseño y no detectan defectos: es la razón declarada del target de 40%.
- Los getters de `smart_warehouse_text_styles.dart` (§5.2).
- La familia huérfana de §5.1.

---

## 7. Estructura y harness

```
packages/design_system/test/
├── support/
│   └── harness.dart
├── buttons/sw_button_test.dart
├── buttons/sw_icon_button_test.dart
├── inputs/sw_text_field_test.dart
├── inputs/custom_text_input_test.dart
├── navigation_bar/sw_bottom_nav_test.dart
├── theme/custom_theme_extension_test.dart
├── widgets/sw_img_placeholder_test.dart
└── …                       ← el árbol espeja lib/
```

`support/harness.dart` expone `pumpDs(tester, widget)`: envuelve en `MaterialApp` con
`SmartWarehouseTheme` y setea `GoogleFonts.config.allowRuntimeFetching = false`.

Ese último punto no es cosmético: `SwText` y `CustomTextStyles` se construyen sobre
`google_fonts`, que sin ese flag intenta bajar las fuentes por red durante el test.

`mocktail` solo donde haga falta verificar una llamada; para los callbacks alcanza con
closures que asientan en una variable local. **Nada de esto va a `test_support`**: la
regla vigente es que un helper se comparte recién cuando lo necesitan ≥2 packages, y ese
package ya arrastra de más (ver "Partir `test_support`" en `E8.2-ESTADO.md` §3).

### 7.1 Dos limitaciones conocidas

- **`SwLogo`** llama `Image.asset('assets/images/sw_logo_full.png')`, pero el asset vive
  en el root de la app y `design_system/pubspec.yaml` no declara bloque
  `flutter: assets:`. Bajo test la carga falla en silencio en vez de tirar. El test
  afirma el label de `Semantics` y qué asset elige según `markOnly`, no que la imagen
  renderice.
- **`SwImgPlaceholder`** usa `Image.network`. El `HttpClient` por defecto de
  `flutter_test` responde 400, lo que dispara el `errorBuilder` — que es justamente una
  de las ramas a cubrir. No hace falta mockear la red.

---

## 8. Entrega

1. Rama `feature/e8.2-phase3-design-system` sobre `develop`. El prefijo `feature/` es
   requisito del job `validate-branch` de CI.
2. `melos bootstrap`. El denominador ya está verificado sobre el workspace
   bootstrapeado (§1.1): 894 líneas, 609 tras exclusiones.
3. **Commit de limpieza**, aislado: borrar `lib/mixins/vibration.dart` y la línea
   `vibration: ^2.0.0` del pubspec (§4.2), más las dos exclusiones comentadas en
   `coverage_thresholds.yaml` (§5). Va primero y solo, para que se pueda revisar —o
   revertir— sin tocar los tests. Sacar la línea del pubspec cambia la resolución del
   workspace: la descripción del PR tiene que avisar que hay que re-bootstrapear.
4. El harness, y después los tests, agrupados por componente.
5. `melos run test:coverage` en verde.
6. `dart run tool/check_coverage.dart --update` para rachetear el floor de 0 a lo medido
   menos un punto, en un commit aparte para que el salto del umbral sea un diff
   revisable por sí mismo.

### 8.1 Criterio de aceptación

`design_system` ≥ 40% con el floor rachetado, sin tests de layout puro, y
`melos run test:coverage` pasando de punta a punta.

---

## 9. Decisiones tomadas

Se registran acá con su costo si estuvieron mal, siguiendo el formato de
`E8.2-ESTADO.md` §6.

| # | Decisión | Costo si estuvo mal |
|---|---|---|
| 1 | Excluir 10 de los 11 huérfanos en vez de borrarlos | Quedan 635 LOC muertas en el repo, anotadas pero no removidas |
| 1b | Borrar `mixins/vibration.dart` y `vibration: ^2.0.0` en vez de excluirlos (§4.2), aun después de caerse la premisa de que rompían el build (§4.3) | Una rama sin mergear que use `VibrationMixin` falla al compilar al mergear; revertir son dos líneas |
| 2 | Excluir `smart_warehouse_text_styles.dart` del denominador | El 40% no es comparable con el baseline del spec original; hay que leer §5.4 para reconstruirlo |
| 3 | **No** excluir `sw_tokens.dart` ni `custom_text_styles.dart` pese a parecer declarativos | 37 líneas más de denominador; si los tests no las tocan, cuesta ~6 puntos del target |
| 4 | Harness propio en `design_system/test/support/` en vez de `test_support` | Si `bottom_navigation_bar` (#168) necesita el mismo `pumpDs`, hay que promoverlo — una mudanza de un archivo |
| 5 | Medir primero con `flutter pub get` en vez de `melos bootstrap` | **Costó de verdad**: produjo el diagnóstico equivocado de §4.3, que se propagó al spec y a una decisión ya tomada hasta que se verificó contra el workspace bootstrapeado. Los números no se movieron; la lectura del error sí |
