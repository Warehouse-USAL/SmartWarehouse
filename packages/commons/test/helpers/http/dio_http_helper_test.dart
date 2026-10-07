import 'package:commons/helpers/http/dio_http_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rechaza el primer request con 401 y resuelve los siguientes con 200:
/// el escenario de un token que expiró y un refresh que salió bien.
class _ExpiredTokenOnceInterceptor extends Interceptor {
  int requests = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests++;
    if (requests == 1) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {
              'error': {'code': 'TOKEN_EXPIRED', 'message': 'expired'},
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: {'ok': true}),
    );
  }
}

void main() {
  late _ExpiredTokenOnceInterceptor stub;
  var refreshCalls = 0;

  DioHttpHelper buildHelper({bool refreshSucceeds = true}) {
    stub = _ExpiredTokenOnceInterceptor();
    refreshCalls = 0;
    final helper = DioHttpHelper(
      baseUrl: 'https://backend.test',
      onRefreshToken: () async {
        refreshCalls++;
        return refreshSucceeds;
      },
      isExpiredToken: (statusCode, _) => statusCode == 401,
      connectTimeout: const Duration(seconds: 1),
      receiveTimeout: const Duration(seconds: 1),
      domainInterceptors: [stub],
      debuggingInterceptors: const [],
    )..init();
    return helper;
  }

  group('post con token expirado', () {
    test('reintenta el request cuando el refresh sale bien', () async {
      // Regresion: la condicion del onRetry estaba invertida y post()
      // devolvia el 401 original con la sesion ya renovada ("No tenes
      // permisos" al crear una orden con token expirado).
      final helper = buildHelper();

      final result = await helper.post('/orders', data: {'x': 1});

      expect(result.isRight(), isTrue, reason: 'el retry debia dar 200');
      expect(refreshCalls, 1);
      expect(stub.requests, 2);
    });

    test('con retryOnTokenExpired: false devuelve el error original',
        () async {
      final helper = buildHelper();

      final result =
          await helper.post('/orders', retryOnTokenExpired: false);

      expect(result.isLeft(), isTrue);
      expect(stub.requests, 1, reason: 'no debia reintentar');
    });

    test('si el refresh falla devuelve el 401 sin reintentar', () async {
      final helper = buildHelper(refreshSucceeds: false);

      final result = await helper.post('/orders');

      expect(result.isLeft(), isTrue);
      expect(refreshCalls, 1);
      expect(stub.requests, 1);
    });

    test('get tambien reintenta tras el refresh (comportamiento existente)',
        () async {
      final helper = buildHelper();

      final result = await helper.get('/orders');

      expect(result.isRight(), isTrue);
      expect(stub.requests, 2);
    });
  });
}
