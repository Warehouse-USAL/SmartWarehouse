# Preview web con marco de celular en el server — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que cada release estable publique una imagen nginx con la app Flutter web y que el server del equipo la sirva en `/mobile/` dentro de una página con marco de celular.

**Architecture:** La URL del backend se resuelve por mismo origen en web (sin CORS). El workflow Stable Release compila web con `--base-href /mobile/app/`, empaqueta el resultado en una imagen nginx y la pushea a GHCR. Un `deploy.yml` calcado del de smarthouse_webapp corre en el runner del server y hace `docker compose pull && up -d`. En wh-autodeploys, Caddy rutea `/mobile/*` al contenedor.

**Tech Stack:** Flutter 3.47 web, nginx:alpine, Docker Compose, GitHub Actions (self-hosted runner), Caddy 2.

**Spec:** `docs/superpowers/specs/2026-09-23-mobile-web-preview-deploy-design.md`

## Global Constraints

- Imagen: `ghcr.io/warehouse-usal/smartwarehouse`, tags `<vX.Y.Z>` y `latest`.
- Base href del build web: `/mobile/app/`. Página de preview en `/mobile/`, app a pantalla completa en `/mobile/app/`.
- Servicio compose: `mobile`, red externa `wh-proxy`, sin puertos de host.
- Clone en el server: `/opt/wh/SmartWarehouse`. Grupo de concurrencia del deploy: `deploy-mobile`.
- El build web de release **no** recibe `--dart-define=API_BASE_URL`. El APK sí, como hoy.
- Nada de frameworks en la página de preview: HTML y CSS puros.
- Commits en español, estilo `feat(scope): ...` como el historial del repo.
- Melos 6.3.3. Tests con `flutter test`. Antes de cada commit: `flutter analyze` limpio en el package tocado.

## Review Focus

1. **Recarga en ruta profunda** (`/mobile/app/orders/3`): nginx debe devolver `/app/index.html`, no 404. Test: curl en Task 2.
2. **Origen web con puerto no estándar** (`http://192.168.0.10:8080/`): la base debe conservar el puerto. Test en Task 1.
3. **`Uri.base` con scheme no http** (`file://`, tests o runners raros): no debe lanzar; cae a `localhost`. Test en Task 1.
4. **HTTPS en el server**: el origen `https://host` debe pasar tal cual, y order_tracking lo convierte a `wss://`. Test en Task 1.
5. **Placeholder de versión sin reemplazar**: si `APP_VERSION` no se pasa, la página muestra `dev`, nunca `__APP_VERSION__`. Test: curl en Task 2.

---

### Task 1: Resolución de la URL del backend por mismo origen en web

**Files:**
- Create: `lib/config/backend_url.dart`
- Create: `test/config/backend_url_test.dart`
- Modify: `lib/config/ioc_manager.dart:70-96` (la función `_localBackendUrl`)

**Interfaces:**
- Produces: `String resolveBackendUrl({required bool isWeb, required bool isAndroid, required Uri base, String fullOverride = '', String hostOverride = '', String port = '8080'})` en `package:smart_warehouse/config/backend_url.dart`. Sin `dart:io`, testeable en VM.

- [ ] **Step 1: Escribir los tests que fallan**

```dart
// test/config/backend_url_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_warehouse/config/backend_url.dart';

void main() {
  final serverBase = Uri.parse('http://warehouse.local/mobile/app/');

  group('resolveBackendUrl', () {
    test('API_BASE_URL absoluta gana sobre todo', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: serverBase,
          fullOverride: 'https://api.example.com',
          hostOverride: '1.2.3.4',
        ),
        'https://api.example.com',
      );
    });

    test('API_HOST/API_PORT arma http://host:port', () {
      expect(
        resolveBackendUrl(
          isWeb: false,
          isAndroid: true,
          base: serverBase,
          hostOverride: '192.168.1.10',
          port: '9090',
        ),
        'http://192.168.1.10:9090',
      );
    });

    test('web en localhost conserva localhost:port (flutter run -d chrome)', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('http://localhost:54321/'),
        ),
        'http://localhost:8080',
      );
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('http://127.0.0.1:54321/'),
          port: '9000',
        ),
        'http://localhost:9000',
      );
    });

    test('web en otro host usa el origen de la página (mismo origen, sin CORS)', () {
      expect(
        resolveBackendUrl(isWeb: true, isAndroid: false, base: serverBase),
        'http://warehouse.local',
      );
    });

    test('web conserva el puerto del origen', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('http://192.168.0.10:8080/mobile/app/'),
        ),
        'http://192.168.0.10:8080',
      );
    });

    test('web con https devuelve origen https', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('https://warehouse.usal.edu/mobile/app/'),
        ),
        'https://warehouse.usal.edu',
      );
    });

    test('web con scheme no http cae a localhost sin lanzar', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('file:///Users/x/index.html'),
        ),
        'http://localhost:8080',
      );
    });

    test('Android emulator usa 10.0.2.2', () {
      expect(
        resolveBackendUrl(isWeb: false, isAndroid: true, base: serverBase),
        'http://10.0.2.2:8080',
      );
    });

    test('iOS/desktop usa localhost', () {
      expect(
        resolveBackendUrl(isWeb: false, isAndroid: false, base: serverBase),
        'http://localhost:8080',
      );
    });
  });
}
```

- [ ] **Step 2: Correr y ver que falla**

Run: `flutter test test/config/backend_url_test.dart`
Expected: falla en compilación, `package:smart_warehouse/config/backend_url.dart` no existe.

- [ ] **Step 3: Implementar la función**

```dart
// lib/config/backend_url.dart

/// URL base del backend.
///
/// Precedencia (de mayor a menor):
/// 1. [fullOverride] (`--dart-define=API_BASE_URL=https://api.example.com`):
///    URL completa con scheme. Se respeta tal cual. La usa el APK de release.
/// 2. [hostOverride] + [port] (`--dart-define=API_HOST=192.168.1.10
///    --dart-define=API_PORT=8080`): device físico en red local, asume http.
/// 3. Web servida desde un host que no es localhost: el origen de la página
///    ([base]). En el server la app vive en `http://<host>/mobile/app/` y el
///    proxy rutea `/auth`, `/products`, `/ws` al backend. Mismo origen, sin
///    CORS. Si el scheme no es http/https (file://, tests) se cae al default.
/// 4. Defaults locales: `10.0.2.2:[port]` en Android emulator (alias al host),
///    `localhost:[port]` en web local, iOS simulator y desktop.
///
/// Pura y sin `dart:io` para poder testearla en VM.
String resolveBackendUrl({
  required bool isWeb,
  required bool isAndroid,
  required Uri base,
  String fullOverride = '',
  String hostOverride = '',
  String port = '8080',
}) {
  if (fullOverride.isNotEmpty) return fullOverride;
  if (hostOverride.isNotEmpty) return 'http://$hostOverride:$port';

  if (isWeb) {
    final isHttp = base.scheme == 'http' || base.scheme == 'https';
    final isLocal = base.host == 'localhost' || base.host == '127.0.0.1';
    if (isHttp && !isLocal) return base.origin;
    return 'http://localhost:$port';
  }

  final host = isAndroid ? '10.0.2.2' : 'localhost';
  return 'http://$host:$port';
}
```

- [ ] **Step 4: Correr y ver que pasa**

Run: `flutter test test/config/backend_url_test.dart`
Expected: 9 tests PASS.

- [ ] **Step 5: Cablear en `ioc_manager.dart`**

Reemplazar el bloque completo desde el doc comment `/// URL del backend.` hasta el cierre de `_localBackendUrl()` (líneas 70-96) por:

```dart
/// URL del backend. Ver [resolveBackendUrl] para la precedencia.
String _localBackendUrl() => resolveBackendUrl(
  isWeb: kIsWeb,
  // Platform.isAndroid lanza en web: el short-circuit lo protege.
  isAndroid: !kIsWeb && Platform.isAndroid,
  base: Uri.base,
  fullOverride: const String.fromEnvironment('API_BASE_URL'),
  hostOverride: const String.fromEnvironment('API_HOST'),
  port: const String.fromEnvironment('API_PORT', defaultValue: '8080'),
);
```

Y agregar el import junto a los otros del proyecto:

```dart
import 'package:smart_warehouse/config/backend_url.dart';
```

- [ ] **Step 6: Analizar y correr tests del root**

Run: `flutter analyze lib test && flutter test`
Expected: `No issues found!` y todos los tests del package root PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/config/backend_url.dart lib/config/ioc_manager.dart test/config/backend_url_test.dart
git commit -m "feat(config): resolver la URL del backend por mismo origen en web

En el server la app web se sirve en /mobile/app/ y el proxy rutea
/auth, /products, /ws al backend. Usar Uri.base.origin evita CORS y
que la imagen quede atada a un host. localhost sigue apuntando a :8080
para flutter run -d chrome.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: Página de preview, nginx y Dockerfile

**Files:**
- Create: `deploy/preview.html`
- Create: `deploy/nginx.conf`
- Create: `Dockerfile`
- Create: `.dockerignore`

**Interfaces:**
- Consumes: `build/web` generado con `flutter build web --release --base-href /mobile/app/`.
- Produces: imagen que sirve `/` (preview) y `/app/` (la app). `ARG APP_VERSION` (default `dev`) reemplaza `__APP_VERSION__` en la página.

Requiere Docker Desktop corriendo (`open -a Docker` si `docker info` falla).

- [ ] **Step 1: Página de preview**

```html
<!-- deploy/preview.html -->
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Smart Warehouse — preview</title>
  <style>
    :root { color-scheme: dark; }
    html, body { margin: 0; height: 100%; background: #111; font-family: system-ui, sans-serif; }
    body { display: flex; align-items: center; justify-content: center; }
    .phone {
      position: relative; width: 390px; height: 844px; padding: 14px;
      background: #000; border-radius: 48px;
      box-shadow: 0 30px 80px rgba(0, 0, 0, .6);
    }
    .notch {
      position: absolute; top: 14px; left: 50%; transform: translateX(-50%);
      width: 120px; height: 34px; background: #000; border-radius: 0 0 20px 20px; z-index: 2;
    }
    iframe { width: 100%; height: 100%; border: 0; border-radius: 36px; background: #fff; }
    .version { position: fixed; right: 12px; bottom: 10px; color: #666; font-size: 12px; }
    /* En un celular real no tiene sentido el marco: la app ocupa todo. */
    @media (max-width: 430px), (max-height: 880px) {
      .phone { width: 100%; height: 100%; padding: 0; border-radius: 0; box-shadow: none; }
      .notch, .version { display: none; }
      iframe { border-radius: 0; }
    }
  </style>
</head>
<body>
  <div class="phone">
    <div class="notch"></div>
    <iframe src="app/" title="Smart Warehouse"></iframe>
  </div>
  <div class="version">__APP_VERSION__</div>
</body>
</html>
```

- [ ] **Step 2: nginx.conf**

```nginx
# deploy/nginx.conf
# Sirve la página de preview en / y la app Flutter web en /app/.
# El proxy (Caddy) monta este contenedor bajo /mobile/ y quita el prefijo
# antes de llegar acá; la app está compilada con --base-href /mobile/app/ así
# que sus assets vuelven a pedir /mobile/app/... y sobreviven al strip.
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Fallback SPA: rutas profundas de la app (/app/orders/3) sirven la app.
    location /app/ {
        try_files $uri $uri/ /app/index.html;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

- [ ] **Step 3: Dockerfile y .dockerignore**

```dockerfile
# Dockerfile
# Empaqueta un build web YA compilado (flutter build web --release
# --base-href /mobile/app/) en nginx. No compila Flutter: el workflow lo hace
# con el SDK pineado de CI y no hay imagen pública de Flutter 3.47.
FROM nginx:alpine

ARG APP_VERSION=dev

COPY build/web /usr/share/nginx/html/app
COPY deploy/preview.html /usr/share/nginx/html/index.html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

RUN sed -i "s/__APP_VERSION__/${APP_VERSION}/" /usr/share/nginx/html/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```
# .dockerignore
# Solo entra lo que la imagen copia.
*
!build/web
!build/web/**
!deploy/
!deploy/**
```

- [ ] **Step 4: Build local y verificación con curl**

Run:

```bash
flutter build web --release --base-href /mobile/app/
docker build -t sw-mobile:test --build-arg APP_VERSION=v9.9.9-test .
docker run -d --rm --name sw-mobile-test -p 8090:80 sw-mobile:test
sleep 1
curl -sf http://localhost:8090/ | grep -c 'v9.9.9-test'
curl -sf http://localhost:8090/app/ | grep -c '<base href="/mobile/app/">'
curl -sf -o /dev/null -w '%{http_code}\n' http://localhost:8090/app/orders/3
curl -sf -o /dev/null -w '%{http_code}\n' http://localhost:8090/app/flutter_bootstrap.js
docker build -t sw-mobile:nover . && docker run --rm sw-mobile:nover cat /usr/share/nginx/html/index.html | grep -c '>dev<'
docker stop sw-mobile-test
```

Expected, en orden: `1`, `1`, `200`, `200`, `1`. Si `grep -c` da `0` el placeholder o el base href no se aplicaron.

- [ ] **Step 5: Commit**

```bash
git add deploy/preview.html deploy/nginx.conf Dockerfile .dockerignore
git commit -m "feat(deploy): imagen nginx con la app web y página de preview con marco de celular

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: Compose de producción, Makefile y .env.example

**Files:**
- Create: `docker-compose.prod.yml`
- Create: `.env.example`
- Modify: `Makefile` (línea 1 `.PHONY` y agregar targets después de `dev:`)

**Interfaces:**
- Produces: `make up-prod`, `make deploy`, `make build-web-image`, `make logs`. `reconcile.sh` de wh-autodeploys llama a `make up-prod` y `make deploy` y exige que exista `.env`.

- [ ] **Step 1: docker-compose.prod.yml**

```yaml
# docker-compose.prod.yml
# Producción: docker compose -f docker-compose.prod.yml up -d
# El proxy Caddy (wh-autodeploys) es el único con puerto de host: rutea
# /mobile/* acá quitando el prefijo. La app llama al backend con paths
# relativos al origen (/auth, /products, /ws), que Caddy manda al backend.
services:
  mobile:
    image: ghcr.io/warehouse-usal/smartwarehouse:latest
    restart: always
    networks:
      - wh-proxy

networks:
  wh-proxy:
    external: true
```

- [ ] **Step 2: .env.example**

```
# Vacío a propósito. La app web no lee variables en runtime: la URL del
# backend es el origen de la página (ver lib/config/backend_url.dart).
# El reconcile de wh-autodeploys exige que exista .env para desplegar:
#   cp /opt/wh/SmartWarehouse/.env.example /opt/wh/SmartWarehouse/.env
```

- [ ] **Step 3: Makefile**

Cambiar la primera línea a:

```make
.PHONY: setup generate analyze test clean dev pr-checks e2e e2e-android e2e-ios build-web-image up-prod deploy logs help
```

Y agregar después del target `dev:` (antes de `pr-checks:`):

```make
# ─── Preview web en el server (ver docs/superpowers/specs/2026-09-23-mobile-web-preview-deploy-design.md)

build-web-image: ## Build web con base /mobile/app/ y la imagen nginx local (sw-mobile:local)
	flutter build web --release --base-href /mobile/app/
	docker build -t sw-mobile:local --build-arg APP_VERSION=local .
	@echo "Probar con: docker run --rm -p 8090:80 sw-mobile:local  ->  http://localhost:8090/"

up-prod: ## Start the nginx container (served under /mobile behind the proxy)
	docker compose -f docker-compose.prod.yml up -d
	@echo "Mobile web started (container mobile:80)"

deploy: ## Pull the newest image and restart
	docker compose -f docker-compose.prod.yml pull
	docker compose -f docker-compose.prod.yml up -d
	@echo "Mobile web redeployed"

logs: ## Follow the mobile web container logs
	docker compose -f docker-compose.prod.yml logs -f mobile
```

- [ ] **Step 4: Verificar targets y compose**

Run:

```bash
make help | grep -E 'build-web-image|up-prod|deploy|logs'
docker compose -f docker-compose.prod.yml config --quiet && echo compose-ok
make build-web-image
```

Expected: los cuatro targets listados, `compose-ok`, y el build local termina en `Probar con: ...`. (`up-prod` no se prueba en local: la red `wh-proxy` solo existe en el server.)

- [ ] **Step 5: Commit**

```bash
git add docker-compose.prod.yml .env.example Makefile
git commit -m "feat(deploy): compose de producción y targets make para el server

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Stable Release construye y publica la imagen

**Files:**
- Modify: `.github/workflows/stable-release.yml` (reescritura completa, ver abajo)

**Interfaces:**
- Produces: imagen `ghcr.io/warehouse-usal/smartwarehouse:{<version>,latest}` en cada release estable. El job `gate` expone `outputs.version`.

- [ ] **Step 1: Reescribir el workflow**

Reemplazar el archivo entero por:

```yaml
name: Stable Release

# Trigger por push a master (no pull_request:closed): con ese evento GitHub
# resuelve el reusable workflow local (backport.yml) contra el merge-ref del
# PR, que ya no existe despues del merge -> startup_failure (v1.0.0 se
# publico a mano por esto). El push del merge commit no tiene ese problema.
on:
  push:
    branches:
      - master
  workflow_dispatch:
    inputs:
      version:
        description: 'Version a releasear (ej: v1.0.1). Vacio: derivar del ultimo merge.'
        required: false
        type: string

# URL del backend a la que apunta el APK estable. Configurar el secret
# API_BASE_URL en el repo. Si está vacío, el APK usa los defaults locales
# hardcoded (10.0.2.2:8080) — útil solo para desarrollo, NO para release.
# El build web NO la usa: resuelve el backend por el origen de la página
# (lib/config/backend_url.dart) porque se sirve detrás del mismo proxy.
env:
  API_BASE_URL: ${{ secrets.API_BASE_URL }}

jobs:
  gate:
    name: Verify release conditions
    # push: solo merges de beta/ o hotfix/ (gitflow: master no recibe otra cosa).
    if: >
      github.event_name == 'workflow_dispatch' ||
      contains(github.event.head_commit.message, 'beta/') ||
      contains(github.event.head_commit.message, 'hotfix/')
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.tag.outputs.version }}
    steps:
      - name: Derive stable version tag
        id: tag
        env:
          INPUT_VERSION: ${{ inputs.version }}
          COMMIT_MSG: ${{ github.event.head_commit.message }}
        run: |
          if [[ -n "$INPUT_VERSION" ]]; then
            VERSION="${INPUT_VERSION#v}"
          else
            # El merge commit de master dice "... from <owner>/beta/vX.Y.Z"
            VERSION=$(echo "$COMMIT_MSG" | grep -oE '(beta|hotfix)/[^ ]+' | head -1 | cut -d/ -f2-)
            [[ -n "$VERSION" ]] || { echo "ERROR: no pude derivar la version del commit: $COMMIT_MSG" >&2; exit 1; }
            VERSION="${VERSION#v}"
          fi
          echo "version=v${VERSION}" >> "$GITHUB_OUTPUT"
          echo "Stable version: v${VERSION}"

  build-web:
    name: Build Web
    needs: gate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Activate melos
        run: dart pub global activate melos

      - name: Bootstrap packages
        run: melos bootstrap

      # Base href fijo: el server sirve la app en /mobile/app/ (ver Dockerfile
      # y deploy/nginx.conf). Sin API_BASE_URL: mismo origen que el proxy.
      - name: Build web
        run: flutter build web --release --base-href /mobile/app/

      - name: Zip web build
        run: zip -r smart-warehouse-web.zip build/web

      - name: Upload web artifact
        uses: actions/upload-artifact@v4
        with:
          name: web-build
          path: smart-warehouse-web.zip

  build-image:
    name: Build and push web image
    needs: [gate, build-web]
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Download web artifact
        uses: actions/download-artifact@v4
        with:
          name: web-build
          path: .

      - name: Unzip web build
        run: unzip -q smart-warehouse-web.zip && test -f build/web/index.html

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        env:
          VERSION: ${{ needs.gate.outputs.version }}
        run: |
          IMAGE="ghcr.io/$(echo '${{ github.repository_owner }}' | tr '[:upper:]' '[:lower:]')/smartwarehouse"
          docker build --build-arg APP_VERSION="${VERSION}" \
                       -t "${IMAGE}:${VERSION}" -t "${IMAGE}:latest" .
          docker push "${IMAGE}:${VERSION}"
          docker push "${IMAGE}:latest"

  build-android:
    name: Build Android
    needs: gate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Activate melos
        run: dart pub global activate melos

      - name: Bootstrap packages
        run: melos bootstrap

      - name: Build APK
        run: |
          ARGS=""
          if [ -n "${API_BASE_URL}" ]; then
            ARGS="--dart-define=API_BASE_URL=${API_BASE_URL}"
            echo "Building APK with API_BASE_URL=${API_BASE_URL}"
          fi
          flutter build apk --release $ARGS

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: android-build
          path: build/app/outputs/flutter-apk/app-release.apk

  stable-release:
    name: Publish stable release
    needs: [gate, build-web, build-image, build-android]
    runs-on: ubuntu-latest
    permissions:
      contents: write

    outputs:
      version: ${{ needs.gate.outputs.version }}

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Download web artifact
        uses: actions/download-artifact@v4
        with:
          name: web-build
          path: .

      - name: Download android artifact
        uses: actions/download-artifact@v4
        with:
          name: android-build
          path: .

      - name: Create git tag
        env:
          VERSION: ${{ needs.gate.outputs.version }}
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git tag "$VERSION"
          git push origin "$VERSION"

      - name: Create stable release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ needs.gate.outputs.version }}
          name: Release ${{ needs.gate.outputs.version }}
          prerelease: false
          files: |
            smart-warehouse-web.zip
            app-release.apk
          generate_release_notes: true

  trigger-backport:
    name: Trigger backport to develop
    needs: stable-release
    uses: ./.github/workflows/backport.yml
    with:
      version: ${{ needs.stable-release.outputs.version }}
```

Antes de pegar, comparar con el archivo actual (`git diff` después de escribir): la única diferencia fuera de `gate`, `build-web`, `build-image` y las referencias a `needs.gate.outputs.version` debería ser ninguna. Si el archivo actual tiene algo entre `Create stable release` y `trigger-backport` que no está acá, conservarlo.

- [ ] **Step 2: Validar sintaxis**

Run:

```bash
python3 -c "import yaml,sys; d=yaml.safe_load(open('.github/workflows/stable-release.yml')); print(sorted(d['jobs']))"
which actionlint >/dev/null && actionlint .github/workflows/stable-release.yml || echo "actionlint no instalado (brew install actionlint), sigo con yaml ok"
git diff --stat .github/workflows/stable-release.yml
```

Expected: `['build-android', 'build-image', 'build-web', 'gate', 'stable-release', 'trigger-backport']`; sin errores de actionlint si está.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/stable-release.yml
git commit -m "feat(release): publicar imagen web a GHCR en cada release estable

El build web pasa a base-href /mobile/app/ y sin API_BASE_URL (mismo
origen). La versión se deriva en gate y la consumen build-image y
stable-release.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: Workflow de deploy al server

**Files:**
- Create: `.github/workflows/deploy.yml`

**Interfaces:**
- Consumes: imagen `latest` en GHCR (Task 4), `make deploy` (Task 3), runner `[self-hosted, prod]` y clone en `/opt/wh/SmartWarehouse` (Task 7).

- [ ] **Step 1: Escribir el workflow**

```yaml
name: Deploy

# Se dispara cuando termina "Stable Release". workflow_run (no
# release:published) porque los releases creados con GITHUB_TOKEN no emiten
# eventos de release. workflow_dispatch permite redeploys manuales.
# Calcado de smarthouse_webapp/.github/workflows/deploy.yml.
on:
  workflow_run:
    workflows: ["Stable Release"]
    types: [completed]
  workflow_dispatch:

concurrency:
  group: deploy-mobile
  cancel-in-progress: true

jobs:
  deploy:
    name: Deploy mobile web preview to server
    if: ${{ github.event_name == 'workflow_dispatch' || github.event.workflow_run.conclusion == 'success' }}
    runs-on: [self-hosted, prod]
    environment: production
    permissions:
      contents: read
      packages: read
      pull-requests: write
      issues: write
    env:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      REPO: ${{ github.repository }}
      RUN_URL: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
    steps:
      - name: Resolve commit, tag, and PR
        id: ctx
        run: |
          cd /opt/wh/SmartWarehouse
          git fetch --tags --force --prune origin
          # Deploy del master publicado. workflow_run.head_sha es el commit de la
          # rama del PR, que ya no existe después del merge: resolver master.
          SHA=$(git rev-parse origin/master)
          TAG=$(git tag --points-at "$SHA" | grep -E '^v' | head -1)
          [ -n "$TAG" ] || TAG="${SHA:0:7}"
          PR=$(curl -fsS -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github+json" \
                "https://api.github.com/repos/$REPO/commits/$SHA/pulls" | jq -r '.[0].number // empty')
          echo "sha=$SHA" >> "$GITHUB_OUTPUT"
          echo "tag=$TAG" >> "$GITHUB_OUTPUT"
          echo "pr=$PR"   >> "$GITHUB_OUTPUT"
          echo "deploying $SHA ($TAG); PR=${PR:-none}"

      - name: Comment — deploy started
        if: steps.ctx.outputs.pr != ''
        run: |
          body=$(printf '🚀 **Deploy started** — `%s` → server (/mobile/).\n\n[Watch the run](%s)' "${{ steps.ctx.outputs.tag }}" "$RUN_URL")
          jq -nc --arg b "$body" '{body:$b}' | curl -fsS -X POST -H "Authorization: Bearer $GH_TOKEN" \
            "https://api.github.com/repos/$REPO/issues/${{ steps.ctx.outputs.pr }}/comments" -d @-

      - name: Log in to GHCR
        run: echo "$GH_TOKEN" | docker login ghcr.io -u "${{ github.actor }}" --password-stdin

      - name: Deploy
        id: deploy
        run: |
          cd /opt/wh/SmartWarehouse
          set -o pipefail
          # reset --hard al commit publicado para que drift local nunca bloquee.
          { git reset --hard "${{ steps.ctx.outputs.sha }}" \
              && git clean -fd \
              && make deploy; } 2>&1 | tee /tmp/wh-deploy-mobile.log

      - name: Verify preview and app are serving
        run: |
          for i in $(seq 1 18); do
            if docker run --rm --network wh-proxy curlimages/curl:latest -sf -o /dev/null http://mobile/ \
               && docker run --rm --network wh-proxy curlimages/curl:latest -sf -o /dev/null http://mobile/app/; then
              echo "mobile web serving"; exit 0
            fi
            sleep 5
          done
          echo "mobile web did not serve within timeout — appending logs:" | tee -a /tmp/wh-deploy-mobile.log
          docker logs --tail 60 "$(docker ps -qf name=mobile | head -1)" 2>&1 | tail -50 >> /tmp/wh-deploy-mobile.log
          exit 1

      - name: Comment — deploy succeeded
        if: success() && steps.ctx.outputs.pr != ''
        run: |
          img=$(docker inspect -f '{{.Image}}' "$(docker ps -qf name=mobile | head -1)" 2>/dev/null || echo unknown)
          body=$(printf '✅ **Deploy succeeded** — `%s` is live at /mobile/.\nImage: `%s`\n\n[Run](%s)' "${{ steps.ctx.outputs.tag }}" "$img" "$RUN_URL")
          jq -nc --arg b "$body" '{body:$b}' | curl -fsS -X POST -H "Authorization: Bearer $GH_TOKEN" \
            "https://api.github.com/repos/$REPO/issues/${{ steps.ctx.outputs.pr }}/comments" -d @-

      - name: Comment — deploy failed
        if: failure() && steps.ctx.outputs.pr != ''
        run: |
          log=$(tail -c 2500 /tmp/wh-deploy-mobile.log 2>/dev/null || echo 'no deploy log captured')
          body=$(printf '❌ **Deploy FAILED** — `%s`.\n\n```\n%s\n```\n\n[Run](%s)' "${{ steps.ctx.outputs.tag }}" "$log" "$RUN_URL")
          jq -nc --arg b "$body" '{body:$b}' | curl -fsS -X POST -H "Authorization: Bearer $GH_TOKEN" \
            "https://api.github.com/repos/$REPO/issues/${{ steps.ctx.outputs.pr }}/comments" -d @-
```

- [ ] **Step 2: Validar sintaxis**

Run:

```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/deploy.yml')); print(d['concurrency']['group'], [s['name'] for s in d['jobs']['deploy']['steps']])"
which actionlint >/dev/null && actionlint .github/workflows/deploy.yml || true
```

Expected: `deploy-mobile` y la lista de 7 pasos.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy.yml
git commit -m "feat(deploy): workflow de deploy al server tras cada release estable

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: Smoke test end-to-end local con Caddy y backend, y README

**Files:**
- Create: `deploy/local/Caddyfile` (solo para pruebas locales, se commitea)
- Create: `deploy/local/docker-compose.yml`
- Modify: `README.md` (nueva sección al final)

**Interfaces:**
- Consumes: imagen `sw-mobile:local` (`make build-web-image`, Task 3) y el backend de wh-backend corriendo en el host en `:8080` (`make up` en un clone de `wh-backend`, seed `admin@smartwarehouse.local` / `changeme`).

- [ ] **Step 1: Caddy y compose locales que reproducen el server**

```
# deploy/local/Caddyfile
# Réplica mínima del Caddyfile de wh-autodeploys para probar en local:
# /mobile/* -> este contenedor, el resto -> backend en el host (:8080).
:80 {
	handle_path /mobile/* {
		reverse_proxy mobile:80
	}
	handle {
		reverse_proxy host.docker.internal:8080
	}
}
```

```yaml
# deploy/local/docker-compose.yml
# Uso: make build-web-image && docker compose -f deploy/local/docker-compose.yml up
# Abre http://localhost:8088/mobile/ con el backend de wh-backend en :8080.
services:
  caddy:
    image: caddy:2
    ports:
      - "8088:80"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
    extra_hosts:
      - "host.docker.internal:host-gateway"
  mobile:
    image: sw-mobile:local
```

- [ ] **Step 2: Levantar y probar con el backend real**

Run (con el backend de wh-backend arriba en `:8080`):

```bash
make build-web-image
docker compose -f deploy/local/docker-compose.yml up -d
sleep 2
curl -sf -o /dev/null -w '%{http_code}\n' http://localhost:8088/mobile/
curl -sf -o /dev/null -w '%{http_code}\n' http://localhost:8088/mobile/app/
curl -s -o /dev/null -w '%{http_code}\n' -X POST http://localhost:8088/auth/login -H 'content-type: application/json' -d '{"email":"admin@smartwarehouse.local","password":"changeme"}'
```

Expected: `200`, `200`, y `200` (o el código que devuelva el backend al login; lo importante es que no sea `502`, que sería Caddy sin llegar al backend).

Luego abrir `http://localhost:8088/mobile/` en Chrome, loguearse con `admin@smartwarehouse.local` / `changeme` y sacar captura del login y del catálogo cargado dentro del marco. Guardar las capturas en el scratchpad y adjuntarlas en el PR.

Bajar todo: `docker compose -f deploy/local/docker-compose.yml down`.

Si el backend no está disponible en la máquina, dejar registrado en el PR que el smoke test con backend quedó pendiente y que los curl a `/mobile/` y `/mobile/app/` dieron 200.

- [ ] **Step 3: README**

Agregar al final de `README.md`:

```markdown
## Preview web en el server

Cada release estable publica la app compilada para web como imagen
`ghcr.io/warehouse-usal/smartwarehouse` y el server del equipo la sirve en
`http://<server>/mobile/`: una página con un celular embebido donde corre la
app real contra el backend, sin instalar el APK. `http://<server>/mobile/app/`
es la app a pantalla completa. El APK sigue adjunto al release como siempre.

- La URL del backend en web es el origen de la página (`lib/config/backend_url.dart`),
  así que no hay CORS ni configuración por host.
- Flujo: `stable-release.yml` compila web con `--base-href /mobile/app/`,
  arma la imagen (`Dockerfile`, `deploy/`) y la pushea a GHCR; al terminar,
  `deploy.yml` corre en el runner del server y hace `make deploy`.
- Infra (Caddy, runner, reconcile) vive en `Warehouse-USAL/wh-autodeploys`.

Probar en local igual que en el server (backend de wh-backend en `:8080`):

```bash
make build-web-image
docker compose -f deploy/local/docker-compose.yml up -d
open http://localhost:8088/mobile/
```
```

- [ ] **Step 4: Commit**

```bash
git add deploy/local/Caddyfile deploy/local/docker-compose.yml README.md
git commit -m "docs(deploy): smoke test local con Caddy y sección de preview web en README

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: PR en wh-autodeploys (ruta Caddy, runner y reconcile)

**Files (repo `Warehouse-USAL/wh-autodeploys`, clonar en el scratchpad de la sesión):**
- Modify: `Caddyfile`
- Modify: `docker-compose.yml`
- Modify: `scripts/reconcile.sh:11`
- Modify: `README.md`

**Interfaces:**
- Produces: `handle_path /mobile/*` a `mobile:80`, runner `runner-mobile` registrado en `Warehouse-USAL/SmartWarehouse`, `SmartWarehouse` en `APPS`.

Cuenta gh: `julisanchezos` no tiene write. Usar `gh auth switch --user sanchezjulian1-usal` para pushear la rama y volver con `gh auth switch --user julisanchezos` al terminar. Si tampoco tiene write en este repo, forkear y abrir el PR desde el fork.

- [ ] **Step 1: Clonar**

```bash
cd "$SCRATCHPAD" && gh repo clone Warehouse-USAL/wh-autodeploys && cd wh-autodeploys
git checkout -b feat/mobile-preview
```

- [ ] **Step 2: Caddyfile**

Agregar antes del bloque `# Everything else → the backend at root.`:

```
	# Mobile app (Flutter web) under /mobile — prefix stripped; built with
	# --base-href /mobile/app/. /mobile/ is a phone-frame preview page, /mobile/app/ the app.
	handle_path /mobile/* {
		reverse_proxy mobile:80
	}
```

Y en el comentario de cabecera, junto a `/dashboard/*  -> dashboard`, la línea `#   /mobile/*     -> mobile app web preview (SmartWarehouse)`.

- [ ] **Step 3: docker-compose.yml**

Agregar después de `runner-webapp`:

```yaml
  runner-mobile:
    build: ./runner
    environment:
      RUNNER_SCOPE: repo
      REPO_URL: https://github.com/${GH_OWNER:?set GH_OWNER}/SmartWarehouse
      ACCESS_TOKEN: ${GH_PAT:?set GH_PAT}
      RUNNER_NAME: ${RUNNER_NAME_PREFIX:-wh}-mobile
      LABELS: ${RUNNER_LABELS:-prod}
      RUNNER_WORKDIR: /opt/wh/_work/SmartWarehouse
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/wh:/opt/wh
    restart: always
```

- [ ] **Step 4: reconcile.sh**

Línea 11: `APPS=(wh-backend Dashboard smarthouse_webapp SmartWarehouse)`.

- [ ] **Step 5: README**

En la tabla de componentes, en la fila de `caddy`, agregar `/mobile/*` → mobile app preview. En la fila de runners, sumar `runner-mobile`. En el bloque de `cp` de app config agregar:

```bash
cp /opt/wh/SmartWarehouse/.env.example    /opt/wh/SmartWarehouse/.env     # vacío: la app web no lee env
```

Y en el `.env.example` del repo, en el comentario de nombres de runner, sumar `<prefix>-mobile`.

- [ ] **Step 6: Validar y abrir PR**

```bash
docker compose config --quiet && echo compose-ok
docker run --rm -v "$PWD/Caddyfile:/etc/caddy/Caddyfile:ro" caddy:2 caddy validate --config /etc/caddy/Caddyfile
bash -n scripts/reconcile.sh && echo sh-ok
git add -A && git commit -m "feat: servir la preview web de SmartWarehouse en /mobile/

Ruta en Caddy, runner self-hosted para el repo y SmartWarehouse en el
reconcile. Requiere .env (vacío) en /opt/wh/SmartWarehouse.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
gh auth switch --user sanchezjulian1-usal
git push -u origin feat/mobile-preview
gh pr create --title "feat: preview web de SmartWarehouse en /mobile/" --body "$(cat <<'EOF'
Suma la app mobile (Flutter web) al server, bajo `/mobile/`, con el mismo patrón que webapp y dashboard.

- Caddy: `handle_path /mobile/*` → `mobile:80`
- `runner-mobile` para `Warehouse-USAL/SmartWarehouse`
- `SmartWarehouse` en `APPS` de reconcile
- README: ruta y `cp .env.example .env`

Depende de que SmartWarehouse publique la imagen `ghcr.io/warehouse-usal/smartwarehouse` (PR en ese repo). Después de mergear: `docker compose up -d --build` en el box y crear `/opt/wh/SmartWarehouse/.env`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
gh auth switch --user julisanchezos
```

Expected: `compose-ok`, `Valid configuration`, `sh-ok`, URL del PR.

---

### Task 8: PR en SmartWarehouse

- [ ] **Step 1: Verificación final**

Run: `make pr-checks && flutter build web --release --base-href /mobile/app/`
Expected: analyze limpio, tests verdes, build ok.

- [ ] **Step 2: Push y PR contra `develop`**

Seguir la regla del repo (memoria: mergear vía fork, cuenta `julisanchezos`). Título: `feat(deploy): preview web con marco de celular en el server`. En el cuerpo: link al spec, las capturas del smoke test de Task 6, el link al PR de wh-autodeploys, y el checklist post-merge: (1) mergear wh-autodeploys y `docker compose up -d --build` en el box, (2) `cp .env.example .env` en `/opt/wh/SmartWarehouse`, (3) release estable desde `beta/` para que salga la primera imagen y el deploy. Terminar con `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
