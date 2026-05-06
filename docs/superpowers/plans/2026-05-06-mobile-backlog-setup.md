# Mobile Backlog Setup — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Materializar en GitHub el backlog completo del Sprint 1 (catálogo + carrito + crear orden, mockeado) para la App Mobile del proyecto SmartWarehouse: 9 épicas, ~43 subtareas, 5-column project board, taxonomía de labels, reorganización de las 7 issues existentes.

**Architecture:** Issues nativas de GitHub con jerarquía épica → subtareas vía task lists con checkboxes (referencias `- [ ] #N`) en el body de la épica. Project board v2 con columnas custom vía GraphQL. Labels para prioridad/área/sprint/tipo. Las 7 issues existentes se reusan editándolas (preserva número y referencias).

**Tech Stack:** GitHub CLI (`gh`), GitHub REST API (`gh api`), GitHub GraphQL API (`gh api graphql`).

**Repo:** `enricotonelli/SmartWarehouse`

---

## Pre-flight: convenciones del plan

- Todas las issues en GitHub se crean con `gh issue create` y devuelven una URL con el número de issue al final (ej: `https://github.com/enricotonelli/SmartWarehouse/issues/15`). El ejecutor debe **anotar el número devuelto** después de cada creación porque las épicas necesitan referenciar a sus subtareas por número.
- Los bodies multilinea se pasan via heredoc para preservar formato.
- Cuando el plan dice "anotar como `#XX`", el ejecutor reemplaza `XX` por el número real al ejecutar.
- Comandos largos están todos en un solo `gh` call con backslashes para legibilidad.

---

## Task 1: Verify GitHub auth scopes

**Files:** N/A (operación remota)

- [ ] **Step 1.1: Check current gh auth scopes**

Run:
```bash
gh auth status
```

Expected: que liste los scopes actuales. Si NO aparecen `read:project` y `project` en la lista, ir al Step 1.2. Si ya aparecen, saltar al Task 2.

- [ ] **Step 1.2: Refresh auth con scopes de project (solo si faltan)**

Run:
```bash
gh auth refresh -s read:project,project
```

Sigue las instrucciones interactivas (abre browser, código de verificación). Volver a correr `gh auth status` después y verificar que los scopes nuevos aparezcan.

---

## Task 2: Create label taxonomy

**Files:** N/A

Creamos 16 labels nuevos en el repo. Si alguno ya existe, `gh` devuelve error — ignorarlo y continuar.

- [ ] **Step 2.1: Priority labels**

```bash
gh label create "priority:P0" --repo enricotonelli/SmartWarehouse --color "B60205" --description "Crítico - bloquea otras tareas"
gh label create "priority:P1" --repo enricotonelli/SmartWarehouse --color "D93F0B" --description "Importante - sprint actual"
gh label create "priority:P2" --repo enricotonelli/SmartWarehouse --color "FBCA04" --description "Nice to have"
```

- [ ] **Step 2.2: Area labels**

```bash
gh label create "area:contracts" --repo enricotonelli/SmartWarehouse --color "1D76DB" --description "Contratos API/JSON con backend"
gh label create "area:auth" --repo enricotonelli/SmartWarehouse --color "1D76DB" --description "Login, auth, tokens"
gh label create "area:catalog" --repo enricotonelli/SmartWarehouse --color "1D76DB" --description "Catálogo de productos"
gh label create "area:cart" --repo enricotonelli/SmartWarehouse --color "1D76DB" --description "Carrito de compras"
gh label create "area:orders" --repo enricotonelli/SmartWarehouse --color "1D76DB" --description "Órdenes y seguimiento"
gh label create "area:ux" --repo enricotonelli/SmartWarehouse --color "1D76DB" --description "UX cross-cutting, navegación"
gh label create "area:qa" --repo enricotonelli/SmartWarehouse --color "1D76DB" --description "Testing y calidad"
```

- [ ] **Step 2.3: Sprint labels**

```bash
gh label create "sprint:1" --repo enricotonelli/SmartWarehouse --color "0E8A16" --description "Sprint 1: 06/05 - 13/05"
gh label create "sprint:2" --repo enricotonelli/SmartWarehouse --color "0E8A16" --description "Sprint 2: 13/05 - 27/05"
gh label create "sprint:3" --repo enricotonelli/SmartWarehouse --color "0E8A16" --description "Sprint 3: 27/05 - 17/06"
```

- [ ] **Step 2.4: Misc labels**

```bash
gh label create "type:epic" --repo enricotonelli/SmartWarehouse --color "5319E7" --description "Issue padre que agrupa subtareas"
gh label create "blocked" --repo enricotonelli/SmartWarehouse --color "000000" --description "Tiene dependencias sin resolver"
gh label create "mock" --repo enricotonelli/SmartWarehouse --color "C5DEF5" --description "Implementación mockeada"
gh label create "real" --repo enricotonelli/SmartWarehouse --color "C5DEF5" --description "Implementación contra backend real"
```

- [ ] **Step 2.5: Verify labels**

```bash
gh label list --repo enricotonelli/SmartWarehouse | grep -E "priority:|area:|sprint:|type:|blocked|mock|real"
```

Expected: ver los 16 labels listados.

---

## Task 3: Reorganize existing issue #1 → become E1 epic

**Files:** N/A

Issue #1 actual: "Definición de contratos (Frontend ↔ Backend)". La convertimos en la épica E1 con body completo y labels. **Mantenemos el número #1.**

- [ ] **Step 3.1: Update issue #1**

```bash
gh issue edit 1 --repo enricotonelli/SmartWarehouse \
  --title "[E1] API Contracts & Coordinación con Backend" \
  --add-label "type:epic,priority:P0,area:contracts,sprint:1" \
  --body "$(cat <<'EOF'
## Goal

Definir y documentar los contratos JSON entre App Mobile y Backend para que ambos grupos puedan trabajar en paralelo sin bloquearse.

## Scope Sprint 1

Solo lo necesario para mockear catálogo + crear orden:
- Schema de Product
- Schema de Order + OrderItem
- Enum de OrderStatus
- Documentación en repo (\`docs/contracts/\`)

## Scope Sprint 2 (placeholder)

Endpoints REST, contratos de auth/JWT, formalizar envelope WebSocket. Bloqueado hasta que el backend entregue secciones 1-3 de su documento.

## Backend constraints conocidos

- Convención: **snake_case** en todos los campos JSON
- WebSocket: \`ws://<host>/ws?token=<JWT>\` (JWT en query string)
- Eventos WS conocidos: \`connected\`, \`order.updated\`, \`vehicle.updated\`, \`vehicle.error\`, \`stock.alert\`
- Backend NO replay-ea eventos perdidos en reconexión → cliente debe REST-fetch estado al reconectar

## Subtareas Sprint 1

(Se completa este checklist con los números de las subtareas creadas en Task 7)

- [ ] E1.1 Definir JSON schema de Product
- [ ] E1.2 Definir JSON schema de Order + OrderItem
- [ ] E1.3 Definir enum de OrderStatus
- [ ] E1.4 Documentar contratos en docs/contracts/
- [ ] E1.5 Documentar decisiones tomadas

## Definition of Done

- Existe \`docs/contracts/product.md\`, \`docs/contracts/order.md\`, \`docs/contracts/README.md\`
- Mobile y Backend acordaron los schemas (revisión cruzada)
- Mobile puede usar los schemas para escribir sus modelos en E3 y E4
EOF
)"
```

---

## Task 4: Reorganize existing issue #2 → become E3 epic

**Files:** N/A

- [ ] **Step 4.1: Update issue #2**

```bash
gh issue edit 2 --repo enricotonelli/SmartWarehouse \
  --title "[E3] Catálogo de Productos" \
  --add-label "type:epic,priority:P0,area:catalog,sprint:1,mock" \
  --body "$(cat <<'EOF'
## Goal

Pantalla de catálogo de productos con datos mockeados (sin backend real). Permite al usuario navegar productos, buscar, filtrar por categoría y ver detalle.

## Scope Sprint 1 (mock)

UI completa funcionando con \`MockCatalogRepository\` con ~10 productos hardcodeados.

## Scope Sprint 2 (real)

Reemplazar mock por \`RemoteCatalogRepository\` consumiendo \`GET /products\` cuando el backend exponga el endpoint.

## Bloqueada por

- E1 (subset Product) — necesita schema de Product cerrado para escribir el modelo

## Bloquea a

- E4 (Carrito) — el botón "Agregar al carrito" sale del detalle de producto

## Subtareas Sprint 1

(Se completa con números reales en Task 8)

- [ ] E3.1 Setup feature package catalog
- [ ] E3.2 Domain: modelos Product y Category
- [ ] E3.3 Domain: interface CatalogRepository
- [ ] E3.4 Data: MockCatalogRepository
- [ ] E3.5 Presentation: CatalogCubit
- [ ] E3.6 UI: widget ProductCard
- [ ] E3.7 UI: CatalogPage con lista
- [ ] E3.8 UI: estados vacío/error/loading
- [ ] E3.9 UI: search bar
- [ ] E3.10 UI: filtros de categoría
- [ ] E3.11 UI: ProductDetailPage
- [ ] E3.12 Routing Beamer
- [ ] E3.13 Wire-up bottom nav

## Definition of Done

- App muestra catálogo con 10 productos mock
- Búsqueda por nombre y SKU funciona
- Filtro por categoría funciona
- Detalle de producto muestra info completa
- Estados de loading/error/vacío implementados
- Tab "Productos" en bottom nav navega al catálogo
EOF
)"
```

---

## Task 5: Reorganize existing issue #3 → become E4 epic

**Files:** N/A

- [ ] **Step 5.1: Update issue #3**

```bash
gh issue edit 3 --repo enricotonelli/SmartWarehouse \
  --title "[E4] Carrito y Creación de Orden" \
  --add-label "type:epic,priority:P0,area:cart,sprint:1,mock,blocked" \
  --body "$(cat <<'EOF'
## Goal

Permitir al usuario armar un carrito agregando productos del catálogo, editar cantidades, y crear una orden (mockeada, sin enviar al backend real todavía).

## Scope Sprint 1 (mock)

- Carrito en memoria (no persiste entre sesiones)
- Orden creada vía \`MockOrderRepository\` que devuelve un \`Order\` con id generado y \`status: pending\`
- Pantalla de éxito con ID de orden

## Scope Sprint 2 (real)

\`RemoteOrderRepository\` consumiendo \`POST /orders\` cuando backend lo exponga.

## Bloqueada por

- **E3.4** \`MockCatalogRepository\` — el carrito necesita productos para agregar
- **E3.11** \`ProductDetailPage\` — el botón "Agregar al carrito" vive ahí

## Bloquea a

- E5 (Seguimiento de Órdenes) — necesita órdenes creadas para mostrar

## Subtareas Sprint 1

(Se completa con números reales en Task 9)

- [ ] E4.1 Setup feature package cart
- [ ] E4.2 Setup feature package orders
- [ ] E4.3 Domain: modelos Cart, CartItem, Order, OrderItem, OrderStatus
- [ ] E4.4 Domain: interfaces CartRepository + OrderRepository
- [ ] E4.5 Data: InMemoryCartRepository
- [ ] E4.6 Data: MockOrderRepository
- [ ] E4.7 Presentation: CartCubit
- [ ] E4.8 Presentation: CreateOrderCubit
- [ ] E4.9 UI: botón "Agregar al carrito" en ProductDetailPage
- [ ] E4.10 UI: CartPage
- [ ] E4.11 UI: stepper de cantidad
- [ ] E4.12 UI: validaciones (qty > 0, qty ≤ stock)
- [ ] E4.13 UI: footer con total + botón "Crear orden"
- [ ] E4.14 UI: CreateOrderConfirmationDialog
- [ ] E4.15 UI: OrderSuccessPage
- [ ] E4.16 UI: manejo de error de submit
- [ ] E4.17 Routing
- [ ] E4.18 Wire-up: badge en bottom nav

## Definition of Done

- Usuario puede agregar productos al carrito desde el detalle
- Puede editar cantidades y eliminar items
- Validaciones de qty funcionando
- Submit crea orden con id y muestra pantalla de éxito
- Manejo de error con retry
- Badge en bottom nav muestra cantidad de items
EOF
)"
```

---

## Task 6: Reorganize remaining existing issues

**Files:** N/A

- [ ] **Step 6.1: Update issue #6 → E7 epic**

```bash
gh issue edit 6 --repo enricotonelli/SmartWarehouse \
  --title "[E7] UX Cross-cutting" \
  --add-label "type:epic,priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
## Goal

Componentes y configuración UX/navegación reusables que necesitan E3 y E4 para funcionar en Sprint 1.

## Scope Sprint 1

- Widgets reusables en design_system: loading, error, empty
- Setup completo de Beamer routing
- Bypass del auth gate (entrar directo al catálogo)
- BottomNavigationScaffold configurado

## Scope Sprint 2/3

- Manejo de offline robusto
- Animaciones de transición
- Pulido visual general

## Subtareas Sprint 1

(Se completa con números reales en Task 10)

- [ ] E7.1 LoadingSpinner widget
- [ ] E7.2 LoadingSkeleton widget
- [ ] E7.3 ErrorView widget con retry
- [ ] E7.4 EmptyView widget
- [ ] E7.5 Setup Beamer routing root
- [ ] E7.6 Bypass de auth gate en main.dart
- [ ] E7.7 Configurar BottomNavigationScaffold

## Definition of Done

- Widgets reusables funcionando y usados en E3/E4
- App arranca y va directo al catálogo (sin login)
- Navegación entre tabs funciona
EOF
)"
```

- [ ] **Step 6.2: Update issue #7 → E8 epic**

```bash
gh issue edit 7 --repo enricotonelli/SmartWarehouse \
  --title "[E8] Testing & QA" \
  --add-label "type:epic,priority:P1,area:qa,sprint:3" \
  --body "$(cat <<'EOF'
## Goal

Asegurar calidad funcional y técnica antes de la demo del Hito 2.

## Scope Sprint 1

Mínimo: validaciones de formularios funcionando.

## Scope Sprint 3 (foco principal)

- Tests unitarios de cubits críticos (CatalogCubit, CartCubit, CreateOrderCubit)
- Widget tests de pantallas principales
- Tests de integración con mocks
- QA manual end-to-end del flujo completo
- Build APK final para demo

## Subtareas

A detallar antes de Sprint 3 (27/05).

## Definition of Done

- Cobertura de tests acordada con el equipo
- Build APK de demo generado
- Checklist QA manual ejecutado
EOF
)"
```

- [ ] **Step 6.3: Close issue #4 (mergeada en E3.real / E4.real)**

```bash
gh issue close 4 --repo enricotonelli/SmartWarehouse \
  --comment "Cerrada al reorganizar el backlog. El contenido (configuración HTTP, endpoints REST, manejo de errores global) se reparte entre las subtareas de Sprint 2 dentro de E3 (RemoteCatalogRepository) y E4 (RemoteOrderRepository), más E1.6 (contratos REST). Ver design doc: docs/superpowers/specs/2026-05-06-mobile-backlog-design.md"
```

- [ ] **Step 6.4: Close issue #8 (consolidada en E1.5)**

```bash
gh issue close 8 --repo enricotonelli/SmartWarehouse \
  --comment "Cerrada al reorganizar el backlog. Las preguntas y respuestas para el backend se documentan ahora como parte de E1.5 (Documentar decisiones tomadas) dentro de docs/contracts/README.md."
```

---

## Task 7: Create E0 (Initial Setup) — closed

**Files:** N/A

- [ ] **Step 7.1: Create issue and capture number**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "[E0] Initial Project Setup" \
  --label "type:epic" \
  --body "$(cat <<'EOF'
## Summary

Setup base del proyecto Flutter con arquitectura modular completado y mergeado en \`main\`.

## Done

- Melos workspace configurado
- Packages base: \`commons\`, \`core\`, \`design_system\`
- IoC manager y \`EnvironmentConfig\`
- Routing con Beamer
- State management con flutter_bloc
- Splash screen (flutter_native_splash)
- Scaffold de features: \`auth\`, \`login\`, \`bottom_navigation_bar\`
- \`token_repository\` con persistencia local
- Fonts (Satoshi) y assets configurados

## Referencias

- PR #9: base project structure with modular architecture
- Commit \`c51ea3b\`: fix base config

## Status

✅ Completado y mergeado a \`main\`. Esta issue se cierra inmediatamente al crearse — sirve como registro histórico en el project board (columna Done).
EOF
)"
```

Anotar el número devuelto como `E0_NUM` (ejemplo: `9`, `10`, etc).

- [ ] **Step 7.2: Close E0 immediately**

Reemplazar `<E0_NUM>` por el número del paso anterior:

```bash
gh issue close <E0_NUM> --repo enricotonelli/SmartWarehouse \
  --comment "Setup base completado en PR #9 + commit c51ea3b. Cerrada para que aparezca en columna Done del project board."
```

---

## Task 8: Create new epics E2, E5, E6

**Files:** N/A

- [ ] **Step 8.1: Create E2 (Login)**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "[E2] Login" \
  --label "type:epic,priority:P0,area:auth,sprint:2" \
  --body "$(cat <<'EOF'
## Goal

Pantalla de login funcional con autenticación contra el backend, persistencia de JWT, y gating de la app (solo usuarios logueados pueden acceder).

## Scope Sprint 2

- UI completa de login (email + password)
- Validación de formato de email y password no vacío
- Integración con endpoint REST real del backend (cuando esté disponible)
- Persistencia de JWT en \`token_repository\`
- Manejo de errores: credenciales inválidas (401), timeout, red caída
- Auth guard real en routing (reemplaza el bypass del Sprint 1)

## Bloqueada por

- E1.7 contrato de auth/JWT (pendiente del backend)

## Bloquea a

- E5 (suscripción WS necesita JWT)
- E6 (Forgot Password)

## Subtareas

A detallar antes del Sprint 2 (semana del 13/05). Posibles subtareas: setup repository remoto, presentation cubit, UI de pantalla, validaciones, manejo de errores, integración con token_repository, auth guard.

## Definition of Done

- Login con credenciales válidas redirige al catálogo y persiste sesión
- Reintento de login después de cerrar app → sesión persistida
- Manejo de errores con mensajes claros
- Logout funcional
EOF
)"
```

Anotar como `E2_NUM`.

- [ ] **Step 8.2: Create E5 (Order Tracking)**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "[E5] Seguimiento de Órdenes" \
  --label "type:epic,priority:P1,area:orders,sprint:2,blocked" \
  --body "$(cat <<'EOF'
## Goal

Lista de órdenes del usuario y detalle de orden con estado actualizado en tiempo real vía WebSocket.

## Scope Sprint 2

- Lista de órdenes del usuario (REST GET inicial)
- Detalle de orden con timeline de estados
- Suscripción WebSocket al evento \`order.updated\`
- REST fetch del estado al conectar/reconectar (siguiendo guideline del backend)
- Pull-to-refresh en lista

## Scope Sprint 3

- \`vehicle.updated\` en detalle (posición rover, batería)
- \`stock.alert\` opcional en catálogo

## Bloqueada por

- E2 (necesita JWT autenticado para conectarse al WS)
- E4 (necesita órdenes creadas para mostrar)
- E1.7 (contrato WebSocket)

## Subtareas

A detallar antes del Sprint 2. Posibles: cliente WS con auth, suscripción a eventos, OrderListPage, OrderDetailPage con timeline, manejo de reconexión.

## Definition of Done

- Usuario ve lista de sus órdenes ordenadas por fecha
- Estado cambia en tiempo real cuando backend emite \`order.updated\`
- Reconexión transparente al perder señal
EOF
)"
```

Anotar como `E5_NUM`.

- [ ] **Step 8.3: Create E6 (Forgot Password)**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "[E6] Olvidé mi Contraseña" \
  --label "type:epic,priority:P2,area:auth,sprint:3" \
  --body "$(cat <<'EOF'
## Goal

Flujo de recuperación de contraseña vía email para usuarios que olvidaron sus credenciales.

## Scope Sprint 3

- Link "Olvidé mi contraseña" en pantalla de login
- Pantalla "Ingresá tu email"
- Llamada a endpoint de request reset
- Pantalla de confirmación "Te enviamos un email"
- (Opcional) deep link para abrir reset desde email

## Bloqueada por

- E2 (necesita pantalla de login lista)
- Endpoint de request reset del backend (parte de E1.6)

## Subtareas

A detallar antes del Sprint 3.

## Definition of Done

- Usuario puede iniciar el flujo desde login
- Backend confirma envío de email
- UI maneja errores (email no registrado, etc.)
EOF
)"
```

Anotar como `E6_NUM`.

---

## Task 9: Create E1 subtasks (Sprint 1)

**Files:** N/A

Crear las 5 subtareas de E1 y anotar sus números (`E1_1_NUM` ... `E1_5_NUM`). Después actualizar el body de la épica #1 para checkear los números reales.

- [ ] **Step 9.1: Create E1.1 — JSON schema Product**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E1.1: Definir JSON schema de Product" \
  --label "priority:P0,area:contracts,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #1

## Tarea

Definir el formato JSON exacto del recurso \`Product\` que va a consumir la app, basado en la convención \`snake_case\` que usa el backend.

## Campos propuestos

\`\`\`json
{
  \"id\": \"PROD-001\",
  \"sku\": \"SKU-ABC-123\",
  \"name\": \"Tornillo M8 50mm\",
  \"description\": \"Tornillo hexagonal acero inoxidable\",
  \"category\": \"hardware\",
  \"stock\": 145,
  \"image_url\": \"https://example.com/img/prod-001.jpg\",
  \"price\": 12.50
}
\`\`\`

## Acceptance criteria

- [ ] Lista completa de campos definida
- [ ] Tipos especificados (string, integer, float, etc.)
- [ ] Cuáles son required vs optional
- [ ] Ejemplo JSON válido en \`docs/contracts/product.md\` (creado en E1.4)
- [ ] Acordado con backend (Grupo 4) — comentario de OK en esta issue

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 9.2: Create E1.2 — JSON schema Order + OrderItem**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E1.2: Definir JSON schema de Order + OrderItem" \
  --label "priority:P0,area:contracts,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #1

## Tarea

Formalizar el schema de Order tomando como base el ejemplo del doc de Grupo 2.

## Campos propuestos

\`\`\`json
{
  \"order_id\": \"ORD-1001\",
  \"timestamp\": \"2026-05-06T15:00:00Z\",
  \"requested_by_user\": \"USR-001\",
  \"status\": \"pending\",
  \"assigned_vehicle_id\": null,
  \"items\": [
    {
      \"product_id\": \"PROD-001\",
      \"sku\": \"SKU-ABC-123\",
      \"quantity\": 10
    }
  ]
}
\`\`\`

## Acceptance criteria

- [ ] Schema de Order formalizado
- [ ] Schema de OrderItem formalizado
- [ ] Tipos y required/optional definidos
- [ ] Ejemplo JSON en \`docs/contracts/order.md\`
- [ ] Acordado con backend

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 9.3: Create E1.3 — Enum OrderStatus**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E1.3: Definir enum de OrderStatus" \
  --label "priority:P0,area:contracts,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #1

## Tarea

Lista cerrada de estados que puede tomar una orden, basada en los estados que mencionaba el doc de Grupo 2.

## Estados propuestos

- \`pending\` — creada, sin asignar
- \`assigned\` — asignada a un vehículo
- \`in_progress\` — en ejecución
- \`picked_up\` — producto recogido por el rover
- \`delivering\` — en camino a entrega
- \`delivered\` — completada
- \`failed\` — falló (por error de rover, stock insuficiente, etc.)

## Acceptance criteria

- [ ] Lista cerrada de estados
- [ ] Transiciones válidas documentadas (ej: pending → assigned → in_progress, etc.)
- [ ] Acordado con backend
- [ ] Documentado en \`docs/contracts/order.md\`

## Estimado

~2hs
EOF
)"
```

- [ ] **Step 9.4: Create E1.4 — Documentar contratos**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E1.4: Crear docs/contracts/ con product.md, order.md, README.md" \
  --label "priority:P0,area:contracts,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #1

## Tarea

Materializar las decisiones de E1.1, E1.2, E1.3 en archivos Markdown commiteados al repo, en \`docs/contracts/\`.

## Files to create

- \`docs/contracts/README.md\` — índice + decisiones cross-cutting
- \`docs/contracts/product.md\` — schema completo + ejemplo
- \`docs/contracts/order.md\` — schema + ejemplo + estados

## Acceptance criteria

- [ ] Tres archivos creados
- [ ] Ejemplos JSON renderizan bien en GitHub
- [ ] README explica convenciones (snake_case, etc.)
- [ ] PR mergeado a main

## Bloqueada por

- E1.1, E1.2, E1.3

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 9.5: Create E1.5 — Documentar decisiones**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E1.5: Documentar decisiones tomadas con backend" \
  --label "priority:P0,area:contracts,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #1

## Tarea

Capturar decisiones cross-cutting acordadas con el backend que no son schemas pero impactan la implementación. Incluye respuestas a las preguntas que estaban en la issue #8.

## Decisiones a capturar

- snake_case en todos los campos JSON
- JWT en query string para WebSocket: \`ws://<host>/ws?token=<JWT>\`
- Backend NO replay-ea eventos perdidos en reconexión → cliente debe REST-fetch al reconectar
- Polling vs WebSocket: WS confirmado para tiempo real
- Notificaciones push: TBD (probable que NO para Hito 2)

## Acceptance criteria

- [ ] Sección \"Decisiones\" en \`docs/contracts/README.md\` con todos los puntos
- [ ] Cada decisión linkeada a la conversación/issue donde se acordó

## Bloqueada por

- E1.4 (los archivos donde se documenta)

## Estimado

~3hs
EOF
)"
```

- [ ] **Step 9.6: Update E1 epic body with real numbers**

Reemplazar `<E1_1_NUM>` etc. con los números devueltos en los pasos anteriores. Re-emitir el body de la épica con los checkboxes referenciando issues reales:

```bash
gh issue edit 1 --repo enricotonelli/SmartWarehouse \
  --body "$(cat <<EOF
## Goal

Definir y documentar los contratos JSON entre App Mobile y Backend para que ambos grupos puedan trabajar en paralelo sin bloquearse.

## Scope Sprint 1

Solo lo necesario para mockear catálogo + crear orden:
- Schema de Product
- Schema de Order + OrderItem
- Enum de OrderStatus
- Documentación en repo (\\\`docs/contracts/\\\`)

## Scope Sprint 2 (placeholder)

Endpoints REST, contratos de auth/JWT, formalizar envelope WebSocket. Bloqueado hasta que el backend entregue secciones 1-3 de su documento.

## Backend constraints conocidos

- Convención: **snake_case** en todos los campos JSON
- WebSocket: \\\`ws://<host>/ws?token=<JWT>\\\` (JWT en query string)
- Eventos WS conocidos: \\\`connected\\\`, \\\`order.updated\\\`, \\\`vehicle.updated\\\`, \\\`vehicle.error\\\`, \\\`stock.alert\\\`
- Backend NO replay-ea eventos perdidos en reconexión → cliente debe REST-fetch estado al reconectar

## Subtareas Sprint 1

- [ ] #<E1_1_NUM> E1.1 Definir JSON schema de Product
- [ ] #<E1_2_NUM> E1.2 Definir JSON schema de Order + OrderItem
- [ ] #<E1_3_NUM> E1.3 Definir enum de OrderStatus
- [ ] #<E1_4_NUM> E1.4 Documentar contratos en docs/contracts/
- [ ] #<E1_5_NUM> E1.5 Documentar decisiones tomadas

## Definition of Done

- Existe \\\`docs/contracts/product.md\\\`, \\\`docs/contracts/order.md\\\`, \\\`docs/contracts/README.md\\\`
- Mobile y Backend acordaron los schemas (revisión cruzada)
- Mobile puede usar los schemas para escribir sus modelos en E3 y E4
EOF
)"
```

---

## Task 10: Create E3 subtasks (Sprint 1)

**Files:** N/A

Crear las 13 subtareas de E3. Anotar números como `E3_1_NUM` a `E3_13_NUM`.

- [ ] **Step 10.1: E3.1 Setup feature package catalog**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.1: Setup feature package catalog" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Crear el package \`packages/features/catalog\` siguiendo el mismo patrón que \`packages/features/login\`.

## Files to create

- \`packages/features/catalog/pubspec.yaml\`
- \`packages/features/catalog/pubspec_overrides.yaml\`
- \`packages/features/catalog/lib/catalog.dart\` (barrel export)
- \`packages/features/catalog/lib/src/\` (carpetas data/, domain/, presentation/)

## Files to modify

- \`pubspec.yaml\` (root) — agregar \`catalog: path: packages/features/catalog\`
- \`melos.yaml\` — automático si los globs ya cubren

## Acceptance criteria

- [ ] \`melos bootstrap\` corre sin errores
- [ ] El package puede importarse desde \`smart_warehouse\` con \`import 'package:catalog/catalog.dart';\`
- [ ] Estructura de carpetas igual a \`features/login\`

## Estimado

~3hs
EOF
)"
```

- [ ] **Step 10.2: E3.2 Domain models Product + Category**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.2: Domain models Product + Category con freezed" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Crear los modelos de dominio \`Product\` y \`Category\` usando freezed, basados en el schema de E1.1.

## Files to create

- \`packages/features/catalog/lib/src/domain/entities/product.dart\`
- \`packages/features/catalog/lib/src/domain/entities/category.dart\`

## Acceptance criteria

- [ ] \`Product\` con campos: id, sku, name, description, category, stock, imageUrl, price
- [ ] \`Category\` (puede ser enum o entity con id+name)
- [ ] Generador freezed corre OK (\`melos run generate\`)
- [ ] Constructores fromJson/toJson funcionando con snake_case

## Bloqueada por

- E3.1 (package setup)
- E1.1 (schema definido) — soft dependency, puede empezarse con campos tentativos

## Estimado

~3hs
EOF
)"
```

- [ ] **Step 10.3: E3.3 Domain interface CatalogRepository**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.3: Domain interface CatalogRepository" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Definir el contrato \`CatalogRepository\` (interface abstracta) que va a tener implementaciones mock y real.

## File to create

- \`packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart\`

## Métodos esperados

- \`Future<List<Product>> getProducts()\`
- \`Future<Product> getProductById(String id)\`
- \`Future<List<Category>> getCategories()\` (opcional si Category es enum)

## Acceptance criteria

- [ ] Interface abstracta sin lógica
- [ ] Métodos retornan tipos del dominio (no DTOs)
- [ ] Comentarios docstring en cada método

## Estimado

~2hs
EOF
)"
```

- [ ] **Step 10.4: E3.4 MockCatalogRepository**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.4: Data MockCatalogRepository con dataset hardcodeado" \
  --label "priority:P0,area:catalog,sprint:1,mock" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Implementación de \`CatalogRepository\` que devuelve datos hardcodeados en memoria. ~10 productos con variedad de categorías para poder probar filtros.

## File to create

- \`packages/features/catalog/lib/src/data/repositories/mock_catalog_repository.dart\`

## Acceptance criteria

- [ ] ~10 productos hardcodeados con datos realistas
- [ ] Al menos 3 categorías diferentes
- [ ] Variedad de stock (algunos con 0 para probar empty state)
- [ ] Simula latencia con \`Future.delayed(Duration(milliseconds: 500))\` para probar loading
- [ ] Implementa todos los métodos de la interface

## Bloqueada por

- E3.2 (modelos)
- E3.3 (interface)

## Estimado

~3hs
EOF
)"
```

- [ ] **Step 10.5: E3.5 CatalogCubit**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.5: Presentation CatalogCubit + CatalogState" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Cubit que maneja el estado del catálogo. Estados con freezed (sealed/union).

## Files to create

- \`packages/features/catalog/lib/src/presentation/bloc/catalog_cubit.dart\`
- \`packages/features/catalog/lib/src/presentation/bloc/catalog_state.dart\`

## Estados

- \`CatalogState.loading()\`
- \`CatalogState.loaded(List<Product> products, String? searchQuery, Category? categoryFilter)\`
- \`CatalogState.error(String message)\`

## Métodos del cubit

- \`loadProducts()\` — fetch inicial
- \`updateSearchQuery(String query)\`
- \`updateCategoryFilter(Category? category)\`
- \`retry()\` — recarga después de error
- Computed: \`filteredProducts\` que combina search + category

## Acceptance criteria

- [ ] Estado con freezed
- [ ] Lógica de filtrado en el cubit (no en UI)
- [ ] Tests unitarios del cubit (al menos happy path)

## Bloqueada por

- E3.3 (interface), E3.4 (mock para tests)

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 10.6: E3.6 ProductCard widget**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.6: UI ProductCard widget reusable" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Widget reusable para mostrar un producto en la lista. Diseño básico, alineado con design_system.

## File to create

- \`packages/features/catalog/lib/src/presentation/components/product_card.dart\`

## Especificación visual

- Imagen (placeholder si no hay URL)
- Nombre del producto
- Stock (badge o texto)
- Precio (si aplica)
- Tap → navega al detalle (callback en props)

## Acceptance criteria

- [ ] Widget recibe \`Product\` y \`VoidCallback onTap\`
- [ ] Maneja imagen ausente con placeholder
- [ ] Stock 0 se muestra en gris/disabled
- [ ] Sigue el theme del design_system

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 10.7: E3.7 CatalogPage**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.7: UI CatalogPage con BlocBuilder + lista" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Pantalla principal del catálogo con la lista de productos consumiendo el cubit.

## File to create

- \`packages/features/catalog/lib/src/presentation/pages/catalog_view.dart\`
- \`packages/features/catalog/lib/src/catalog_feature_builder.dart\` (provider con cubit)

## Acceptance criteria

- [ ] BlocProvider provee el CatalogCubit
- [ ] BlocBuilder renderiza loading / loaded / error
- [ ] ListView con ProductCard por producto
- [ ] Llama \`loadProducts()\` en el initState

## Bloqueada por

- E3.5 (cubit), E3.6 (ProductCard)

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 10.8: E3.8 Estados vacío/error/loading**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.8: UI estados vacío/error/loading en CatalogPage" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Implementar los tres estados no-felices del catálogo usando los widgets reusables de E7.

## Acceptance criteria

- [ ] Estado vacío: \`EmptyView\` con mensaje \"No hay productos\"
- [ ] Estado loading: \`LoadingSkeleton\` o \`LoadingSpinner\`
- [ ] Estado error: \`ErrorView\` con botón \"Reintentar\" → \`cubit.retry()\`
- [ ] Estados se renderizan sin crashes

## Bloqueada por

- E3.7 (página)
- E7.1, E7.2, E7.3, E7.4 (widgets reusables)

## Estimado

~3hs
EOF
)"
```

- [ ] **Step 10.9: E3.9 Search bar**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.9: UI search bar con filtrado por nombre/SKU" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Barra de búsqueda en la parte superior del catálogo. Filtrado en cliente (no llama backend).

## Acceptance criteria

- [ ] TextField con icono lupa
- [ ] OnChanged llama \`cubit.updateSearchQuery(value)\`
- [ ] El cubit filtra in-memory por nombre OR sku (case-insensitive)
- [ ] Botón clear (X) que vacía la query
- [ ] Debounce de ~300ms para no recalcular en cada keystroke

## Bloqueada por

- E3.5, E3.7

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 10.10: E3.10 Filtros de categoría**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.10: UI chips de filtro por categoría + lógica" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Chips horizontales scrollables debajo de la search bar para filtrar por categoría.

## Acceptance criteria

- [ ] Chips uno por categoría + un chip \"Todos\"
- [ ] Tap en un chip llama \`cubit.updateCategoryFilter(category)\`
- [ ] Chip seleccionado se ve diferente (color de fondo)
- [ ] Combina con la search query (AND, no OR)

## Bloqueada por

- E3.5, E3.7

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 10.11: E3.11 ProductDetailPage**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.11: UI ProductDetailPage con info completa + CTA" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Pantalla de detalle de producto. Recibe el id por param de ruta.

## File to create

- \`packages/features/catalog/lib/src/presentation/pages/product_detail_view.dart\`

## Layout

- Imagen grande
- Nombre y SKU
- Categoría
- Descripción
- Stock disponible
- Precio
- **Botón \"Agregar al carrito\"** (handler queda para E4.9)

## Acceptance criteria

- [ ] Recibe id de producto por param
- [ ] Carga el producto vía \`cubit.getProductById\` o desde cache
- [ ] Maneja loading y error
- [ ] Botón \"Agregar al carrito\" presente (handler dummy por ahora — \"Próximamente\")

## Estimado

~4hs
EOF
)"
```

- [ ] **Step 10.12: E3.12 Routing Beamer**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.12: Routing Beamer /catalog y /catalog/:id" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Configurar las rutas Beamer del catálogo dentro del routing root.

## Acceptance criteria

- [ ] \`/catalog\` → CatalogPage
- [ ] \`/catalog/:id\` → ProductDetailPage con id como param
- [ ] Tap en ProductCard navega correctamente
- [ ] Back funciona

## Bloqueada por

- E7.5 (routing root setup)
- E3.7, E3.11

## Estimado

~3hs
EOF
)"
```

- [ ] **Step 10.13: E3.13 Wire-up bottom nav**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E3.13: Wire-up tab Productos en bottom navigation" \
  --label "priority:P0,area:catalog,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #2

## Tarea

Agregar tab \"Productos\" en el bottom navigation que abre \`/catalog\`.

## Files to modify

- \`packages/features/bottom_navigation_bar/lib/src/presentation/components/bottom_navigation_component.dart\`
- \`packages/features/bottom_navigation_bar/lib/src/domain/entities/navigation_bar_option.dart\` (si necesita agregar opción)

## Acceptance criteria

- [ ] Tab \"Productos\" con icono apropiado
- [ ] Tap navega a /catalog
- [ ] Tab activo cuando estás en /catalog o /catalog/:id

## Bloqueada por

- E7.7, E3.12

## Estimado

~2hs
EOF
)"
```

- [ ] **Step 10.14: Update E3 epic body with real numbers**

Reemplazar `<E3_X_NUM>` por los números reales:

```bash
gh issue edit 2 --repo enricotonelli/SmartWarehouse \
  --body "$(cat <<EOF
## Goal

Pantalla de catálogo de productos con datos mockeados (sin backend real). Permite al usuario navegar productos, buscar, filtrar por categoría y ver detalle.

## Scope Sprint 1 (mock)

UI completa funcionando con \\\`MockCatalogRepository\\\` con ~10 productos hardcodeados.

## Scope Sprint 2 (real)

Reemplazar mock por \\\`RemoteCatalogRepository\\\` consumiendo \\\`GET /products\\\` cuando el backend exponga el endpoint.

## Bloqueada por

- E1 (subset Product) — necesita schema de Product cerrado para escribir el modelo

## Bloquea a

- E4 (Carrito) — el botón \"Agregar al carrito\" sale del detalle de producto

## Subtareas Sprint 1

- [ ] #<E3_1_NUM> E3.1 Setup feature package catalog
- [ ] #<E3_2_NUM> E3.2 Domain: modelos Product y Category
- [ ] #<E3_3_NUM> E3.3 Domain: interface CatalogRepository
- [ ] #<E3_4_NUM> E3.4 Data: MockCatalogRepository
- [ ] #<E3_5_NUM> E3.5 Presentation: CatalogCubit
- [ ] #<E3_6_NUM> E3.6 UI: widget ProductCard
- [ ] #<E3_7_NUM> E3.7 UI: CatalogPage con lista
- [ ] #<E3_8_NUM> E3.8 UI: estados vacío/error/loading
- [ ] #<E3_9_NUM> E3.9 UI: search bar
- [ ] #<E3_10_NUM> E3.10 UI: filtros de categoría
- [ ] #<E3_11_NUM> E3.11 UI: ProductDetailPage
- [ ] #<E3_12_NUM> E3.12 Routing Beamer
- [ ] #<E3_13_NUM> E3.13 Wire-up bottom nav

## Definition of Done

- App muestra catálogo con 10 productos mock
- Búsqueda por nombre y SKU funciona
- Filtro por categoría funciona
- Detalle de producto muestra info completa
- Estados de loading/error/vacío implementados
- Tab \"Productos\" en bottom nav navega al catálogo
EOF
)"
```

---

## Task 11: Create E4 subtasks (Sprint 1)

**Files:** N/A

Crear las 18 subtareas de E4. Anotar números como `E4_1_NUM` a `E4_18_NUM`.

- [ ] **Step 11.1: E4.1 Setup package cart**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.1: Setup feature package cart" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

Crear \`packages/features/cart\` siguiendo el patrón de \`features/login\` y \`features/catalog\`.

## Acceptance criteria

- [ ] pubspec.yaml + pubspec_overrides.yaml + lib/cart.dart barrel
- [ ] Estructura data/, domain/, presentation/
- [ ] Registrado en pubspec root
- [ ] \`melos bootstrap\` OK

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 11.2: E4.2 Setup package orders**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.2: Setup feature package orders" \
  --label "priority:P0,area:orders,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

Crear \`packages/features/orders\` siguiendo el patrón.

## Acceptance criteria

- [ ] Estructura completa
- [ ] Registrado en pubspec
- [ ] \`melos bootstrap\` OK

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 11.3: E4.3 Domain models**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.3: Domain models Cart, CartItem, Order, OrderItem, OrderStatus" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Tarea

Modelos de dominio con freezed:
- \`Cart\` (en package cart)
- \`CartItem\` (en package cart)
- \`Order\` (en package orders)
- \`OrderItem\` (en package orders)
- \`OrderStatus\` enum (en package orders)

## Acceptance criteria

- [ ] Modelos generados con freezed
- [ ] fromJson/toJson con snake_case (excepto Cart que es local)
- [ ] OrderStatus matchea enum de E1.3

## Bloqueada por

- E1.2, E1.3
- E4.1, E4.2

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.4: E4.4 Domain interfaces**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.4: Domain interfaces CartRepository + OrderRepository" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Métodos esperados

CartRepository:
- \`Cart getCurrentCart()\`
- \`void addItem(Product product, int quantity)\`
- \`void removeItem(String productId)\`
- \`void updateQuantity(String productId, int quantity)\`
- \`void clear()\`

OrderRepository:
- \`Future<Order> createOrder(Cart cart)\`
- \`Future<List<Order>> getMyOrders()\` (placeholder, sprint 2)

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 11.5: E4.5 InMemoryCartRepository**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.5: Data InMemoryCartRepository (singleton via IoC)" \
  --label "priority:P0,area:cart,sprint:1,mock" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Tarea

Implementación in-memory del CartRepository. Singleton registrado en IoC para que se comparta entre páginas.

## Acceptance criteria

- [ ] Estado persiste mientras la app corre
- [ ] Se resetea al reiniciar (no necesita persistencia local)
- [ ] Registrado en \`IocManager\`
- [ ] Thread-safe (no concurrencia esperada en mobile pero considerar)

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.6: E4.6 MockOrderRepository**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.6: Data MockOrderRepository (genera Order fake)" \
  --label "priority:P0,area:orders,sprint:1,mock" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Tarea

Implementación mock del OrderRepository. \`createOrder\` devuelve un \`Order\` con:
- id generado (\`ORD-\${random 4 digits}\`)
- timestamp = now
- status = pending
- items copiados del cart

## Acceptance criteria

- [ ] Latencia simulada (500-1000ms)
- [ ] Probabilidad ~10% de devolver error (para probar UI de error)
- [ ] Limpia el carrito al éxito (vía CartRepository)

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.7: E4.7 CartCubit**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.7: Presentation CartCubit (add, remove, updateQty, clear, total)" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Estados

- \`CartState.empty()\`
- \`CartState.loaded(List<CartItem> items, double total, int itemCount)\`

## Métodos

- \`addProduct(Product, int quantity)\`
- \`removeItem(String productId)\`
- \`updateQuantity(String productId, int quantity)\`
- \`clear()\`
- emite estado nuevo después de cada cambio

## Acceptance criteria

- [ ] Estado con freezed
- [ ] Tests unitarios del cubit
- [ ] Total se computa correctamente

## Estimado: ~4hs
EOF
)"
```

- [ ] **Step 11.8: E4.8 CreateOrderCubit**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.8: Presentation CreateOrderCubit (submit, success, error)" \
  --label "priority:P0,area:orders,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Estados

- \`CreateOrderState.idle()\`
- \`CreateOrderState.submitting()\`
- \`CreateOrderState.success(Order order)\`
- \`CreateOrderState.error(String message)\`

## Métodos

- \`submit(Cart cart)\`
- \`reset()\` — vuelve a idle

## Acceptance criteria

- [ ] Llama OrderRepository.createOrder
- [ ] Tests unitarios

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.9: E4.9 Botón Agregar al carrito**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.9: UI botón Agregar al carrito en ProductDetailPage" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Tarea

Wire-up del botón existente en ProductDetailPage (creado en E3.11) con CartCubit.

## Acceptance criteria

- [ ] Tap → llama \`cartCubit.addProduct(product, 1)\`
- [ ] Snackbar con \"Agregado al carrito\"
- [ ] Si stock = 0, botón disabled

## Bloqueada por

- E3.11, E4.7

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 11.10: E4.10 CartPage**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.10: UI CartPage con lista de items" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Tarea

Pantalla de carrito con items, scroll, y empty state.

## Acceptance criteria

- [ ] BlocBuilder consumiendo CartCubit
- [ ] Lista de \`CartItemCard\` (creado dentro de la misma issue)
- [ ] Empty state con CTA \"Ir al catálogo\"

## Estimado: ~4hs
EOF
)"
```

- [ ] **Step 11.11: E4.11 Stepper de cantidad**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.11: UI stepper de cantidad (+/-) por item" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Tarea

Componente +/- por item del carrito que llama \`updateQuantity\`.

## Acceptance criteria

- [ ] Botones + y - junto al número
- [ ] - en qty=1 elimina el item (con confirmación opcional)
- [ ] + bloqueado si supera stock disponible

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.12: E4.12 Validaciones**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.12: UI validaciones (qty > 0, qty ≤ stock)" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Tarea

Reglas de negocio aplicadas en el cubit y UI.

## Acceptance criteria

- [ ] qty no puede ser <= 0
- [ ] qty no puede superar stock del producto
- [ ] Mensajes de error si se intenta
- [ ] Validación previa al submit (no permitir submit con items inválidos)

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.13: E4.13 Footer + botón Crear orden**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.13: UI footer con total + botón Crear orden" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Acceptance criteria

- [ ] Footer fijo en bottom de CartPage
- [ ] Muestra cantidad de items y total
- [ ] Botón \"Crear orden\" disabled si carrito vacío
- [ ] Tap → abre CreateOrderConfirmationDialog (E4.14)

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.14: E4.14 CreateOrderConfirmationDialog**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.14: UI CreateOrderConfirmationDialog" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Acceptance criteria

- [ ] Muestra resumen: # items, total
- [ ] Botones Cancelar / Confirmar
- [ ] Confirmar llama \`createOrderCubit.submit(cart)\`

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.15: E4.15 OrderSuccessPage**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.15: UI OrderSuccessPage (muestra ORD-XXXX + CTA)" \
  --label "priority:P0,area:orders,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Acceptance criteria

- [ ] Muestra ID de orden grande (\`ORD-XXXX\`)
- [ ] Mensaje \"Orden creada\"
- [ ] Botón \"Volver al catálogo\"
- [ ] Recibe orderId por param de ruta

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.16: E4.16 Manejo error de submit**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.16: UI manejo de error de submit con retry" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Acceptance criteria

- [ ] BlocListener escuchando CreateOrderCubit
- [ ] En error: snackbar con mensaje + botón retry
- [ ] Cart no se vacía al error (preserva intent del usuario)

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.17: E4.17 Routing**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.17: Routing /cart, /cart/confirm, /order/:id/success" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Rutas Beamer

- \`/cart\` → CartPage
- \`/cart/confirm\` → presenta el dialog (puede ser modal sobre /cart)
- \`/order/:id/success\` → OrderSuccessPage con orderId

## Bloqueada por

- E7.5, E4.10, E4.15

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.18: E4.18 Badge en bottom nav**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E4.18: Wire-up badge con cantidad de items en tab Cart" \
  --label "priority:P0,area:cart,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #3

## Acceptance criteria

- [ ] Tab \"Carrito\" en bottom nav
- [ ] Badge con número = cant items en cart
- [ ] Badge se oculta si cart vacío
- [ ] Reactive al CartCubit

## Bloqueada por

- E7.7, E4.7

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 11.19: Update E4 epic body con números reales**

Reemplazar `<E4_X_NUM>`:

```bash
gh issue edit 3 --repo enricotonelli/SmartWarehouse \
  --body "$(cat <<EOF
## Goal

Permitir al usuario armar un carrito agregando productos del catálogo, editar cantidades, y crear una orden (mockeada).

## Subtareas Sprint 1

- [ ] #<E4_1_NUM> E4.1 Setup feature package cart
- [ ] #<E4_2_NUM> E4.2 Setup feature package orders
- [ ] #<E4_3_NUM> E4.3 Domain: modelos Cart, CartItem, Order, OrderItem, OrderStatus
- [ ] #<E4_4_NUM> E4.4 Domain: interfaces CartRepository + OrderRepository
- [ ] #<E4_5_NUM> E4.5 Data: InMemoryCartRepository
- [ ] #<E4_6_NUM> E4.6 Data: MockOrderRepository
- [ ] #<E4_7_NUM> E4.7 Presentation: CartCubit
- [ ] #<E4_8_NUM> E4.8 Presentation: CreateOrderCubit
- [ ] #<E4_9_NUM> E4.9 UI: botón \"Agregar al carrito\"
- [ ] #<E4_10_NUM> E4.10 UI: CartPage
- [ ] #<E4_11_NUM> E4.11 UI: stepper de cantidad
- [ ] #<E4_12_NUM> E4.12 UI: validaciones
- [ ] #<E4_13_NUM> E4.13 UI: footer + botón Crear orden
- [ ] #<E4_14_NUM> E4.14 UI: CreateOrderConfirmationDialog
- [ ] #<E4_15_NUM> E4.15 UI: OrderSuccessPage
- [ ] #<E4_16_NUM> E4.16 UI: manejo error de submit
- [ ] #<E4_17_NUM> E4.17 Routing
- [ ] #<E4_18_NUM> E4.18 Wire-up badge bottom nav

## Bloqueada por

- **E3.4** \\\`MockCatalogRepository\\\` — el carrito necesita productos
- **E3.11** \\\`ProductDetailPage\\\` — botón \"Agregar\" vive ahí

## Definition of Done

- Usuario puede agregar productos desde el detalle
- Editar cantidades / eliminar items
- Validaciones funcionando
- Submit crea orden y muestra pantalla de éxito
- Manejo de error con retry
- Badge en bottom nav funcionando
EOF
)"
```

---

## Task 12: Create E7 subtasks (Sprint 1)

**Files:** N/A

- [ ] **Step 12.1: E7.1 LoadingSpinner**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E7.1: LoadingSpinner widget en design_system" \
  --label "priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #6

## Tarea

Widget reusable de spinner centrado con color del theme.

## File

\`packages/design_system/lib/src/components/loading_spinner.dart\`

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 12.2: E7.2 LoadingSkeleton**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E7.2: LoadingSkeleton widget en design_system" \
  --label "priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #6

## Tarea

Skeleton loader animado para listas (shimmer effect).

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 12.3: E7.3 ErrorView**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E7.3: ErrorView widget con retry callback" \
  --label "priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #6

## Acceptance criteria

- [ ] Recibe \`String message\` y \`VoidCallback onRetry\`
- [ ] Icono de error
- [ ] Botón \"Reintentar\"

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 12.4: E7.4 EmptyView**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E7.4: EmptyView widget reusable" \
  --label "priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #6

## Acceptance criteria

- [ ] Recibe icono, título, mensaje, optional CTA
- [ ] Centrado verticalmente

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 12.5: E7.5 Beamer routing root**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E7.5: Setup Beamer routing root + locations" \
  --label "priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #6

## Tarea

BeamerDelegate root, locations registrados, default location = /catalog.

## Acceptance criteria

- [ ] Locations: catalog, cart, order, login (placeholder)
- [ ] Beamer integrado en MaterialApp.router
- [ ] Inicial = /catalog (no login durante Sprint 1)

## Estimado: ~4hs
EOF
)"
```

- [ ] **Step 12.6: E7.6 Bypass auth gate**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E7.6: Bypass auth gate en main.dart (Sprint 1)" \
  --label "priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #6

## Tarea

Configurar el flow para que la app vaya directo al catálogo sin pasar por login.

## Acceptance criteria

- [ ] App arranca y muestra /catalog sin pedir credenciales
- [ ] Comentario en el código indicando que esto se reemplaza en Sprint 2 (E2)

## Estimado: ~2hs
EOF
)"
```

- [ ] **Step 12.7: E7.7 BottomNavigationScaffold**

```bash
gh issue create --repo enricotonelli/SmartWarehouse \
  --title "E7.7: Configurar BottomNavigationScaffold con tabs Sprint 1" \
  --label "priority:P1,area:ux,sprint:1" \
  --body "$(cat <<'EOF'
Parent epic: #6

## Tabs

1. Productos (catalog)
2. Carrito (cart) con badge
3. Órdenes (placeholder por ahora — \"Próximamente\")

## Acceptance criteria

- [ ] Tabs registrados
- [ ] Tab activo se marca correctamente según ruta
- [ ] Tab \"Órdenes\" muestra placeholder

## Estimado: ~3hs
EOF
)"
```

- [ ] **Step 12.8: Update E7 epic body**

```bash
gh issue edit 6 --repo enricotonelli/SmartWarehouse \
  --body "$(cat <<EOF
## Goal

Componentes y configuración UX/navegación reusables que necesitan E3 y E4 para Sprint 1.

## Subtareas Sprint 1

- [ ] #<E7_1_NUM> E7.1 LoadingSpinner widget
- [ ] #<E7_2_NUM> E7.2 LoadingSkeleton widget
- [ ] #<E7_3_NUM> E7.3 ErrorView widget con retry
- [ ] #<E7_4_NUM> E7.4 EmptyView widget
- [ ] #<E7_5_NUM> E7.5 Setup Beamer routing root
- [ ] #<E7_6_NUM> E7.6 Bypass de auth gate en main.dart
- [ ] #<E7_7_NUM> E7.7 Configurar BottomNavigationScaffold

## Definition of Done

- Widgets reusables funcionando y usados en E3/E4
- App arranca y va directo al catálogo (sin login)
- Navegación entre tabs funciona
EOF
)"
```

---

## Task 13: Create Project board v2 with 5 columns

**Files:** N/A

Project boards v2 son por owner (user/org), no por repo. Se crea uno asociado al user `enricotonelli` o al repo. Vamos a crear uno owned por el user.

- [ ] **Step 13.1: Create project**

```bash
gh project create --owner enricotonelli --title "SmartWarehouse Mobile - Sprint Backlog"
```

Salida: imprime URL del proyecto y un **número de proyecto** (ej. `#1`). Anotar como `PROJECT_NUM`.

- [ ] **Step 13.2: Get project ID and Status field ID**

```bash
gh api graphql -f query='
{
  user(login: "enricotonelli") {
    projectV2(number: <PROJECT_NUM>) {
      id
      fields(first: 20) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
            options { id name }
          }
        }
      }
    }
  }
}'
```

Anotar:
- `PROJECT_ID` (el `id` del projectV2)
- `STATUS_FIELD_ID` (el `id` del field con `name: "Status"`)
- IDs de las options existentes (Todo, In Progress, Done) como `OPTION_TODO_ID`, `OPTION_INPROGRESS_ID`, `OPTION_DONE_ID`

- [ ] **Step 13.3: Update Status field options to 5 columns**

GitHub Projects v2 vienen con un Status default de `Todo / In Progress / Done`. Necesitamos: `Backlog / In Progress / Pending Approval / QA / Done`.

```bash
gh api graphql -f query='
mutation {
  updateProjectV2Field(input: {
    fieldId: "<STATUS_FIELD_ID>",
    singleSelectOptions: [
      {name: "Backlog", color: GRAY, description: "Pendiente, sin empezar"},
      {name: "In Progress", color: BLUE, description: "Trabajo en curso"},
      {name: "Pending Approval", color: YELLOW, description: "PR abierta, esperando review"},
      {name: "QA", color: ORANGE, description: "Mergeado, esperando QA"},
      {name: "Done", color: GREEN, description: "Completado y validado"}
    ]
  }) {
    projectV2Field {
      ... on ProjectV2SingleSelectField {
        id
        options { id name }
      }
    }
  }
}'
```

Anotar los nuevos IDs de options:
- `OPT_BACKLOG_ID`
- `OPT_INPROGRESS_ID`
- `OPT_PENDINGAPPROVAL_ID`
- `OPT_QA_ID`
- `OPT_DONE_ID`

> **Nota:** Si la mutation falla porque las options existentes están en uso, primero hay que migrar items a un option temporal, después updatear. Si pasa esto, fallback: borrar el Status field y crear uno nuevo con las 5 options. Documentar en comentario de E0.

---

## Task 14: Add all open issues to project + assign columns

**Files:** N/A

Necesitamos agregar cada issue al project y settearle el Status.

Para cada issue (~50 total), el flow es:

1. Add item via REST: `gh project item-add`
2. Set Status field

Vamos a hacer un loop simple. Primero juntar todos los números de issue.

- [ ] **Step 14.1: List all open issues + E0**

```bash
gh issue list --repo enricotonelli/SmartWarehouse --state all --limit 100 --json number,state,title
```

Anotar todos los números. Esperado: ~50 issues (1, 2, 3, 6, 7 abiertas como épicas + ~43 subtareas + E0/E2/E5/E6 nuevas + #4 y #8 cerradas).

- [ ] **Step 14.2: Add issues to project (loop)**

Para cada número de issue, correr:

```bash
gh project item-add <PROJECT_NUM> --owner enricotonelli --url https://github.com/enricotonelli/SmartWarehouse/issues/<ISSUE_NUM>
```

Cada call devuelve un `item-id`. **Anotar** cada item-id porque lo necesitamos para setear el Status.

> Tip: si hay muchas, puede automatizarse con un script bash que itere. Ejemplo:
>
> ```bash
> for n in 1 2 3 6 7 9 10 11 12 13 14 15 16; do
>   gh project item-add <PROJECT_NUM> --owner enricotonelli \
>     --url https://github.com/enricotonelli/SmartWarehouse/issues/$n
> done
> ```

- [ ] **Step 14.3: Set Status field por issue**

Para cada item agregado, setear su Status según esta tabla:

| Tipo de issue | Columna |
|---------------|---------|
| E0 (Initial Setup, cerrada) | **Done** |
| Épicas E1-E8 (abiertas) | **Backlog** |
| Subtareas de Sprint 1 | **Backlog** |
| Issue #4, #8 (cerradas reorg) | **Done** (o no agregar al board) |

Para setear Status:

```bash
gh project item-edit \
  --id <ITEM_ID> \
  --field-id <STATUS_FIELD_ID> \
  --project-id <PROJECT_ID> \
  --single-select-option-id <OPT_BACKLOG_ID>
```

Reemplazar `<OPT_BACKLOG_ID>` por `<OPT_DONE_ID>` para E0.

> **Pragmatic shortcut:** si hacer esto manual para 50 issues es muy tedioso, otra opción es **abrir el project en el browser** (URL devuelta en Step 13.1) y arrastrar items entre columnas. Es más rápido y menos error-prone.

---

## Task 15: Final verification

**Files:** N/A

- [ ] **Step 15.1: Verify issues count**

```bash
gh issue list --repo enricotonelli/SmartWarehouse --state all --limit 100 --label "type:epic"
```

Expected: 9 épicas (E0-E8). E0 cerrada, E1-E8 abiertas (E5 con label `blocked`).

- [ ] **Step 15.2: Verify Sprint 1 subtasks count**

```bash
gh issue list --repo enricotonelli/SmartWarehouse --state open --label "sprint:1" --limit 100
```

Expected: ~47 issues (5 epics + 5 E1 subtasks + 13 E3 + 18 E4 + 7 E7 = 48; con epic E2 que tiene sprint:2 pero es para placeholder, ajustar).

- [ ] **Step 15.3: Verify project board structure**

Abrir en el browser la URL del project (devuelta en Step 13.1) y verificar:
- 5 columnas: Backlog, In Progress, Pending Approval, QA, Done
- E0 está en Done
- Resto de épicas Sprint 1 en Backlog
- Subtareas Sprint 1 en Backlog

- [ ] **Step 15.4: Verify epic body checkboxes link to real issues**

Para cada épica (E1, E3, E4, E7), abrir en browser y verificar que los checkboxes referencian issues reales (cliquables, muestran preview).

- [ ] **Step 15.5: Verify labels coverage**

```bash
gh issue list --repo enricotonelli/SmartWarehouse --state open --json number,labels --jq '.[] | select(.labels | length == 0) | .number'
```

Expected: vacío (todas las issues abiertas tienen al menos 1 label).

---

## Definition of Done global

- [ ] 16 labels creados en el repo
- [ ] 7 issues existentes reorganizadas (5 reutilizadas como épicas, 2 cerradas con comentario)
- [ ] 9 épicas en GitHub (E0-E8) con bodies completos
- [ ] ~43 subtareas de Sprint 1 creadas y enlazadas a sus épicas vía task lists
- [ ] Project board v2 con 5 columnas custom (Backlog, In Progress, Pending Approval, QA, Done)
- [ ] Todas las issues agregadas al project con Status correcto
- [ ] E0 visible en columna Done
- [ ] Todas las épicas y subtareas Sprint 1 en columna Backlog
- [ ] Verificaciones del Task 15 pasan

---

## Notas para el ejecutor

1. **Anotar números de issue después de cada `gh issue create`.** Son críticos para los pasos de actualización de body de épicas.
2. **Si un comando falla, leer el error completo antes de seguir.** Algunos errores comunes:
   - Label ya existe → continuar
   - Issue no encontrada → revisar número
   - Permission denied en project → correr Task 1 (auth refresh)
3. **No hacer commits de código durante este plan** — solo operaciones de GitHub. El código de las features se implementa en planes posteriores cuando cada subtarea se trabaje.
4. **Checkpoint al final de Task 6, 9, 10, 11, 12** — pausar y verificar visualmente en GitHub que las issues quedan como se espera antes de seguir.
