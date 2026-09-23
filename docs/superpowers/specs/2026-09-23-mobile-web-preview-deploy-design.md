# Preview web de la app mobile en el server (marco de celular)

Fecha: 2026-09-23

## Objetivo

Que cada release estable de SmartWarehouse quede accesible en el server del
equipo como Flutter web, dentro de una página con marco de celular, para
probar la app sin instalar el APK. El APK sigue generándose y adjuntándose al
release como hoy; esto no lo reemplaza.

## Contexto (cómo despliegan los otros repos)

- `wh-autodeploys` es el server: Caddy en `:80` rutea `/app/*` a la webapp,
  `/dashboard/*` al dashboard y todo lo demás al backend en la raíz. Cada app
  tiene un runner self-hosted de GitHub Actions como contenedor, con el socket
  de Docker montado, y un `reconcile.sh` que converge cada app a su último
  release.
- `smarthouse_webapp` construye su SPA con `base: '/app/'`, la empaqueta en
  una imagen nginx (fallback SPA), la pushea a GHCR en Stable Release, y un
  `deploy.yml` disparado por `workflow_run` hace `docker compose pull && up -d`
  en el runner.
- El backend no configura CORS. Las SPAs llaman a la API con paths relativos
  (`/auth`, `/products`, `/ws`) y Caddy los enruta al backend: mismo origen.
- Este repo ya compila web en `stable-release.yml` y adjunta
  `smart-warehouse-web.zip` al release, pero nadie lo sirve.
- Verificado el 2026-09-23: `flutter build web --release --base-href /mobile/`
  compila en `develop` y la app levanta en un iframe con marco de celular.

## Alcance

Entra:

1. Imagen Docker de la app web publicada en GHCR en cada release estable.
2. Página de preview: la app corriendo dentro de un marco de celular.
3. Resolución de la URL del backend por mismo origen cuando corre en web.
4. `docker-compose.prod.yml`, `deploy.yml` y target `make deploy` en este
   repo, calcados de `smarthouse_webapp`.
5. Cambios en `wh-autodeploys` (PR aparte): ruta en Caddy, runner y reconcile.

No entra:

- Deploy de `develop` ni previews por PR.
- Cambios en `local_auth`, `vibration`, `image_picker` ni en los tres archivos
  con `dart:io`, salvo que el build web o el smoke test lo exijan.
- HTTPS o dominio público (Caddy lo resuelve solo cuando se exponga).

## Diseño

### 1. Imagen Docker (`Dockerfile` en la raíz del repo)

La imagen no compila Flutter: solo empaqueta un `build/web` ya construido.
Razones: el workflow ya compila web con `subosito/flutter-action` pineado al
mismo SDK que CI, y las imágenes públicas de Flutter (`cirruslabs/flutter`)
no ofrecen la 3.47.0 que usa el equipo. Así el build es uno solo, rápido y
reproducible en local con los mismos comandos.

- Etapa única `nginx:alpine`. Copia `build/web` a `/usr/share/nginx/html/app/`,
  copia `deploy/preview.html` a `/usr/share/nginx/html/index.html`
  reemplazando el placeholder `__APP_VERSION__` con `sed` (`ARG APP_VERSION`,
  default `dev`), y `deploy/nginx.conf` con:
  - `location /app/ { try_files $uri $uri/ /app/index.html; }` (fallback SPA)
  - `location / { try_files $uri $uri/ /index.html; }` (la página de preview)
- El `build/web` se genera antes con
  `flutter build web --release --base-href /mobile/app/`, sin
  `--dart-define=API_BASE_URL` (la URL se resuelve por mismo origen, sección
  3). El APK sigue recibiendo `API_BASE_URL` como hoy.
- Los archivos de la página viven en `deploy/`, no en `web/`, porque Flutter
  copia todo `web/` dentro de `build/web` y quedarían servidos bajo la app.

Caddy hace `handle_path /mobile/*`, o sea quita el prefijo antes de llegar al
contenedor. Por eso nginx sirve desde la raíz pero el build usa
`--base-href /mobile/app/`: los assets se piden como `/mobile/app/...`,
Caddy los enruta acá y sobreviven al strip.

`.dockerignore` deja pasar solo `build/web` y `deploy/`.

### 2. Página de preview (`web/preview/index.html`)

HTML y CSS puros, sin frameworks. Contiene:

- Solo el marco de celular de 390x844, centrado, con bordes redondeados y
  notch, y un `iframe` con `src="app/"` (relativo, así funciona bajo
  `/mobile/`). La app real corre adentro. Sin barra ni links.
- Un texto discreto con la versión desplegada (placeholder `__APP_VERSION__`)
  en una esquina, para saber qué release se está probando.
- En viewports angostos (menos de 430px de ancho) el marco desaparece y el
  iframe ocupa toda la pantalla, para que también sirva desde un teléfono.

### 3. URL del backend en web (`lib/config/ioc_manager.dart`)

`_localBackendUrl()` mantiene la precedencia actual (`API_BASE_URL`, luego
`API_HOST`/`API_PORT`). Cambia solo el default en `kIsWeb`:

- Si `Uri.base.host` es `localhost` o `127.0.0.1`, se conserva
  `http://localhost:$overridePort` (desarrollo con `flutter run -d chrome`).
- En cualquier otro host, se usa `Uri.base.origin`. En el server la página
  vive en `http://<host>/mobile/app/`, así que las llamadas van a
  `http://<host>/auth` y Caddy las manda al backend. Mismo origen, sin CORS.

El WebSocket de order_tracking reemplaza `http` por `ws` sobre esa misma base,
así que llega a `ws://<host>/ws`, que Caddy ya proxea al backend.

La lógica se extrae a una función pura `resolveBackendUrl({required bool
isWeb, required Uri base, required bool isAndroid, String fullOverride,
String host, String port})` con test unitario en `test/config/`.

### 4. Deploy en este repo

- `docker-compose.prod.yml`: servicio `mobile`, imagen
  `ghcr.io/warehouse-usal/smartwarehouse:latest`, `restart: always`, red
  externa `wh-proxy`, sin puertos de host.
- `Makefile`: targets `up-prod` (`docker compose -f docker-compose.prod.yml
  up -d`), `deploy` (`pull` y luego `up -d`) y `build-web-image` (build web
  con el base-href y `docker build`), siguiendo el Makefile de
  `smarthouse_webapp`. `reconcile.sh` invoca `make up-prod` y `make deploy`.
- `.env.example` vacío salvo comentarios: `reconcile.sh` se niega a
  desplegar una app sin `.env` en el server, así que hay que dejar uno para
  copiar aunque la app no lea variables.
- `stable-release.yml`: el job `build-web` pasa a compilar con
  `--base-href /mobile/app/` y sin `API_BASE_URL`. Nuevo job `build-image`
  (needs `gate` y `build-web`) que descarga el artifact `web-build`, lo
  descomprime en `build/web`, hace login a GHCR con `GITHUB_TOKEN`,
  `docker build --build-arg APP_VERSION=<tag>` con tags `<version>` y
  `latest`, y push. El paso "Derive stable version tag"
  se mueve del job `stable-release` al job `gate`, que lo expone como output
  `version`; `build-image` y `stable-release` lo consumen desde ahí. El job
  `stable-release` pasa a depender también de `build-image`. `build-web` y
  `build-android` quedan como están.
- `.github/workflows/deploy.yml`: copia del de `smarthouse_webapp` con
  `cd /opt/wh/SmartWarehouse`, grupo de concurrencia `deploy-mobile`,
  verificación `curl -sf http://mobile/` y `http://mobile/app/` desde la red
  `wh-proxy`, y comentarios de inicio/éxito/fallo en el PR.

### 5. Infra (`wh-autodeploys`, PR aparte)

- `Caddyfile`: `handle_path /mobile/* { reverse_proxy mobile:80 }` antes del
  `handle` del backend.
- `docker-compose.yml`: servicio `runner-mobile` igual a `runner-webapp` con
  `REPO_URL=.../SmartWarehouse` y `RUNNER_WORKDIR=/opt/wh/_work/SmartWarehouse`.
- `scripts/reconcile.sh`: agregar `SmartWarehouse` a `APPS`.
- README: fila para `/mobile/*` y línea `cp /opt/wh/SmartWarehouse/.env.example
  /opt/wh/SmartWarehouse/.env` en la sección de app config.

## Manejo de errores

- Si el build web falla, falla la release entera (como hoy con el APK).
- Si el deploy falla, el workflow comenta el log en el PR y sale con error;
  el contenedor anterior sigue corriendo porque `compose up -d` solo recrea
  al tener la imagen nueva.
- Si la app web no puede hablar con el backend, el login muestra el error de
  red que ya existe; no se agrega manejo especial.

## Verificación

1. `flutter test test/config/` verde con casos: override absoluto, host/port,
   web en localhost, web en otro host, Android, desktop.
2. `make build-web-image` local y `docker run -p 8090:80`: `curl` a `/`,
   `/app/` y a una ruta profunda como `/app/orders/1` devuelven 200 con HTML.
   Luego, detrás de un Caddy mínimo con el backend local (`docker-compose.yml`
   de `wh-backend`) reproduciendo el ruteo `/mobile/*` y raíz: screenshot de
   login y de catálogo cargado.
3. CI del repo verde. Después del primer release, el `deploy.yml` comenta
   éxito en el PR y `http://<server>/mobile/` responde.

## Orden de entrega

1. PR en SmartWarehouse: sección 3 (URL) con tests, luego 1, 2 y 4.
2. PR en wh-autodeploys: sección 5. Se puede mergear antes del release; el
   runner queda esperando y reconcile ignora la app hasta que exista un
   release con imagen.
3. Release estable desde `beta/`, que dispara build, push y deploy.
