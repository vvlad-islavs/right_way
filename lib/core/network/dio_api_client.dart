import 'package:dio/dio.dart';
import 'package:right_way/core/network/api_client.dart';

class DioApiClient implements ApiClient {
  DioApiClient(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      queryParameters: query,
    );
    return response.data ?? const <String, dynamic>{};
  }
}

