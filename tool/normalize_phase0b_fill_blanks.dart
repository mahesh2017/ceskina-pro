import 'dart:convert';
import 'dart:io';

void main() {
  final files = Directory(
    'assets/curriculum/lessons',
  ).listSync().whereType<File>().where((file) => file.path.endsWith('.json'));
  var fillBlankCount = 0;
  var errorCorrectionCount = 0;

  for (final file in files) {
    var source = file.readAsStringSync();
    final lesson = jsonDecode(source) as Map<String, dynamic>;
    final exercises = (lesson['exercises'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final targets = exercises
        .where(
          (exercise) =>
              exercise['type'] == 'fill_blank' ||
              (exercise['type'] == 'error_correction' &&
                  (exercise['data'] as Map)['correct_sentence_cz'] == null),
        )
        .map((exercise) => exercise['id'] as int)
        .toList();
    final replacements = <({int start, int end, String text})>[];

    for (final id in targets) {
      final marker = source.indexOf('"id": $id,');
      final start = source.lastIndexOf('{', marker);
      final end = _objectEnd(source, start);
      final exercise =
          jsonDecode(source.substring(start, end)) as Map<String, dynamic>;
      if (exercise['type'] == 'fill_blank') {
        _normalizeFillBlank(exercise);
        fillBlankCount++;
      } else {
        final data = exercise['data'] as Map<String, dynamic>;
        final answers = (data['accepted_answers'] as List<dynamic>)
            .cast<String>();
        data['correct_sentence_cz'] = answers.first;
        errorCorrectionCount++;
      }
      replacements.add((
        start: start,
        end: end,
        text: _prettyJson(exercise, 2),
      ));
    }

    replacements.sort((a, b) => b.start.compareTo(a.start));
    for (final replacement in replacements) {
      source = source.replaceRange(
        replacement.start,
        replacement.end,
        replacement.text,
      );
    }
    if (replacements.isNotEmpty) file.writeAsStringSync(source);
  }

  if (fillBlankCount != 144 || errorCorrectionCount != 4) {
    stderr.writeln(
      'Expected 144 fill blanks and 4 error corrections; normalized '
      '$fillBlankCount and $errorCorrectionCount',
    );
    exitCode = 1;
  }
}

void _normalizeFillBlank(Map<String, dynamic> exercise) {
  final id = exercise['id'] as int;
  final data = exercise['data'] as Map<String, dynamic>;
  if (id == 9023) {
    data['sentence'] =
        'Dnes je pondělí, zítra bude ___. (Today is Monday; name tomorrow.)';
  } else if (id == 18006) {
    data['sentence'] = 'v ___ (hotel) → v hotelu. na ___ (hrad) → na hradě.';
  } else if (id == 18007) {
    data['sentence'] =
        'v ___ (škola) → ve škole. na ___ (ulice) → na ulici. '
        'o ___ (práce) → o práci.';
  }

  final sentence = data['sentence'] as String;
  final blankCount = RegExp(r'_+').allMatches(sentence).length;
  final accepted = (data['accepted_answers'] as List<dynamic>).cast<String>();
  final overrides = <int, List<List<String>>>{
    22011: [
      ['protože'],
      ['že'],
      ['jestli'],
    ],
    22016: [
      ['aby'],
      ['věděl'],
    ],
    22019: [
      ['Kdyby', 'kdyby'],
      ['věděl'],
    ],
    22023: [
      ['abys'],
      ['chápal'],
    ],
  };

  final List<List<String>> blankAnswers;
  if (overrides[id] case final override?) {
    blankAnswers = override;
  } else if (blankCount == 1) {
    blankAnswers = [accepted];
  } else {
    final combinations = accepted.map((answer) {
      if (answer.contains('|')) return answer.split('|');
      final commaParts = answer.split(RegExp(r',\s*'));
      return commaParts.length == blankCount ? commaParts : null;
    }).toList();
    if (combinations.every((parts) => parts?.length == blankCount)) {
      blankAnswers = List.generate(
        blankCount,
        (blankIndex) => combinations
            .map((parts) => parts![blankIndex].trim())
            .toSet()
            .toList(),
      );
    } else if (accepted.length == blankCount) {
      blankAnswers = accepted.map((answer) => [answer]).toList();
    } else {
      throw FormatException(
        'Cannot map fill blank $id: ${accepted.length} answer(s) for '
        '$blankCount blanks',
      );
    }
  }

  if (blankAnswers.length != blankCount ||
      blankAnswers.any(
        (answers) =>
            answers.isEmpty || answers.any((answer) => answer.trim().isEmpty),
      )) {
    throw FormatException('Invalid normalized answer groups for $id');
  }
  data
    ..['blank_count'] = blankCount
    ..['blank_answers'] = blankAnswers
    ..remove('accepted_answers');
}

int _objectEnd(String source, int start) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var index = start; index < source.length; index++) {
    final char = source[index];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        inString = false;
      }
      continue;
    }
    if (char == '"') {
      inString = true;
    } else if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0) return index + 1;
    }
  }
  throw const FormatException('Unterminated exercise object');
}

String _prettyJson(Object? value, [int depth = 0]) {
  final indent = '  ' * depth;
  final childIndent = '  ' * (depth + 1);
  return switch (value) {
    final Map map =>
      map.isEmpty
          ? '{}'
          : '{\n${map.entries.map((entry) {
              final key = jsonEncode(entry.key.toString());
              return '$childIndent$key: ${_prettyJson(entry.value, depth + 1)}';
            }).join(',\n')}\n$indent}',
    final List list =>
      list.isEmpty
          ? '[]'
          : list.every((item) => item is! Map && item is! List)
          ? '[${list.map(jsonEncode).join(', ')}]'
          : '[\n${list.map((item) => '$childIndent${_prettyJson(item, depth + 1)}').join(',\n')}\n$indent]',
    _ => jsonEncode(value),
  };
}
