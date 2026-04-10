import 'dart:math';

import 'package:dio/dio.dart';
import 'package:right_way/core/logging/logging.dart';

class DioRetryInterceptor extends Interceptor {
  DioRetryInterceptor({
    required Dio dio,
    required LogService log,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
  })  : _dio = dio,
        _log = log;

  final Dio _dio;
  final LogService _log;
  final int maxRetries;
  final Duration baseDelay;

  static const _retryCountKey = '__retryCount';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final retryCount = (req.extra[_retryCountKey] as int?) ?? 0;

    if (retryCount >= maxRetries || !_shouldRetry(err)) {
      return handler.next(err);
    }

    final nextCount = retryCount + 1;
    final delay = _delayForAttempt(nextCount);

    _log.warn(
      'HTTP retry $nextCount/$maxRetries in ${delay.inMilliseconds}ms: ${req.method} ${req.uri}',
      tag: 'dio',
      error: err,
    );

    await Future.delayed(delay);

    final newOptions = req.copyWith(extra: Map<String, dynamic>.from(req.extra)..[_retryCountKey] = nextCount);
    try {
      final response = await _dio.fetch<dynamic>(newOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException e) {
    // Retry only transient network errors, not HTTP status responses.
    if (e.type == DioExceptionType.badResponse) return false;
    return switch (e.type) {
      DioExceptionType.connectionTimeout => true,
      DioExceptionType.sendTimeout => true,
      DioExceptionType.receiveTimeout => true,
      DioExceptionType.connectionError => true,
      DioExceptionType.unknown => true,
      DioExceptionType.cancel => false,
      DioExceptionType.badCertificate => false,
      DioExceptionType.badResponse => false,
    };
  }

  Duration _delayForAttempt(int attempt) {
    final rnd = Random();
    final ms = baseDelay.inMilliseconds * (1 << (attempt - 1));
    final jitter = rnd.nextInt(120);
    return Duration(milliseconds: ms + jitter);
  }
}
