import 'dart:convert';
import 'dart:io';
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
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  @override
  Future<LlmResponse> complete(LlmRequest request) async {
    final response = await _dio.post(
      '/chat/completions',
      data: jsonEncode({
        'model': request.model,
        'messages': request.messages
            .map((m) => {
                  'role': m.role.name,
                  'content': m.content,
                })
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

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw const DeepSeekException('No response from model');
    }

    final content = choices[0]['message']['content'] as String;
    final usage = data['usage'] as Map<String, dynamic>?;

    return LlmResponse(
      content: content,
      inputTokens: usage?['prompt_tokens'] as int? ?? 0,
      outputTokens: usage?['completion_tokens'] as int? ?? 0,
      model: data['model'] as String?,
    );
  }

  @override
  Stream<LlmChunk> streamComplete(LlmRequest request) async* {
    final response = await _dio.post(
      '/chat/completions',
      data: jsonEncode({
        'model': request.model,
        'messages': request.messages
            .map((m) => {
                  'role': m.role.name,
                  'content': m.content,
                })
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

    // Parse SSE stream
    final stream = response.data.stream as Stream<List<int>>;
    await for (final chunk in stream) {
      final lines = utf8.decode(chunk).split('\n');
      for (final line in lines) {
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
        } catch (_) {
          // Skip malformed chunks
        }
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
}

/// Exception from the DeepSeek API.
class DeepSeekException implements Exception {
  final String message;
  const DeepSeekException(this.message);

  @override
  String toString() => 'DeepSeekException: $message';
}