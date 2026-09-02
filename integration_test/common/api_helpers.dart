import 'dart:convert';
import 'dart:io';

import 'config.dart';

/// Helpers HTTP para setup/teardown de los tests e2e, hablando directo con el
/// backend (mismo host que usa la app: 10.0.2.2 en el emulador Android).
///
/// Los tests que crean o modifican datos SIEMPRE deben restaurarlos en
/// teardown (ver docs/e2e-data-contract.md).
abstract final class E2eApi {
  static String get baseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  }

  static Future<String> adminToken() async {
    final body = await _request(
      'POST',
      '/auth/login',
      body: {'email': E2eConfig.email, 'password': E2eConfig.password},
    );
    return body['token'] as String;
  }

  /// Los dos primeros productos del listado (mismo orden que muestra la UI).
  static Future<List<Map<String, dynamic>>> firstProducts(
    String token, {
    int count = 2,
  }) async {
    // El backend pagina 0-indexed (la primera página es page=0).
    final body = await _request(
      'GET',
      '/products?page=0&size=$count',
      token: token,
    );
    return (body['products'] as List).cast<Map<String, dynamic>>();
  }

  /// Un producto de la página [page] (1-indexed, como la ve la UI) del
  /// listado, para asertar paginación. El backend es 0-indexed.
  static Future<Map<String, dynamic>?> productOnPage(
    String token,
    int page, {
    int size = 20,
  }) async {
    final body = await _request(
      'GET',
      '/products?page=${page - 1}&size=$size',
      token: token,
    );
    final products = (body['products'] as List).cast<Map<String, dynamic>>();
    return products.isEmpty ? null : products.first;
  }

  /// Crea un producto temporal (prefijo E2E- en el SKU) y devuelve su id.
  static Future<String> createProduct(
    String token, {
    required String sku,
    required String name,
    String currency = 'ARS',
    int amountCents = 100000,
  }) async {
    final body = await _request(
      'POST',
      '/products',
      token: token,
      body: {
        'sku': sku,
        'name': name,
        'category': 'OTROS',
        'price': {
          'amount_cents': amountCents,
          'currency': currency,
          'tax_included': true,
        },
        'height': 1.0,
        'width': 1.0,
        'length': 1.0,
        'weight': 1.0,
      },
    );
    return (body['product'] as Map<String, dynamic>)['id'] as String;
  }

  static Future<void> deleteProduct(String token, String id) =>
      _request('DELETE', '/products/$id', token: token);

  /// Cambia solo la moneda del precio de un producto. Usado por el test de
  /// mixed-currency; el teardown DEBE restaurar la moneda original.
  static Future<void> patchProductCurrency(
    String token,
    String id, {
    required int amountCents,
    required String currency,
  }) =>
      _request('PATCH', '/products/$id', token: token, body: {
        'price': {
          'amount_cents': amountCents,
          'currency': currency,
          'tax_included': true,
        },
      });

  /// Cancela todas las órdenes en estado `pending` (teardown de los tests de
  /// checkout, para no ensuciar corridas futuras: lista de órdenes, "gastado
  /// este mes", etc.). Best effort: una cancelación fallida no corta el resto.
  static Future<void> cancelPendingOrders(String token) async {
    for (var page = 0; page < 5; page++) {
      final body = await _request(
        'GET',
        '/orders?page=$page&size=50',
        token: token,
      );
      final orders = (body['orders'] as List).cast<Map<String, dynamic>>();
      if (orders.isEmpty) break;
      for (final order in orders.where((o) => o['status'] == 'pending')) {
        try {
          await _request(
            'POST',
            '/orders/${order['id']}/cancel',
            token: token,
            body: {'reason': 'e2e teardown'},
          );
        } catch (_) {
          // Best effort.
        }
      }
      final pagination = body['pagination'] as Map<String, dynamic>;
      if (page + 1 >= (pagination['total_pages'] as int)) break;
    }
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.openUrl(method, Uri.parse('$baseUrl$path'));
      req.headers.contentType = ContentType.json;
      if (token != null) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) req.write(jsonEncode(body));
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 400) {
        throw HttpException('$method $path -> ${res.statusCode}: $text');
      }
      if (text.isEmpty) return const {};
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } finally {
      client.close(force: true);
    }
  }
}
