import 'dart:async';
import 'package:flutter/material.dart';
import '../models/entity_document.dart';
import '../services/entity_service.dart';

class EntityDetailPage extends StatefulWidget {
  final String entityFilePath;
  final VoidCallback onBack;

  const EntityDetailPage({
    super.key,
    required this.entityFilePath,
    required this.onBack,
  });

  @override
  State<EntityDetailPage> createState() => _EntityDetailPageState();
}

class _EntityDetailPageState extends State<EntityDetailPage> {
  final EntityService _entityService = EntityService();

  EntityDocument _doc = EntityDocument.empty();
  bool _isLoading = true;
  Timer? _debounceTimer;

  // Per-column controllers
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _descControllers = [];
  final List<String> _typeValues = [];
  final List<bool> _requiredValues = [];

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final doc = await _entityService.load(widget.entityFilePath);
    if (!mounted) return;

    setState(() {
      _doc = doc;
      _disposeColumnControllers();

      for (final col in doc.columns) {
        _addColumnControllers(col);
      }

      _isLoading = false;
    });
  }

  void _addColumnControllers(EntityColumn col) {
    final nameC = TextEditingController(text: col.name);
    final descC = TextEditingController(text: col.description);
    nameC.addListener(_onFieldChanged);
    descC.addListener(_onFieldChanged);
    _nameControllers.add(nameC);
    _descControllers.add(descC);
    _typeValues.add(col.type);
    _requiredValues.add(col.required);
  }

  void _onFieldChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _saveToFile);
  }

  EntityDocument _buildDocument() {
    final columns = <EntityColumn>[];
    for (var i = 0; i < _nameControllers.length; i++) {
      columns.add(EntityColumn(
        name: _nameControllers[i].text,
        type: _typeValues[i],
        required: _requiredValues[i],
        description: _descControllers[i].text,
      ));
    }
    return EntityDocument(
      name: _doc.name,
      columns: columns,
      unknownSections: _doc.unknownSections,
    );
  }

  Future<void> _saveToFile() async {
    final doc = _buildDocument();
    await _entityService.save(widget.entityFilePath, doc);
  }

  void _addColumn() {
    setState(() {
      _addColumnControllers(EntityColumn());
    });
    _onFieldChanged();
  }

  void _removeColumn(int index) {
    setState(() {
      _nameControllers[index].removeListener(_onFieldChanged);
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);

      _descControllers[index].removeListener(_onFieldChanged);
      _descControllers[index].dispose();
      _descControllers.removeAt(index);

      _typeValues.removeAt(index);
      _requiredValues.removeAt(index);
    });
    _onFieldChanged();
  }

  void _disposeColumnControllers() {
    for (final c in _nameControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _nameControllers.clear();

    for (final c in _descControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _descControllers.clear();

    _typeValues.clear();
    _requiredValues.clear();
  }

  @override
  void dispose() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      _entityService.save(widget.entityFilePath, _buildDocument());
    }
    _disposeColumnControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: '목록으로',
              ),
              const SizedBox(width: 8),
              Text(
                _doc.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _addColumn,
                icon: const Icon(Icons.add),
                label: const Text('Add Column'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Column table
        Expanded(
          child: _nameControllers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.table_chart_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '칼럼이 없습니다',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _addColumn,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Column'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildColumnTable(),
                ),
        ),
      ],
    );
  }

  Widget _buildColumnTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // name
        1: FlexColumnWidth(1.5), // type
        2: IntrinsicColumnWidth(), // required
        3: FlexColumnWidth(2), // description
        4: IntrinsicColumnWidth(), // delete
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: [
            _buildHeaderCell('Name'),
            _buildHeaderCell('Type'),
            _buildHeaderCell('Required'),
            _buildHeaderCell('Description'),
            const SizedBox(width: 48),
          ],
        ),
        // Data rows
        for (var i = 0; i < _nameControllers.length; i++) _buildColumnRow(i),
      ],
    );
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  TableRow _buildColumnRow(int index) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: _nameControllers[index],
            decoration: const InputDecoration(
              hintText: 'column name',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: DropdownButtonFormField<String>(
            initialValue: _typeValues[index],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: supportedColumnTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _typeValues[index] = value;
                });
                _onFieldChanged();
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Checkbox(
            value: _requiredValues[index],
            onChanged: (value) {
              setState(() {
                _requiredValues[index] = value ?? false;
              });
              _onFieldChanged();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: _descControllers[index],
            decoration: const InputDecoration(
              hintText: 'description',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _removeColumn(index),
          icon: const Icon(Icons.close),
          tooltip: '삭제',
        ),
      ],
    );
  }
}
