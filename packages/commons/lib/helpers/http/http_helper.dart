// ignore_for_file: avoid_annotating_with_dynamic

import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class HttpHelper {
  void init();

  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noCache = false,
    bool external = false,
    Map<String, dynamic>? headers,
  });

  Future<Either<HttpResponseError, HttpResponse>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  });

  Future<Either<HttpResponseError, HttpResponse>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool retryOnTokenExpired = true,
    bool external = false,
    Map<String, dynamic>? headers,
  });

  Future<Either<HttpResponseError, HttpResponse>> postImages(
    String path, {
    required Map<String, dynamic> data,
    required FilesData filesData,
    bool external = false,
    Map<String, dynamic>? headers,
  });

  Future<Either<HttpResponseError, HttpResponse>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool external = false,
  });

  Future<Either<HttpResponseError, HttpResponse>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  });
}

class MultipartFileData {
  MultipartFileData({required this.path, required this.filename});

  final String path, filename;
}

class FilesData {
  FilesData({required this.files, this.filesNameParameter = 'file[]'});

  final List<MultipartFileData> files;
  final String filesNameParameter;
}
