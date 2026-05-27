// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:developer';

import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:commons/helpers/http/http_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

typedef OnRefreshTokenCallback = Future<bool> Function();
typedef IsExpiredTokenCheckCallback = bool Function(int errorStatusCode, String? message);

class DioHttpHelper implements HttpHelper {
  DioHttpHelper({
    required this.baseUrl,
    required this.onRefreshToken,
    required this.isExpiredToken,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.domainInterceptors,
    required this.debuggingInterceptors,
  });

  final String baseUrl;
  final OnRefreshTokenCallback onRefreshToken;
  final IsExpiredTokenCheckCallback isExpiredToken;
  late Dio _dio;
  final Duration connectTimeout, receiveTimeout;
  final List<Interceptor> domainInterceptors, debuggingInterceptors;

  @override
  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.addAll([...domainInterceptors, ...debuggingInterceptors]);
  }

  @override
  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool noCache = false,
    bool external = false,
  }) async {
    try {
      final noCacheHeader = Options(
        headers: {'Cache-Control': 'no-cache'},
        extra: {'external': external},
      );

      final dioResponse = await _execute(
        headers: headers ?? {},
        query: () => _dio.get(
          path,
          queryParameters: queryParameters,
          options: noCache ? noCacheHeader : null,
        ),
        external: external,
      );

      return Right(_buildHttpResponse(dioResponse));
    } on DioException catch (error) {
      return _onDioError(
        external: external,
        error: error,
        onRetry: () => get(path, noCache: noCache, queryParameters: queryParameters),
      );
    }
  }

  @override
  Future<Either<HttpResponseError, HttpResponse>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool external = false,
    Options? options,
    bool retryOnTokenExpired = true,
  }) async {
    try {
      final dioResponse = await _execute(
        headers: headers ?? {},
        query: () => _dio.post(path, data: data, queryParameters: queryParameters, options: options),
        external: external,
      );

      return Right(_buildHttpResponse(dioResponse));
    } on DioException catch (error) {
      return _onDioError(
        external: external,
        error: error,
        onRetry: () async {
          if (!retryOnTokenExpired) return post(path, data: data, queryParameters: queryParameters, options: options);
          return Left(_onResponseError(error));
        },
      );
    }
  }

  @override
  Future<Either<HttpResponseError, HttpResponse>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool external = false,
  }) async {
    try {
      final dioResponse = await _execute(
        headers: headers ?? {},
        query: () => _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
        ),
        external: external,
      );

      return Right(_buildHttpResponse(dioResponse));
    } on DioException catch (error) {
      return _onDioError(
        external: external,
        error: error,
        onRetry: () => put(path, data: data, queryParameters: queryParameters),
      );
    }
  }

  @override
  Future<Either<HttpResponseError, HttpResponse>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final dioResponse = await _execute(
        headers: headers ?? {},
        query: () => _dio.delete(path, queryParameters: queryParameters, data: data),
        external: external,
      );
      return Right(_buildHttpResponse(dioResponse));
    } on DioException catch (error) {
      return _onDioError(
        external: external,
        error: error,
        onRetry: () => delete(path, data: data, queryParameters: queryParameters),
      );
    }
  }

  @override
  Future<Either<HttpResponseError, HttpResponse>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final dioResponse = await _execute(
        headers: headers ?? {},
        query: () => _dio.patch(path, data: data, queryParameters: queryParameters),
        external: external,
      );
      return Right(_buildHttpResponse(dioResponse));
    } on DioException catch (error) {
      return _onDioError(
        error: error,
        onRetry: () => patch(path, data: data, queryParameters: queryParameters),
        external: external,
      );
    }
  }

  @override
  Future<Either<HttpResponseError, HttpResponse>> postImages(
    String path, {
    required Map<String, dynamic> data,
    required FilesData filesData,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final multipartFiles = await Future.wait(
        filesData.files.map((file) async => MultipartFile.fromFile(file.path, filename: file.filename)),
      );
      final formData = FormData.fromMap(
        {
          filesData.filesNameParameter: multipartFiles,
          ...data,
        },
      );
      final dioResponse = await _dio.post(
        path,
        data: formData,
      );
      return Right(_buildHttpResponse(dioResponse));
    } on DioException catch (error) {
      return _onDioError(
        external: external,
        error: error,
        onRetry: () => postImages(path, data: data, filesData: filesData),
      );
    }
  }

  Future<Either<HttpResponseError, HttpResponse>> _onDioError({
    required bool external,
    required DioException error,
    required Future<Either<HttpResponseError, HttpResponse>> Function() onRetry,
  }) async {
    final httpResponseError = _onResponseError(error);
    if (!external && isExpiredToken(httpResponseError.statusCode, httpResponseError.message)) {
      final refreshTokenSuccess = await onRefreshToken();
      if (refreshTokenSuccess) return onRetry();
    }
    return Left(httpResponseError);
  }

  HttpResponseError _onResponseError(DioException error) {
    final data = error.response?.data;
    // El backend devuelve errors con shape `{"error": {"code": "...",
    // "message": "..."}}`. Toleramos también shapes legacy (`{message,
    // errorType, error: {reason}}`) y `data` como string plano por si algún
    // endpoint devuelve texto crudo.
    String? message;
    String? reason;
    String? errorType;

    if (data is Map<String, dynamic>) {
      final err = data['error'];
      if (err is Map<String, dynamic>) {
        message = err['message']?.toString();
        reason = (err['code'] ?? err['reason'])?.toString();
      }
      message ??= data['message']?.toString();
      errorType = data['error_type']?.toString() ?? data['errorType']?.toString();
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    return HttpResponseError(
      message: message,
      stackTrace: error.stackTrace,
      reason: reason,
      statusCode: error.response?.statusCode,
      errorType: errorType,
    );
  }

  HttpResponse<dynamic> _buildHttpResponse(Response<dynamic> dioResponse) =>
      HttpResponse(data: dioResponse.data, status: dioResponse.statusCode.toString());

  Future<Response> _execute({
    required Future<Response> Function() query,
    required bool external,
    required Map<String, dynamic> headers,
  }) async {
    if (!external) return query();
    final options = _dio.options;
    final baseUrl = options.baseUrl;
    final originalHeaders = {...options.headers};
    try {
      _dio.interceptors.clear();
      _dio.interceptors.addAll(debuggingInterceptors);
      options
        ..headers = headers
        ..baseUrl = '';
      final dioResponse = await query();
      _restoreDio(baseUrl, originalHeaders);
      return dioResponse;
    } catch (e) {
      log('$e');
      _restoreDio(baseUrl, originalHeaders);
      rethrow;
    }
  }

  void _restoreDio(String baseUrl, Map<String, dynamic> headers) {
    _dio.options
      ..baseUrl = baseUrl
      ..headers = headers;
    _dio.interceptors.addAll(domainInterceptors);
  }
}
