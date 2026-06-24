import 'package:commons/helpers/http/http_helper.dart';
import 'package:commons/helpers/injector/injector.dart';

/// Resuelve un `imageUrl` del back a una URL absoluta cargable por
/// `Image.network`.
///
/// El back puede devolver dos formas:
/// - **Absoluta**: `https://picsum.photos/...` (productos seedeados) →
///   se devuelve tal cual.
/// - **Relativa**: `/api/v1/files/images/abc.png` (productos con imagen
///   uploadeada por MinIO via POST /api/v1/files/upload) → necesita el
///   baseUrl del backend prependeado para resolverse desde el cliente.
///
/// Si `baseUrl` no se pasa explícito, se toma del `HttpHelper` registrado
/// en el Injector. Si la URL no es ni absoluta ni empieza con `/`, se
/// devuelve tal cual (defensa contra valores raros).
class ImageUrlResolver {
  const ImageUrlResolver._();

  static String? resolve(String? raw, {String? baseUrl}) {
    if (raw == null || raw.isEmpty) return null;
    // Absoluta: http(s) o data: → no tocar.
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('data:')) {
      return raw;
    }
    // Relativa al back: prependear baseUrl.
    if (raw.startsWith('/')) {
      final base = baseUrl ?? _resolveBaseUrlFromInjector();
      if (base == null) return raw;
      // Normalizar slashes para no terminar con //.
      final trimmedBase = base.endsWith('/')
          ? base.substring(0, base.length - 1)
          : base;
      return '$trimmedBase$raw';
    }
    // No tiene shape conocida — devolver tal cual y dejar que la red lo
    // resuelva o tire un error visible.
    return raw;
  }

  static String? _resolveBaseUrlFromInjector() {
    try {
      return Injector.i.resolve<HttpHelper>().baseUrl;
    } catch (_) {
      return null;
    }
  }
}
