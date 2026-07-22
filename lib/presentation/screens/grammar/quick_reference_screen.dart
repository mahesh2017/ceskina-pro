import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../core/theme/app_tokens.dart';

/// Screen for quick-reference content: cheat sheets, declension tables,
/// conjugation tables.
class QuickReferenceScreen extends StatefulWidget {
  /// Which reference type to show: 'cheat_sheets', 'declension_tables',
  /// or 'conjugation_tables'.
  final String type;

  const QuickReferenceScreen({
    super.key,
    required this.type,
  });

  @override
  State<QuickReferenceScreen> createState() => _QuickReferenceScreenState();
}

class _QuickReferenceScreenState extends State<QuickReferenceScreen> {
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _assetPath => 'assets/curriculum/${widget.type}.json';

  String get _title {
    switch (widget.type) {
      case 'cheat_sheets':
        return 'Cheat Sheets';
      case 'declension_tables':
        return 'Declension Tables';
      case 'conjugation_tables':
        return 'Conjugation Tables';
      default:
        return 'Reference';
    }
  }

  Future<void> _load() async {
    try {
      final json = await rootBundle.loadString(_assetPath);
      setState(() => _data = jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _buildBody(t),
    );
  }

  Widget _buildBody(AppTokens t) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: t.red),
              const SizedBox(height: 16),
              Text('Could not load $_title.',
                  style: TextStyle(color: t.muted)),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.type == 'cheat_sheets') {
      return _buildCheatSheets(t);
    } else {
      return _buildTables(t);
    }
  }

  Widget _buildCheatSheets(AppTokens t) {
    final sheets = _data!['cheat_sheets'] as List<dynamic>? ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sheets.length,
      itemBuilder: (context, i) {
        final sheet = sheets[i] as Map<String, dynamic>;
        final unitId = sheet['unit_id'];
        final title = sheet['title'] as String? ?? '';
        final description = sheet['description'] as String? ?? '';
        final grammarRules =
            (sheet['grammar_rules'] as List<dynamic>?) ?? [];
        final coreVocab =
            (sheet['core_vocabulary'] as List<dynamic>?) ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            title: Text(
              'Unit $unitId: $title',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: t.ink,
              ),
            ),
            subtitle: Text(description,
                style: TextStyle(fontSize: 13, color: t.muted)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (grammarRules.isNotEmpty) ...[
                      Text('Grammar Rules',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: t.pri,
                          )),
                      const SizedBox(height: 4),
                      ...grammarRules.take(5).map((r) {
                        final rule = r as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.arrow_right,
                                  size: 14, color: t.faint),
                              const SizedBox(width: 4),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 13, color: t.ink),
                                    children: [
                                      TextSpan(
                                        text: '${rule['name']}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${rule['pattern']}',
                                        style: TextStyle(color: t.muted),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (coreVocab.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Key Vocabulary',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: t.pri,
                          )),
                      const SizedBox(height: 4),
                      ...coreVocab.take(8).map((v) {
                        final vocab = v as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${vocab['cz']} — ${vocab['en']}',
                            style: TextStyle(fontSize: 13, color: t.ink),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTables(AppTokens t) {
    final tables = _data!['tables'] as List<dynamic>? ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tables.length,
      itemBuilder: (context, i) {
        final table = tables[i] as Map<String, dynamic>;
        final title = table['title'] as String? ?? '';
        final description = table['description'] as String? ?? '';
        final rows = (table['rows'] as List<dynamic>?) ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            title: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: t.ink)),
            subtitle: description.isNotEmpty
                ? Text(description,
                    style: TextStyle(fontSize: 13, color: t.muted))
                : null,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    columns: rows.isNotEmpty
                        ? (rows.first as Map<String, dynamic>)
                            .keys
                            .map((k) => DataColumn(
                                label: Text(k,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: t.pri))))
                            .toList()
                        : [],
                    rows: rows.map((r) {
                      final row = r as Map<String, dynamic>;
                      return DataRow(
                        cells: row.values
                            .map((v) => DataCell(Text('$v',
                                style: const TextStyle(fontSize: 13))))
                            .toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
