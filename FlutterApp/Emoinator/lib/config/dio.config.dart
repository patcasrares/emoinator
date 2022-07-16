library dio_config;

import 'package:dio/dio.dart';
import 'package:emoinator/config/app.config.dart';
import 'package:emoinator/core/interceptors/http_log.interceptor.dart';

Dio dioInstance(AppConfig configuredApp) {
  final dio = Dio(BaseOptions(
    headers: {
      Headers.contentTypeHeader: 'application/json',
    },
    connectTimeout: 10000,
    receiveTimeout: 10000,
    sendTimeout: 10000,
  ));

  dio.interceptors.addAll([
    if (configuredApp.logServices) HttpLogInterceptor(),
  ]);

  return dio;
}
