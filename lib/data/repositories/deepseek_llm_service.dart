import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/repositories/llm_service.dart';

/// DeepSeek API implementation of [LlmService].
///
/// Uses the DeepSeek chat completions endpoint with JSON mode
/// for structured tutor responses.
class DeepSeekLlmService implements LlmService {
  final Dio _dio;
  final String _apiKey;

  static const _baseUrl = 'https://api.deepseek.com/v1';

  DeepSeekLlmService({
    required String apiKey,
    Dio? dio,
    // Named parameters can't be private, so an initializing formal isn't possible.
    // ignore: prefer_initializing_formals
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl)) {
    assert(_apiKey.isNotEmpty, 'DeepSeekLlmService requires an API key');
  }

  @override
  Future<LlmResponse> complete(LlmRequest request) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post(
        '/chat/completions',
        data: jsonEncode({
          'model': request.model,
          'messages': request.messages
              .map((m) => {
                    'role': m.role.name,
                    'content': m.content,
                  },)
              .toList(),
          'temperature': request.temperature,
          'response_format': {'type': 'json_object'},
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw const DeepSeekException('No response from model');
    }

    final content = choices[0]['message']['content'] as String;
    final usage = data['usage'] as Map<String, dynamic>?;

    return LlmResponse(
      content: content,
      inputTokens: (usage?['prompt_tokens'] as num?)?.toInt() ?? 0,
      outputTokens: (usage?['completion_tokens'] as num?)?.toInt() ?? 0,
      model: data['model'] as String?,
    );
  }

  @override
  Stream<LlmChunk> streamComplete(LlmRequest request) async* {
    final Response<dynamic> response;
    try {
      response = await _dio.post(
        '/chat/completions',
        data: jsonEncode({
          'model': request.model,
          'messages': request.messages
              .map((m) => {
                    'role': m.role.name,
                    'content': m.content,
                  },)
              .toList(),
          'temperature': request.temperature,
          'stream': true,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }

    // Parse the SSE stream line by line. utf8.decoder + LineSplitter buffer
    // across network chunks, so multi-byte characters and `data:` lines that
    // span chunk boundaries are reassembled instead of dropped.
    final stream = response.data.stream as Stream<List<int>>;
    final lines = stream.transform(utf8.decoder).transform(const LineSplitter());

    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final data = line.substring(6).trim();
      if (data == '[DONE]') {
        yield const LlmChunk(delta: '', isFinal: true);
        return;
      }
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final choices = json['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final delta = choices[0]['delta']['content'] as String?;
          if (delta != null && delta.isNotEmpty) {
            yield LlmChunk(delta: delta);
          }
        }
      } on FormatException {
        // Skip keep-alive or malformed events; real payload lines are
        // complete JSON thanks to the LineSplitter buffering above.
      }
    }
    yield const LlmChunk(delta: '', isFinal: true);
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Simple connectivity check
      await _dio.get(
        '/models',
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  DeepSeekException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const DeepSeekException(
            'The AI service timed out. Check your connection and try again.',);
      case DioExceptionType.connectionError:
        return const DeepSeekException(
            'Could not reach the AI service. Are you online?',);
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        return switch (status) {
          400 => const DeepSeekException(
              'The AI service rejected the request (bad request).',),
          401 => const DeepSeekException(
              'Invalid API key. Check it in Settings.',),
          402 => const DeepSeekException(
              'Insufficient API credit. Top up at platform.deepseek.com.',),
          429 => const DeepSeekException(
              'Rate limit reached. Wait a moment and try again.',),
          >= 500 => const DeepSeekException(
              'The AI service is having problems. Try again later.',),
          _ => DeepSeekException('AI service error (HTTP $status).'),
        };
      case DioExceptionType.cancel:
        return const DeepSeekException('Request was cancelled.');
      default:
        return const DeepSeekException(
            'Unexpected network error talking to the AI service.',);
    }
  }
}

/// Exception from the DeepSeek API.
class DeepSeekException implements Exception {
  final String message;
  const DeepSeekException(this.message);

  @override
  String toString() => message;
}
