abstract interface class ApiClient {
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  });
}

