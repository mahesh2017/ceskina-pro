/// User-facing failure returned by the server-managed AI service.
class LlmServiceException implements Exception {
  const LlmServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
