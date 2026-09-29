/// URL base del backend.
///
/// Precedencia (de mayor a menor):
/// 1. [fullOverride] (`--dart-define=API_BASE_URL=https://api.example.com`):
///    URL completa con scheme. Se respeta tal cual. La usa el APK de release.
/// 2. [hostOverride] + [port] (`--dart-define=API_HOST=192.168.1.10
///    --dart-define=API_PORT=8080`): device físico en red local, asume http.
/// 3. Web servida desde un host que no es localhost, o con [sameOrigin]
///    (`--dart-define=WEB_SAME_ORIGIN=true`, el build para el proxy): el
///    origen de la página ([base]). En el server la app vive en
///    `http://<host>/mobile/app/` y el proxy rutea `/auth`, `/products`, `/ws`
///    al backend. Mismo origen, sin CORS. [sameOrigin] cubre el caso de
///    llegar al proxy por localhost (smoke test local, túnel ssh). Si el
///    scheme no es http/https (file://, tests) se cae al default.
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
  bool sameOrigin = false,
}) {
  if (fullOverride.isNotEmpty) return fullOverride;
  if (hostOverride.isNotEmpty) return 'http://$hostOverride:$port';

  if (isWeb) {
    final isHttp = base.scheme == 'http' || base.scheme == 'https';
    final isLocal = base.host == 'localhost' || base.host == '127.0.0.1';
    if (isHttp && (sameOrigin || !isLocal)) return base.origin;
    return 'http://localhost:$port';
  }

  final host = isAndroid ? '10.0.2.2' : 'localhost';
  return 'http://$host:$port';
}
