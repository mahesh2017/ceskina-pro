import 'dart:convert';
import 'dart:io';

const _wordOrderFixes = <int, ({List<String> words, List<int> order})>{
  1108: (words: ['Řeka', 'teče', 'pod', 'mostem.'], order: [0, 1, 2, 3]),
  2008: (words: ['Ahoj,', 'jak', 'se', 'máš?'], order: [0, 1, 2, 3]),
  2104: (
    words: ['Jmenuju', 'se', 'Anna.', 'Jsem', 'z', 'Prahy.', 'Těší', 'mě.'],
    order: [0, 1, 2, 3, 4, 5, 6, 7],
  ),
  3010: (words: ['To', 'je', 'velký', 'hrad.'], order: [0, 1, 2, 3]),
  3109: (
    words: ['On', 'je', 'lékař.', 'Ona', 'je', 'lékařka.'],
    order: [0, 1, 2, 3, 4, 5],
  ),
  9011: (words: ['Mám', 'tři', 'knihy.'], order: [0, 1, 2]),
  10009: (words: ['myju', 'se', 'Já', 'každé', 'ráno'], order: [2, 1, 0, 3, 4]),
  10017: (
    words: ['domů', 'a', 'večer', 'Večer', 'vracím', 'večeřím', 'se'],
    order: [3, 6, 4, 0, 1, 5],
  ),
  13012: (
    words: ['rád', 'Díváš', 'filmy?', 'na', 'se'],
    order: [1, 4, 0, 3, 2],
  ),
  13022: (
    words: ['vždycky', 'chodím', 'procházku.', 'V', 'neděli', 'na'],
    order: [3, 4, 0, 1, 5, 2],
  ),
  15023: (
    words: ['Příští', 'týden', 'budu', 'v', 'hotelu'],
    order: [0, 1, 2, 3, 4],
  ),
  16009: (
    words: ['Jdu', 'do', 'školy', 'každý', 'den'],
    order: [0, 1, 2, 3, 4],
  ),
  16021: (words: ['Potřebuju', 'litr', 'mléka'], order: [0, 1, 2]),
  18023: (words: ['Jedu', 'do', 'práce', 'autem'], order: [0, 1, 2, 3]),
  22009: (
    words: ['dobrý', 'že', 'Myslím,', 'je', 'ten', 'film'],
    order: [2, 1, 4, 5, 3, 0],
  ),
  22022: (
    words: ['mi', 'bych', 'Kdybys', 'dnes.', 'to', 'dokončil', 'pomohl,'],
    order: [2, 0, 6, 5, 1, 4, 3],
  ),
  23008: (words: ['nám', 'můžeš', 'Ty', 'pomoci'], order: [2, 1, 0, 3]),
  24011: (words: ['horečku', 'Mám', 'teplotu'], order: [1, 0]),
  24023: (words: ['Mám', 'bolest', 'břicho', 'žaludku'], order: [0, 1, 3]),
  25010: (
    words: ['učitelka', 'pracuje', 'Moje', 'jako', 'sestra'],
    order: [2, 4, 1, 3, 0],
  ),
  26010: (words: ['v', 'byt', 'Praze', 'Mám', 'velký'], order: [3, 4, 1, 0, 2]),
  26023: (
    words: ['smlouvu', 'Musím', 'nájemní', 'podepsat'],
    order: [1, 3, 2, 0],
  ),
  31015: (
    words: [
      'ho',
      'jsem',
      'Včera',
      'viděl',
      'protože',
      'byl',
      'v',
      'parku.',
      'jsem',
      'v',
      'kavárně',
    ],
    order: [2, 1, 0, 3, 4, 8, 5, 9, 10, 6, 7],
  ),
};

const _answerKeyFixes = <int, String>{
  1108: 'Řeka teče pod mostem.',
  2008: 'Ahoj, jak se máš?',
  2104: 'Jmenuju se Anna. Jsem z Prahy. Těší mě.',
  3010: 'To je velký hrad.',
  3109: 'On je lékař. Ona je lékařka.',
};

void main() {
  final lessonFiles = Directory(
    'assets/curriculum/lessons',
  ).listSync().whereType<File>().where((file) => file.path.endsWith('.json'));
  final expected = {..._wordOrderFixes.keys, 6002, 6005, 6007, 6009};
  final changedIds = <int>{};

  for (final file in lessonFiles) {
    var source = file.readAsStringSync();
    final replacements = <({int start, int end, String text, int id})>[];
    for (final id in expected) {
      final marker = '"id": $id,';
      final markerIndex = source.indexOf(marker);
      if (markerIndex < 0) continue;
      final start = source.lastIndexOf('{', markerIndex);
      final end = _objectEnd(source, start);
      final exercise =
          jsonDecode(source.substring(start, end)) as Map<String, dynamic>;
      _normalizeExercise(exercise);
      replacements.add((
        start: start,
        end: end,
        text: _prettyJson(exercise, 2),
        id: id,
      ),);
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
    if (replacements.isNotEmpty) {
      file.writeAsStringSync(source);
    }
  }

  if (!changedIds.containsAll(expected) ||
      changedIds.length != expected.length) {
    stderr.writeln('Expected to update $expected, updated $changedIds');
    exitCode = 1;
  }
}

void _normalizeExercise(Map<String, dynamic> exercise) {
  final id = exercise['id'] as int;
  final fix = _wordOrderFixes[id];
  if (fix != null) {
    final data = exercise['data'] as Map<String, dynamic>;
    data
      ..remove('shuffled')
      ..remove('scrambled')
      ..remove('_correct_sentence')
      ..['words'] = fix.words
      ..['correct_order'] = fix.order;
  }
  if (_answerKeyFixes[id] case final answer?) {
    exercise['answer_key'] = answer;
  }

  if (exercise['type'] == 'declension_table') {
    final data = exercise['data'] as Map<String, dynamic>;
    if (data['word'] == null) {
      exercise['data'] = <String, dynamic>{
        'type': 'declension_table',
        'word': data['noun'],
        'gender': data['gender'],
        'cases': ['nominative', 'accusative'],
        'answer_key': {
          'nominative': data['nominative'],
          'accusative': data['accusative'],
        },
        'explanation': data['explanation'],
      };
    }
  }

  if (id == 1108) {
    (exercise['data'] as Map<String, dynamic>)
      ..['translation_en'] = 'The river flows under the bridge.'
      ..['explanation'] =
          "'Řeka teče pod mostem.' = The river flows under the bridge. "
          "The location preposition 'pod' takes the instrumental here: "
          'most → mostem.';
  } else if (id == 13012) {
    exercise['answer_key'] = 'Díváš se rád na filmy?';
    (exercise['data'] as Map<String, dynamic>)['explanation'] =
        "'Díváš se rád na filmy?' = Do you like watching films? "
        "The reflexive pronoun 'se' follows the finite verb here; "
        "'dívat se na' takes the accusative.";
  } else if (id == 26010) {
    (exercise['data'] as Map<String, dynamic>)['explanation'] =
        "'Mám velký byt v Praze.' = I have a big apartment in Prague. "
        "'V' + locative: Praha → Praze. 'Velký byt' is masculine "
        'inanimate in the accusative.';
  } else if (id == 31015) {
    exercise['answer_key'] =
        'Včera jsem ho viděl, protože jsem byl v kavárně v parku.';
    (exercise['data'] as Map<String, dynamic>)['explanation'] =
        "'Včera jsem ho viděl, protože jsem byl v kavárně v parku.' "
        '= Yesterday I saw him because I was in the café in the park. '
        "The clitics 'jsem' and 'ho' occupy the second position of the "
        "main clause; the 'protože' clause starts its own clitic group.";
  }
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
