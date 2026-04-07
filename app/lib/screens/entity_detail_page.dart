import 'dart:async';
import 'package:flutter/material.dart';
import '../models/entity_document.dart';
import '../services/entity_service.dart';

class EntityDetailPage extends StatefulWidget {
  final String projectPath;
  final String entityFilePath;
  final VoidCallback onBack;

  const EntityDetailPage({
    super.key,
    required this.projectPath,
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

  // Attribute controllers
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _infoControllers = [];

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
      _disposeAllControllers();

      for (final attr in doc.attributes) {
        _addAttributeControllers(attr);
      }

      _isLoading = false;
    });
  }

  void _addAttributeControllers(Attribute attr) {
    final nameC = TextEditingController(text: attr.name);
    final infoC = TextEditingController(text: attr.info);
    nameC.addListener(_onFieldChanged);
    infoC.addListener(_onFieldChanged);
    _nameControllers.add(nameC);
    _infoControllers.add(infoC);
  }

  void _addAttribute() {
    setState(() => _addAttributeControllers(Attribute()));
    _onFieldChanged();
  }

  void _removeAttribute(int index) {
    setState(() {
      _nameControllers[index].removeListener(_onFieldChanged);
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
      _infoControllers[index].removeListener(_onFieldChanged);
      _infoControllers[index].dispose();
      _infoControllers.removeAt(index);
    });
    _onFieldChanged();
  }

  void _onFieldChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _saveToFile);
  }

  EntityDocument _buildDocument() {
    final attributes = <Attribute>[];
    for (var i = 0; i < _nameControllers.length; i++) {
      attributes.add(Attribute(
        name: _nameControllers[i].text,
        info: _infoControllers[i].text,
      ));
    }

    return EntityDocument(
      name: _doc.name,
      attributes: attributes,
      unknownSections: _doc.unknownSections,
    );
  }

  Future<void> _saveToFile() async {
    await _entityService.save(widget.entityFilePath, _buildDocument());
  }

  void _disposeAllControllers() {
    for (final c in _nameControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _nameControllers.clear();
    for (final c in _infoControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _infoControllers.clear();
  }

  @override
  void dispose() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      _entityService.save(widget.entityFilePath, _buildDocument());
    }
    _disposeAllControllers();
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
              Text(_doc.name, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: _addAttribute,
                icon: const Icon(Icons.add),
                label: const Text('속성 추가'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _nameControllers.isEmpty
                ? _buildEmptyAttributes()
                : _buildAttributeTable(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAttributes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.table_chart_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('속성이 없습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _addAttribute, icon: const Icon(Icons.add), label: const Text('속성 추가')),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
          children: [
            _headerCell('속성명'),
            _headerCell('속성 정보'),
            const SizedBox(width: 48),
          ],
        ),
        for (var i = 0; i < _nameControllers.length; i++)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: _nameControllers[i],
                  decoration: const InputDecoration(hintText: '속성명', border: OutlineInputBorder(), isDense: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: _infoControllers[i],
                  decoration: const InputDecoration(hintText: '속성 정보를 자유롭게 입력하세요', border: OutlineInputBorder(), isDense: true),
                ),
              ),
              IconButton(onPressed: () => _removeAttribute(i), icon: const Icon(Icons.close), tooltip: '삭제'),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
