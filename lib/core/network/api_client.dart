/// HTTP-клиент приложения: POST с JSON телом и ответом в виде карты полей.
abstract interface class ApiClient {
  /// POST по [path], опционально [body] и [query]. Возвращает тело ответа как JSON-объект.
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  });
}

