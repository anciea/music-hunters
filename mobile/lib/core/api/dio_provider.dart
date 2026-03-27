import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';

part 'dio_provider.g.dart';

/// Provides a configured [Dio] singleton with:
/// - Base URL from [AppConfig.apiBaseUrl]
/// - X-API-Key header injected on every request
@riverpod
Dio dio(Ref ref) {
  final d = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  d.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-API-Key'] = AppConfig.apiKey;
        handler.next(options);
      },
    ),
  );

  return d;
}
