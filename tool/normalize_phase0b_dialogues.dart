import 'dart:convert';
import 'dart:io';

void main() {
  final lessonFiles = Directory(
    'assets/curriculum/lessons',
  ).listSync().whereType<File>().where((file) => file.path.endsWith('.json'));
  final changedIds = <int>{};

  for (final file in lessonFiles) {
    var source = file.readAsStringSync();
    final lesson = jsonDecode(source) as Map<String, dynamic>;
    final dialogueIds = (lesson['exercises'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((exercise) => exercise['type'] == 'dialogue')
        .map((exercise) => exercise['id'] as int)
        .toList();
    final replacements = <({int start, int end, String text, int id})>[];

    for (final id in dialogueIds) {
      final markerIndex = source.indexOf('"id": $id,');
      if (markerIndex < 0) {
        throw StateError('Could not find dialogue $id in ${file.path}');
      }
      final start = source.lastIndexOf('{', markerIndex);
      final end = _objectEnd(source, start);
      final exercise =
          jsonDecode(source.substring(start, end)) as Map<String, dynamic>;
      _normalizeDialogue(exercise);
      replacements.add((
        start: start,
        end: end,
        text: _prettyJson(exercise, 2),
        id: id,
      ));
    }

    replacements.sort((a, b) => b.start.compareTo(a.start));
    for (final replacement in replacements) {
      source = source.replaceRange(
        replacement.start,
        replacement.end,
        replacement.text,
      );
      changedIds.add(replacement.id);
    }
    if (replacements.isNotEmpty) file.writeAsStringSync(source);
  }

  if (changedIds.length != 36) {
    stderr.writeln('Expected to normalize 36 dialogues, updated $changedIds');
    exitCode = 1;
  }
}

void _normalizeDialogue(Map<String, dynamic> exercise) {
  final data = exercise['data'] as Map<String, dynamic>;
  if (data['blank_answers'] is List) return;

  final lines = (data['lines'] as List<dynamic>)
      .map((raw) => Map<String, dynamic>.from(raw as Map))
      .toList();
  final explicitAnswers = <List<String>>[];

  for (final line in lines) {
    final rawText = (line['text'] ?? line['text_cz']) as String;
    line['text'] = rawText.replaceAll(RegExp(r'_{3,}'), '___');
    final rawAnswers =
        line['accepted_answers'] ?? line['blank_accepted_answers'];
    if (rawAnswers is List) {
      explicitAnswers.add(rawAnswers.cast<String>());
    }
    line
      ..remove('text_cz')
      ..remove('blank')
      ..remove('accepted_answers')
      ..remove('blank_accepted_answers');
  }

  var blankCount = _blankCount(lines);
  List<List<String>> blankAnswers;
  if (explicitAnswers.isNotEmpty) {
    blankAnswers = explicitAnswers;
  } else {
    final topLevel = (data['accepted_answers'] as List<dynamic>).cast<String>();
    if (blankCount == 0) {
      final candidateGroups = topLevel
          .map((entry) => entry.split('|'))
          .toList();
      final candidates = candidateGroups.expand((group) => group).toList();
      final targetIndices = <int>[];
      for (var index = 0; index < lines.length; index++) {
        final lineText = _canonical(lines[index]['text'] as String);
        if (candidates.any((candidate) {
          final normalized = _canonical(candidate);
          return normalized.isNotEmpty && lineText.contains(normalized);
        })) {
          targetIndices.add(index);
        }
      }
      if (targetIndices.length != topLevel.length) {
        throw FormatException(
          'Dialogue ${exercise['id']} expected ${topLevel.length} response '
          'line(s), found ${targetIndices.length}',
        );
      }
      blankAnswers = candidateGroups;
      for (final index in targetIndices) {
        lines[index]['text'] = '___';
      }
      blankCount = _blankCount(lines);
    } else {
      final groups = topLevel.map((entry) => entry.split('|')).toList();
      if (blankCount == 1) {
        blankAnswers = [groups.expand((group) => group).toList()];
      } else if (groups.every((group) => group.length == blankCount)) {
        blankAnswers = List.generate(
          blankCount,
          (blankIndex) =>
              groups.map((group) => group[blankIndex]).toSet().toList(),
        );
      } else if (groups.length == blankCount) {
        blankAnswers = groups;
      } else {
        throw FormatException(
          'Dialogue ${exercise['id']} cannot map ${groups.length} answer '
          'group(s) to $blankCount blanks',
        );
      }
    }
  }

  if (blankAnswers.length != blankCount ||
      blankAnswers.any(
        (answers) =>
            answers.isEmpty || answers.any((answer) => answer.trim().isEmpty),
      )) {
    throw FormatException(
      'Dialogue ${exercise['id']} produced ${blankAnswers.length} answer '
      'groups for $blankCount blanks',
    );
  }

  data
    ..['lines'] = lines
    ..['blank_answers'] = blankAnswers
    ..remove('accepted_answers');
  if (data['scenario'] == null && data['context_en'] is String) {
    data['scenario'] = data['context_en'];
  }
  data.remove('context_en');
}

int _blankCount(List<Map<String, dynamic>> lines) => lines.fold(
  0,
  (count, line) => count + '___'.allMatches(line['text'] as String).length,
);

String _canonical(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-záčďéěíňóřšťúůýž0-9]+'), ' ')
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ');

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
