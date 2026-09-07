# Widget tests de `design_system` (Fase 3) — Design

**Fecha**: 2026-08-26 · **revisado el 2026-09-02, después de implementar**
**Issue**: #169 (E8.2.15), bajo el epic #129
**Estado**: implementado — `design_system` en **98,4% (599/609)**, floor rachetado a 97

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

### 0.1 Qué cambió en la revisión del 2026-09-02

Este documento se escribió **antes** de implementar y se revisó **después**. Las
secciones §1 a §5 se sostuvieron enteras: los números medidos el 26/08 (894 líneas de
base, 609 de denominador) se reprodujeron exactos. Lo que cambió:

| Sección | Cambio |
|---|---|
| §4.2 | La limpieza de `vibration` **no se hizo**: quedó excluida, no borrada (§4.4) |
| §6 | La tabla de aserciones se reemplazó por lo que efectivamente se escribió |
| §6.2 | **Nueva**: por qué el resultado es 98,4% con un target de 40% |
| §7 | El harness creció: tres helpers que el spec no anticipaba, todos forzados por el entorno |
| §7.1 | **Una de las dos limitaciones era falsa.** `SwLogo` no falla en silencio: falla el test (§7.2) |
| §8 | **Nueva**: dos hallazgos de la implementación — un bug del gate y un parámetro muerto |

El formato de §4.3 —registrar un diagnóstico equivocado en vez de borrarlo— se aplica
igual acá. Un spec que se corrige a sí mismo vale más que uno que parece haber acertado
siempre.

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

### 1.1 Baseline medido (2026-08-26, reproducido el 2026-09-02)

Medido con `melos bootstrap`, generando el archivo de imports de cobertura y corriendo
`flutter test --coverage --no-pub` sobre el package.

**Total: 6 / 894 líneas = 0,7%.**

Esa cifra coincide con la que registra `E8.2-ESTADO.md` §2 para `design_system`, lo que
confirma que 894 es el denominador que ve CI hoy. La medición se repitió el 02/09 en
otra máquina y otro sistema operativo (Windows, Flutter 3.44) y dio **exactamente los
mismos 6/894**, archivo por archivo.

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

- ✅ `design_system` ≥ 40% de cobertura de líneas, con el floor rachetado en CI.
  **Resultado: 98,4%, floor en 97.**
- ✅ Los tests cubren **comportamiento**: estado interno, callbacks y renderizado
  condicional. Nada de layout puro.
- ⬜ Sacar del package la dependencia muerta `vibration`, que hoy se resuelve y se
  registra como plugin sin que nadie la use (§4). **No se hizo: ver §4.4.**

## 3. No objetivos

- **No** se borran los 10 componentes de UI no referenciados. Se excluyen y se documenta
  por qué. SmartWarehouse es un repo compartido y puede haber ramas sin mergear que los
  usen. ~~La única excepción es `mixins/vibration.dart`, que sí se borra: ver §4.~~
  **Terminaron siendo 11 exclusiones y ningún borrado (§4.4).**
- **No** se testea layout: padding, spacing, radios, hex. Ese es el motivo explícito
  por el que el target es 40% y no 80% (#169).
- **No** golden tests.
- **No** se toca `bottom_navigation_bar` (#168).
- **No** se refactorea la familia legacy `Custom*` ni se migra `login` a la familia `Sw*`.

---

## 4. La dependencia muerta `vibration`

> **Esta sección se reescribió dos veces.** Una versión anterior la titulaba "hallazgo
> bloqueante" y afirmaba que el package no compilaba bajo test: ese diagnóstico era
> **incorrecto** (§4.3). La segunda versión decidía borrar el mixin; eso **tampoco
> pasó** (§4.4). Lo que se sostiene sin cambios es §4.1: la dependencia está muerta.

### 4.1 La dependencia está muerta en todo el monorepo

Verificado con `grep` sobre `lib/` y `packages/` completos, el 26/08 y de nuevo el 02/09:

| Hecho | Estado |
|---|---|
| Quién declara `vibration: ^2.0.0` | solo `packages/design_system/pubspec.yaml` |
| Quién importa `package:vibration` | solo `lib/mixins/vibration.dart` |
| Quién mixea `VibrationMixin` | **nadie**: se declara y no se usa |
| `hasVibration` de `PressableWidget` | se declara y **nunca se lee** — vestigio de la feature removida |

### 4.2 La decisión original: borrar, no excluir

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

### 4.4 Lo que efectivamente se hizo: excluir

`mixins/vibration.dart` quedó **excluido junto a los otros 10 huérfanos**, y la línea
`vibration: ^2.0.0` sigue en el pubspec.

El motivo es de proceso, no técnico: el borrado del archivo quedó bloqueado por el
control de permisos del entorno con el que se implementó #169, y la alternativa ya
estaba explícitamente autorizada por el propio §4.2 ("si se prefiere un diff 100%
test-only, excluirlo junto a los otros 10 es una alternativa válida"). Se tomó esa
salida en vez de frenar la fase entera por dos líneas.

**Sobre los números no tiene efecto**: el archivo sale del denominador de las dos
formas, y los 609 de §5.4 se confirmaron con la exclusión puesta.

**La deuda queda abierta y anotada** en el comentario del YAML. Sigue valiendo lo de
§4.2: la dependencia se resuelve en cada bootstrap y se registra como plugin de Android
e iOS para un mixin que nadie mixea. Son dos líneas y un archivo, con cero referencias
confirmadas por grep. Conviene cerrarla en un PR aparte, que además puede llevarse
`hasVibration` si se acepta el cambio de API.

---

## 5. Exclusiones

Las exclusiones van en el bloque `packages.design_system.exclude` de
`coverage_thresholds.yaml`, agrupadas y comentadas. El gate aplica los globs sobre
los registros `SF:` del lcov (`tool/coverage/lcov_parser.dart`), así que la exclusión
saca los archivos del denominador aunque queden instrumentados por transitividad.

> Ese "aplica los globs sobre los `SF:`" resultó ser cierto solo en Linux. Ver §8.1.

### 5.1 Archivos no referenciados (11 archivos, 221 líneas)

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
mixins/vibration.dart  (§4.4)
```

Son 31 archivos alcanzables (2.601 LOC) contra 11 huérfanos (643 LOC), 218 líneas
ejecutables de componentes de UI más 3 del mixin.

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

> Nota de la implementación: `smart_warehouse_text_styles.dart` **sí queda
> instrumentado** —`SmartWarehouseTheme` lo importa, así que entra al lcov por
> transitividad— y de hecho los tests lo cubren al 100%. La exclusión lo saca del
> denominador igual, que es lo que corresponde: sus 64 líneas cubiertas no son mérito
> de nadie.

### 5.3 Lo que **no** se excluye, aunque lo parezca

`theme/sw_tokens.dart` (11 LF) y `theme/theme_data/custom_text_styles.dart` (26 LF) se
leen como archivos de declaraciones, pero sus líneas ejecutables no son las constantes:
son los builders `SwText.display/body/label/mono` y `CustomTextStyles.lerp`. Los
ejercita cualquier test de widget real. Excluirlos sería inflar el porcentaje en la
dirección contraria.

Quedaron los dos al 100%, y `sw_tokens.dart` con tests propios: la conversión de
`letterSpacing` de ems a píxeles (`letterSpacing * size`) es lógica de verdad y no la
detecta ningún test de layout.

### 5.4 Denominador resultante — confirmado

| | Líneas |
|---|---|
| Denominador medido, todos los archivos (§1.1) | 894 |
| menos los 11 huérfanos de §5.1 | −221 |
| menos `smart_warehouse_text_styles.dart` de §5.2 | −64 |
| **Denominador del gate** | **609** |
| **40% ⇒ líneas a cubrir** | **244** |
| **Líneas efectivamente cubiertas** | **599 (98,4%)** |

El gate reportó `design_system 98.4% 599/609`, o sea que el denominador previsto el
26/08 dio exacto.

---

## 6. Qué se testeó

Comportamiento observable únicamente: qué callback se dispara, con qué argumento, y qué
se renderiza o deja de renderizarse según los inputs.

Se entregaron **25 archivos de test más el harness, y 371 casos**. El árbol de `test/`
espeja `lib/`.

| Componente | Aserciones | Cobertura |
|---|---|---|
| `CustomThemeExtension` | `lerp` en t=0/0,5/1 y `copyWith` sobre los **19 colores, uno por uno**; `of()` con y sin extension registrada; `lerp(null)` devuelve `this` | 48/48 |
| `CustomTextStyles` | `lerp` de los 19 estilos; `CustomTextStyle.lerp`; `of()` | 26/26 |
| `SwText` (`sw_tokens`) | `letterSpacing` en ems → píxeles en `display`/`body`/`mono`; `label` no escala; defaults | 11/11 |
| `SwButton` | callback; `isLoading` cambia label→spinner **y** bloquea el tap; opacidad 0,5 solo si está deshabilitado y no cargando; las tres variantes; borde solo en `secondary`; `compact`; icono | 33/33 |
| `SwIconButton` / `SwBadge` | callback; `tooltip ?? ''`; badge en 0 y negativo no renderiza; 99 entero, 100 → `99+` | 25/25 |
| `SwTextField` | el foco cambia el borde y agrega el anillo; `error` vacío **no** es error; el error le gana al foco; `obscure`; `prefix`/`suffix`; `trailingAction` sola monta la fila | 47/47 |
| `SwBottomNav` | `onTabSelected` reporta el `id` correcto **por tab**; reseleccionar el activo también reporta; color activo vs inactivo; badge 0 / 99 / 100; las keys de e2e | 34/35 |
| `SwImgPlaceholder` | `imageUrl` null o vacía → rayas; `errorBuilder` → rayas; `label` en mayúsculas; `_StripePainter.shouldRepaint` en las dos direcciones | 40/41 |
| `SwEmptyView` | los **cuatro** cruces del `&&` entre `ctaLabel` y `onCtaPressed`; el callback; variante `secondary` | 19/19 |
| `SwErrorView` | "Reintentar" invoca `onRetry` | 11/11 |
| `SwLoadingSkeleton` | el color cambia entre frames (el controller arranca); desmontar no filtra el `Ticker`; `.circle` fija `borderRadius = size / 2` | 25/25 |
| `SwCard` | `padding` null no envuelve; radio y sombra del design system | 6/7 |
| `SwLogo` / `SwLogoMark` | qué asset elige según `markOnly`; el label de `Semantics`; el size | 10/11 |
| `SwLoadingSpinner` | size, stroke y color; `value` null (indeterminado) | 9/9 |
| `CustomText` | el `assert` salta si `style` y `styleBuilder` son ambos null; `style` gana sobre `styleBuilder`; `useLineHeight: false` fuerza `height: 1`; `copyWith(color: null)` **no borra** | 10/10 |
| `PressableWidget` | `onPressed: null` ⇒ `onTap` null; `disabledColor`; el `borderRadius` va al `Material` **y** al `InkWell` | 15/15 |
| `CustomTextInput` | `_getStyle` en rojo con error; alto 56 vs 85; formatters de `number` y `phone` y el orden del spread; `prefixIcon` gana sobre `prefix`; `PercentageFormatter` completo | 56/58 |
| `PrimaryButton` / `BaseButtonTheme` | `isLoading` corta el `onPressed` y esconde los cuatro slots; precedencia `baseButtonTheme → textColor → theme`; `copyWith`; `secondary` engrosa a w700 | 61/62 |
| `CustomAppBar` | `canGoBack` con `NavigationHelper` mockeado; `onBackPressed` vs `popToPreviousRoute`; `autoImplyLeading`; `preferredSize` | 32/32 |
| `AccessLayout` | callbacks; el error llega al input; el bloque social está **oculto** a propósito | 30/30 |
| `CustomDialog` | padding; colores del tema; `show()` monta y respeta `barrierDismissible` | 14/14 |
| `CustomIcon` / `CustomCircularIcon` | el SVG inline monta sin excepción; `colorFilter` solo con `color` | 16/18 |
| `CustomSpacer` / `CustomSpace` | la escala es monótona; `height`/`width` independientes | 3/3 |
| `CustomTextSeparator` | dos divisores; `styleBuilder` propio | 9/9 |
| `E2eKeys` | los alias constantes coinciden con su generador; los ids no colisionan entre sí | 6/6 |

Quedaron sin cubrir **10 líneas**, repartidas de a una o dos en nueve archivos:
`custom_text_input` (2), y una en cada uno de `primary_button`, `sw_bottom_nav`,
`sw_img_placeholder`, `sw_logo`, `sw_card`, `custom_icon`, `custom_circular_icon` y
`custom_theme` (el `factory` del abstract, que nadie llama). Son ramas de error de
carga de imágenes y de callback que el entorno de test no puede provocar sin montar un
mock que valdría más que la línea que cubre.

### 6.1 Qué **no** se testea, a propósito

- Padding, spacing, radios, sombras, colores hardcodeados. Rompen con cada cambio de
  diseño y no detectan defectos: es la razón declarada del target de 40%.
- Los getters de `smart_warehouse_text_styles.dart` (§5.2).
- La familia huérfana de §5.1.

### 6.2 Por qué el resultado es 98,4% y no 40%

El target de 40% no estaba de más, y el resultado no lo contradice. La razón del target
bajo era **no fijar layout**, y esa restricción se respetó: no hay una sola aserción
sobre un padding, un radio o un hex en los 371 casos.

Lo que el spec no anticipó es la aritmética. Estos componentes son chicos, y sus líneas
ejecutables son casi todas el cuerpo del `build`. Montar un `SwButton` para afirmar que
`isLoading` bloquea el tap ejecuta, de arrastre, las 33 líneas del widget entero. La
cobertura de línea no distingue "lo ejercité para afirmar algo" de "pasó por ahí": el
98,4% es efecto de la métrica, no de haber testeado de más.

**El riesgo de leerlo al revés es real**: alguien puede concluir que el package está
"casi perfectamente testeado" y que un cambio de comportamiento va a ser detectado.
No es así. Lo que está protegido es lo que la tabla de §6 enumera. El resto de las
líneas está *ejecutado*, no *verificado*.

Esto también explica por qué el floor quedó en 97 y no en 40 (§10, decisión 6).

---

## 7. Estructura y harness

```
packages/design_system/test/
├── support/harness.dart
├── buttons/{sw_button,sw_icon_button,primary_button}_test.dart
├── dialog/custom_dialog_test.dart
├── icon/custom_icon_test.dart
├── indicators/sw_loading_spinner_test.dart
├── inputs/{sw_text_field,custom_text_input}_test.dart
├── layouts/access_layout_test.dart
├── navigation_bar/{sw_bottom_nav,custom_app_bar}_test.dart
├── testing/e2e_keys_test.dart
├── theme/{custom_theme_extension,custom_text_styles,sw_tokens}_test.dart
└── widgets/…                ← el árbol espeja lib/
```

`support/harness.dart` terminó con cinco piezas. Dos estaban previstas; tres las forzó
el entorno y ninguna es opcional:

| Helper | Por qué existe |
|---|---|
| `pumpDs` / `pumpBare` | Envuelven en `MaterialApp` con la `CustomThemeExtension` registrada, igual que `lib/application/application.dart`. `pumpBare` no agrega `Scaffold`, para `CustomDialog` y `CustomAppBar` |
| `initDsBinding()` | `TestWidgetsFlutterBinding.ensureInitialized()` + `allowRuntimeFetching = false`. Va como primera línea de `main()` en los archivos que arman estilos fuera de un `testWidgets` (§7.3) |
| `textStylesFixture(base)` | Una `CustomTextStyles` de `TextStyle` planos, con un `fontSize` distinto por campo (§7.3 y §7.4) |
| `TestAssetBundle` | Un `AssetBundle` que devuelve un PNG de 1×1 a cualquier clave, y un manifiesto vacío para `AssetManifest.bin` (§7.2) |
| `registerMock` / `resetInjector` | Tres líneas para el `Injector` global, que solo necesita `CustomAppBar` |

`mocktail` se usa en un solo archivo (`custom_app_bar_test.dart`, para
`NavigationHelper`); para el resto de los callbacks alcanza con closures que asientan en
una variable local. **Nada de esto va a `test_support`**: la regla vigente es que un
helper se comparte recién cuando lo necesitan ≥2 packages, y ese package ya arrastra de
más (ver "Partir `test_support`" en `E8.2-ESTADO.md` §3).

### 7.1 Las dos limitaciones que preveía el spec

> **La primera era falsa y la segunda era correcta.**

- ~~**`SwLogo`** llama `Image.asset('assets/images/sw_logo_full.png')`, pero el asset vive
  en el root de la app y `design_system/pubspec.yaml` no declara bloque
  `flutter: assets:`. Bajo test la carga falla en silencio en vez de tirar.~~
  **Falso: ver §7.2.**
- **`SwImgPlaceholder`** usa `Image.network`. El `HttpClient` por defecto de
  `flutter_test` responde 400, lo que dispara el `errorBuilder` — que es justamente una
  de las ramas a cubrir. No hace falta mockear la red. **Confirmado**: el test del
  fallback a rayas pasa sin un solo mock.

### 7.2 Corrección: `SwLogo` no falla en silencio, falla el test

El asset falta, eso era correcto. Lo que no es cierto es que la carga falle en silencio.
En Flutter 3.44 el image resource service reporta la excepción y **el caso de test
falla**:

```
══╡ EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE ╞═══
Unable to load asset: "assets/images/sw_logo_full.png".
The asset does not exist or has empty data.
```

La salida no es `tester.takeException()`: eso se tragaría también las excepciones que sí
importan. Los tests montan el widget bajo un `DefaultAssetBundle` con `TestAssetBundle`,
que responde un PNG de 1×1 válido. `Image.asset` resuelve el bundle vía
`DefaultAssetBundle.of(context)`, así que el widget se monta de verdad y se puede
afirmar **qué asset elige** — que es lo único que `SwLogo` realmente decide.

Un detalle que costó un ciclo: `AssetImage.obtainKey` **primero** pide
`AssetManifest.bin` para resolver variantes por densidad. Devolverle el PNG rompe el
decoder del manifiesto antes de llegar a la imagen. `TestAssetBundle` devuelve un mapa
vacío codificado con `StandardMessageCodec` para esa clave, que significa "sin
variantes".

### 7.3 `google_fonts` hace `rethrow`, y eso decide la forma de los tests

`allowRuntimeFetching = false` no silencia a `google_fonts`: lo hace tirar. En el `else`
de `loadFontIfNecessary` (google_fonts 6.3.3, `src/google_fonts_base.dart`) la ausencia
de la fuente en los assets es un `throw Exception(...)`, y el `catch` que lo atrapa
**imprime y hace `rethrow`**. Como ningún llamador awaitea ese future, queda un error
asincrónico sin dueño.

De ahí salen dos reglas del harness, las dos con consecuencias visibles:

1. **Los helpers de `SwText` se testean con `testWidgets`, no con `test`.** Son cuatro
   funciones puras que devuelven un `TextStyle` y no tocan el árbol, así que la
   tentación de usar `test` es fuerte. Dentro de un `test`, package:test atribuye el
   error asincrónico al caso y lo marca fallado; dentro de un `testWidgets` el binding
   lo absorbe. Convertirlos "porque no usan el tester" rompe los once casos. Está
   documentado en el encabezado de `sw_tokens_test.dart`.
2. **`SmartWarehouseTextStyles` no se construye en el cuerpo de `main()`.** Resuelve sus
   19 estilos con `google_fonts` en el constructor, así que un
   `final styles = SmartWarehouseTextStyles()` a nivel de `main()` hace que el archivo
   entero **no llegue ni a cargar**. Para eso está `textStylesFixture`.

### 7.4 Por qué las fixtures tienen un valor distinto por campo

`CustomThemeExtension.copyWith`, `CustomThemeExtension.lerp` y `CustomTextStyles.lerp`
son tres listas de 19 líneas casi idénticas escritas a mano. El modo de falla real no es
que la interpolación esté mal: es el **cross-wiring**, una línea del tipo
`gray300: Color.lerp(gray300, other.white300, t)`.

Con una paleta uniforme ese bug es invisible. Por eso `textStylesFixture(base)` y el
helper `_ext(base)` dan un valor distinto a cada campo, y los tests recorren los 19 uno
por uno: `copyWith(gray:)` tiene que pisar `gray` **y dejar los otros 18 intactos**, y
`lerp` tiene que interpolar cada campo contra su propio par. Son 100 de los 371 casos, y
es donde está la mayor parte del valor del archivo de theme.

---

## 8. Hallazgos de la implementación

Dos cosas que aparecieron al implementar y que no son parte del alcance de #169, pero que
alguien tiene que decidir.

### 8.1 El gate de cobertura estaba roto en Windows

`parseLcov` guardaba el path del `SF:` tal cual venía. En Windows,
`flutter test --coverage` los emite con separador `\` (`SF:lib\theme\sw_tokens.dart`),
y los globs de `coverage_thresholds.yaml` están escritos con `/`. Resultado:
**ninguna exclusión matcheaba**, en silencio.

No es un problema de `design_system`: es de todo el gate. Con los paths sin normalizar,
la corrida local daba

| Package | Reportaba | Floor | |
|---|---|---|---|
| `commons` | 43,0% | 85 | FAIL |
| `cart` | 53,3% | 89 | FAIL |
| `catalog` | 29,7% | 42 | FAIL |
| `login` | 9,3% | 13 | FAIL |
| `orders` | 20,6% | 23 | FAIL |
| `order_tracking` | 24,0% | 32 | FAIL |

Todos por la exclusión `**/presentation/pages/**`, que nunca aplicaba. CI no lo detectó
nunca porque corre en Ubuntu, donde los separadores ya vienen bien.

El arreglo es una línea en `tool/coverage/lcov_parser.dart` —normalizar `\` a `/` al
parsear el `SF:`— más un caso de regresión en `test/tool/lcov_parser_test.dart`. En
Linux no cambia absolutamente nada.

**Es tooling de la Fase 0 (#130), no de #169.** Se hizo acá porque sin eso no se podía
verificar el criterio de aceptación en la máquina donde se implementó. Puede salir en su
propio PR.

### 8.2 `CustomTextInput.onChanged` es un parámetro muerto

`onChanged` se declara en el constructor (línea 22) y como campo (línea 44), y **no se
cablea al `TextFormField` en ningún lado**. Un feature que lo pase no recibe nada, y el
analyzer no dice una palabra porque el campo "se usa" al declararse.

Es el mismo patrón que `hasVibration` de `PressableWidget` (§4.1): API que promete algo
que no hace.

Se documentó con un test que fija el comportamiento actual —`onChanged` nunca se
llama— en vez de arreglarlo, porque cablearlo cambia el comportamiento de una API
pública del design system y #169 es un issue de tests. El test lleva el comentario
explicando que **no es el comportamiento deseado, es el que hay**, y que el día que
alguien lo conecte ese caso va a fallar: que es exactamente la señal que se busca.

---

## 9. Entrega

Lo que efectivamente pasó, contra lo que preveía el plan:

1. Rama `feature/e8.2-phase3-design-system` sobre `develop`. **El spec ya había
   mergeado como #189**, así que la rama se rebaseó sobre `origin/develop` y su commit
   original quedó descartado por duplicado.
2. `melos bootstrap` — con `dart run melos`, para usar el 6.3.3 que pinea el pubspec y
   que es el que activa CI, en vez del global.
3. ~~Commit de limpieza aislado: borrar `lib/mixins/vibration.dart` y la línea del
   pubspec.~~ **No se hizo (§4.4).** Quedan solo las exclusiones comentadas en
   `coverage_thresholds.yaml`, y el diff es 100% test-only salvo por §8.1.
4. El harness, y después los tests, agrupados por componente.
5. ~~`melos run test:coverage` en verde.~~ **No corre en Windows**: el script empieza con
   `set -e` y melos lo pasa por `cmd.exe`, que responde
   `ERROR: Environment variable -e not defined`. Se corrieron los tres pasos a mano
   —`gen_coverage_imports.dart`, `flutter test --coverage --no-pub` por package,
   `check_coverage.dart`— con el mismo resultado. **12 packages en verde**, `profile`
   con exit 79 (sin tests), que es el caso tolerado por `package_coverage.sh`.
6. Floor rachetado de 0 a 97 (medido 98,4%, menos un punto de margen), en su propio
   commit para que el salto del umbral sea un diff revisable por sí mismo.

`flutter analyze` limpio en `design_system` y en el root.

### 9.1 Criterio de aceptación — cumplido

`design_system` **98,4%** ≥ 40%, floor rachetado a 97, sin tests de layout puro, y el
gate pasando de punta a punta sobre los 12 packages.

---

## 10. Decisiones tomadas

Se registran acá con su costo si estuvieron mal, siguiendo el formato de
`E8.2-ESTADO.md` §6.

| # | Decisión | Costo si estuvo mal |
|---|---|---|
| 1 | Excluir los huérfanos en vez de borrarlos | Quedan 635 LOC muertas en el repo, anotadas pero no removidas |
| 1b | ~~Borrar `mixins/vibration.dart` y `vibration: ^2.0.0`~~ → **excluirlos** (§4.4) | La dependencia muerta sigue en el grafo: se resuelve en cada bootstrap y se registra como plugin de Android e iOS. La deuda queda anotada en el YAML |
| 2 | Excluir `smart_warehouse_text_styles.dart` del denominador | El 98,4% no es comparable con el baseline del spec original; hay que leer §5.4 para reconstruirlo |
| 3 | **No** excluir `sw_tokens.dart` ni `custom_text_styles.dart` pese a parecer declarativos | Salió bien: los dos quedaron al 100% y `sw_tokens` tiene tests propios de la conversión ems→píxeles |
| 4 | Harness propio en `design_system/test/support/` en vez de `test_support` | Si `bottom_navigation_bar` (#168) necesita el mismo `pumpDs`, hay que promoverlo — una mudanza de un archivo. Nota: `TestAssetBundle` y `initDsBinding` son candidatos reales a compartirse |
| 5 | Medir primero con `flutter pub get` en vez de `melos bootstrap` | **Costó de verdad**: produjo el diagnóstico equivocado de §4.3, que se propagó al spec y a una decisión ya tomada hasta que se verificó contra el workspace bootstrapeado |
| 6 | Rachetear el floor a 97 y no dejarlo en 40 | Un componente nuevo sin tests hace fallar el gate aunque el package siga muy por encima del target de #169. Es el ratchet funcionando como está definido (§7.2 del spec original), y el precedente de #168 es el mismo (80,4% medido → floor 79 contra un target de 60) |
| 7 | Arreglar el bug de separadores del lcov (§8.1) dentro de este PR | Mezcla tooling de Fase 0 con tests de Fase 3. Se puede sacar a su propio PR; sin el arreglo, el criterio de aceptación no era verificable fuera de Linux |
| 8 | Documentar `onChanged` muerto con un test en vez de cablearlo (§8.2) | El parámetro sigue mintiendo. Si alguien lo conecta, el test falla y hay que borrarlo — que es la señal buscada, no un falso positivo |
| 9 | Usar `testWidgets` para funciones puras que tocan `google_fonts` (§7.3) | Se lee como un error y alguien lo va a "corregir". Mitigado con el comentario del encabezado de `sw_tokens_test.dart` |
