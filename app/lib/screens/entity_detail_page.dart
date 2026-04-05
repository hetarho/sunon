import 'dart:async';
import 'package:flutter/material.dart';
import '../models/entity_document.dart';
import '../services/entity_service.dart';

enum DetailKind { entity, type }

class EntityDetailPage extends StatefulWidget {
  final String projectPath;
  final String entityFilePath;
  final DetailKind kind;
  final VoidCallback onBack;

  const EntityDetailPage({
    super.key,
    required this.projectPath,
    required this.entityFilePath,
    this.kind = DetailKind.entity,
    required this.onBack,
  });

  @override
  State<EntityDetailPage> createState() => _EntityDetailPageState();
}

// Controllers for one local type's columns
class _LocalTypeCtrl {
  final TextEditingController nameController;
  final List<TextEditingController> colNameCtrls = [];
  final List<TextEditingController> colDescCtrls = [];
  final List<String> colTypeValues = [];
  final List<bool> colIsListValues = [];
  final List<bool> colRequiredValues = [];

  _LocalTypeCtrl(String name) : nameController = TextEditingController(text: name);

  void dispose(void Function() listener) {
    nameController.removeListener(listener);
    nameController.dispose();
    for (final c in colNameCtrls) {
      c.removeListener(listener);
      c.dispose();
    }
    for (final c in colDescCtrls) {
      c.removeListener(listener);
      c.dispose();
    }
  }
}

class _LocalEnumCtrl {
  final TextEditingController nameController;
  final List<TextEditingController> valueCtrls = [];

  _LocalEnumCtrl(String name) : nameController = TextEditingController(text: name);

  void dispose(void Function() listener) {
    nameController.removeListener(listener);
    nameController.dispose();
    for (final c in valueCtrls) {
      c.removeListener(listener);
      c.dispose();
    }
  }
}

class _EntityDetailPageState extends State<EntityDetailPage> {
  final EntityService _entityService = EntityService();

  EntityDocument _doc = EntityDocument.empty();
  List<String> _entityNames = [];
  List<String> _typeNames = [];
  bool _isLoading = true;
  Timer? _debounceTimer;

  // Main columns controllers
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _descControllers = [];
  final List<String> _typeValues = [];
  final List<bool> _isListValues = [];
  final List<bool> _requiredValues = [];

  // Local types & enums controllers
  final List<_LocalTypeCtrl> _localTypeCtrls = [];
  final List<_LocalEnumCtrl> _localEnumCtrls = [];

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final results = await Future.wait([
      _entityService.load(widget.entityFilePath),
      _entityService.listEntities(widget.projectPath),
      _entityService.listTypes(widget.projectPath),
    ]);
    if (!mounted) return;

    final doc = results[0] as EntityDocument;
    final entities = results[1] as List<EntitySummary>;
    final types = results[2] as List<EntitySummary>;

    setState(() {
      _doc = doc;
      _entityNames = entities
          .map((e) => e.name)
          .where((name) => name != doc.name)
          .toList();
      _typeNames = types
          .map((e) => e.name)
          .where((name) => widget.kind != DetailKind.type || name != doc.name)
          .toList();

      _disposeAllControllers();

      for (final col in doc.columns) {
        _addColumnControllers(col);
      }
      for (final lt in doc.localTypes) {
        _addLocalType(lt);
      }
      for (final le in doc.localEnums) {
        _addLocalEnum(le);
      }

      _isLoading = false;
    });
  }

  // ── Main column helpers ──

  void _addColumnControllers(EntityColumn col) {
    final nameC = TextEditingController(text: col.name);
    final descC = TextEditingController(text: col.description);
    nameC.addListener(_onFieldChanged);
    descC.addListener(_onFieldChanged);
    _nameControllers.add(nameC);
    _descControllers.add(descC);
    _typeValues.add(col.type);
    _isListValues.add(col.isList);
    _requiredValues.add(col.required);
  }

  void _addColumn() {
    setState(() => _addColumnControllers(EntityColumn()));
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
      _isListValues.removeAt(index);
      _requiredValues.removeAt(index);
    });
    _onFieldChanged();
  }

  // ── Local type helpers ──

  void _addLocalType(LocalType lt) {
    final ctrl = _LocalTypeCtrl(lt.name);
    ctrl.nameController.addListener(_onFieldChanged);
    for (final col in lt.columns) {
      _addLocalTypeColumn(ctrl, col);
    }
    _localTypeCtrls.add(ctrl);
  }

  void _addLocalTypeColumn(_LocalTypeCtrl ctrl, EntityColumn col) {
    final nameC = TextEditingController(text: col.name);
    final descC = TextEditingController(text: col.description);
    nameC.addListener(_onFieldChanged);
    descC.addListener(_onFieldChanged);
    ctrl.colNameCtrls.add(nameC);
    ctrl.colDescCtrls.add(descC);
    ctrl.colTypeValues.add(col.type);
    ctrl.colIsListValues.add(col.isList);
    ctrl.colRequiredValues.add(col.required);
  }

  void _addNewLocalType() {
    setState(() => _addLocalType(LocalType()));
    _onFieldChanged();
  }

  void _removeLocalType(int ltIndex) {
    setState(() {
      _localTypeCtrls[ltIndex].dispose(_onFieldChanged);
      _localTypeCtrls.removeAt(ltIndex);
    });
    _onFieldChanged();
  }

  void _addColumnToLocalType(int ltIndex) {
    setState(() => _addLocalTypeColumn(_localTypeCtrls[ltIndex], EntityColumn()));
    _onFieldChanged();
  }

  void _removeColumnFromLocalType(int ltIndex, int colIndex) {
    setState(() {
      final ctrl = _localTypeCtrls[ltIndex];
      ctrl.colNameCtrls[colIndex].removeListener(_onFieldChanged);
      ctrl.colNameCtrls[colIndex].dispose();
      ctrl.colNameCtrls.removeAt(colIndex);
      ctrl.colDescCtrls[colIndex].removeListener(_onFieldChanged);
      ctrl.colDescCtrls[colIndex].dispose();
      ctrl.colDescCtrls.removeAt(colIndex);
      ctrl.colTypeValues.removeAt(colIndex);
      ctrl.colIsListValues.removeAt(colIndex);
      ctrl.colRequiredValues.removeAt(colIndex);
    });
    _onFieldChanged();
  }

  // ── Local enum helpers ──

  void _addLocalEnum(LocalEnum le) {
    final ctrl = _LocalEnumCtrl(le.name);
    ctrl.nameController.addListener(_onFieldChanged);
    for (final v in le.values) {
      final c = TextEditingController(text: v);
      c.addListener(_onFieldChanged);
      ctrl.valueCtrls.add(c);
    }
    _localEnumCtrls.add(ctrl);
  }

  void _addNewLocalEnum() {
    setState(() => _addLocalEnum(LocalEnum()));
    _onFieldChanged();
  }

  void _removeLocalEnum(int index) {
    setState(() {
      _localEnumCtrls[index].dispose(_onFieldChanged);
      _localEnumCtrls.removeAt(index);
    });
    _onFieldChanged();
  }

  void _addEnumValue(int enumIndex) {
    setState(() {
      final c = TextEditingController();
      c.addListener(_onFieldChanged);
      _localEnumCtrls[enumIndex].valueCtrls.add(c);
    });
    _onFieldChanged();
  }

  void _removeEnumValue(int enumIndex, int valueIndex) {
    setState(() {
      final ctrl = _localEnumCtrls[enumIndex];
      ctrl.valueCtrls[valueIndex].removeListener(_onFieldChanged);
      ctrl.valueCtrls[valueIndex].dispose();
      ctrl.valueCtrls.removeAt(valueIndex);
    });
    _onFieldChanged();
  }

  // ── Document build / save ──

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
        isList: _isListValues[i],
        required: _requiredValues[i],
        description: _descControllers[i].text,
      ));
    }

    final localTypes = <LocalType>[];
    for (final ctrl in _localTypeCtrls) {
      final cols = <EntityColumn>[];
      for (var i = 0; i < ctrl.colNameCtrls.length; i++) {
        cols.add(EntityColumn(
          name: ctrl.colNameCtrls[i].text,
          type: ctrl.colTypeValues[i],
          isList: ctrl.colIsListValues[i],
          required: ctrl.colRequiredValues[i],
          description: ctrl.colDescCtrls[i].text,
        ));
      }
      localTypes.add(LocalType(name: ctrl.nameController.text, columns: cols));
    }

    final localEnums = <LocalEnum>[];
    for (final ctrl in _localEnumCtrls) {
      localEnums.add(LocalEnum(
        name: ctrl.nameController.text,
        values: ctrl.valueCtrls.map((c) => c.text).toList(),
      ));
    }

    return EntityDocument(
      name: _doc.name,
      columns: columns,
      localTypes: localTypes,
      localEnums: localEnums,
      unknownSections: _doc.unknownSections,
    );
  }

  Future<void> _saveToFile() async {
    await _entityService.save(widget.entityFilePath, _buildDocument());
  }

  // ── Dispose ──

  void _disposeAllControllers() {
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
    _isListValues.clear();
    _requiredValues.clear();

    for (final ctrl in _localTypeCtrls) {
      ctrl.dispose(_onFieldChanged);
    }
    _localTypeCtrls.clear();

    for (final ctrl in _localEnumCtrls) {
      ctrl.dispose(_onFieldChanged);
    }
    _localEnumCtrls.clear();
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

  // ── Dropdown helpers ──

  List<String> get _localTypeNames =>
      _localTypeCtrls.map((c) => c.nameController.text).where((n) => n.isNotEmpty).toList();

  List<String> get _localEnumNames =>
      _localEnumCtrls.map((c) => c.nameController.text).where((n) => n.isNotEmpty).toList();

  List<DropdownMenuItem<String>> _buildTypeDropdownItems() {
    final items = <DropdownMenuItem<String>>[];

    for (final t in supportedColumnTypes) {
      items.add(DropdownMenuItem(value: t, child: Text(t)));
    }

    if (_entityNames.isNotEmpty) {
      items.add(const DropdownMenuItem(enabled: false, value: null, child: Divider(height: 1)));
      for (final name in _entityNames) {
        items.add(DropdownMenuItem(
          value: name,
          child: Text(name, style: const TextStyle(fontStyle: FontStyle.italic)),
        ));
      }
    }

    if (_typeNames.isNotEmpty) {
      items.add(const DropdownMenuItem(enabled: false, value: null, child: Divider(height: 1)));
      for (final name in _typeNames) {
        items.add(DropdownMenuItem(
          value: name,
          child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        ));
      }
    }

    final localNames = [..._localTypeNames, ..._localEnumNames];
    if (localNames.isNotEmpty) {
      items.add(const DropdownMenuItem(enabled: false, value: null, child: Divider(height: 1)));
      for (final name in localNames) {
        items.add(DropdownMenuItem(
          value: name,
          child: Text(name, style: const TextStyle(decoration: TextDecoration.underline)),
        ));
      }
    }

    return items;
  }

  String _resolveTypeValue(String type) {
    if (supportedColumnTypes.contains(type)) return type;
    if (_entityNames.contains(type)) return type;
    if (_typeNames.contains(type)) return type;
    if (_localTypeNames.contains(type)) return type;
    if (_localEnumNames.contains(type)) return type;
    return 'string';
  }

  // ── Build UI ──

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
                onPressed: _addColumn,
                icon: const Icon(Icons.add),
                label: const Text('Add Column'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main columns
                if (_nameControllers.isEmpty)
                  _buildEmptyColumns()
                else
                  _buildColumnTable(
                    nameControllers: _nameControllers,
                    descControllers: _descControllers,
                    typeValues: _typeValues,
                    isListValues: _isListValues,
                    requiredValues: _requiredValues,
                    onRemove: _removeColumn,
                  ),

                const SizedBox(height: 32),

                // Local types & enums section
                Row(
                  children: [
                    Text('Types', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: '이 엔티티에서만 사용하는 하위 타입입니다.',
                      child: Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.outline),
                    ),
                    const Spacer(),
                    MenuAnchor(
                      builder: (context, controller, child) {
                        return TextButton.icon(
                          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        );
                      },
                      menuChildren: [
                        MenuItemButton(
                          leadingIcon: const Icon(Icons.data_object),
                          onPressed: _addNewLocalType,
                          child: const Text('Struct'),
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(Icons.list_alt),
                          onPressed: _addNewLocalEnum,
                          child: const Text('Enum'),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                if (_localTypeCtrls.isEmpty && _localEnumCtrls.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        '로컬 타입이 없습니다',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  )
                else ...[
                  ...List.generate(_localTypeCtrls.length, _buildLocalTypeSection),
                  ...List.generate(_localEnumCtrls.length, _buildLocalEnumSection),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyColumns() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.table_chart_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('칼럼이 없습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _addColumn, icon: const Icon(Icons.add), label: const Text('Add Column')),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalTypeSection(int ltIndex) {
    final ctrl = _localTypeCtrls[ltIndex];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type name + actions
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl.nameController,
                    decoration: const InputDecoration(
                      hintText: '타입 이름',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addColumnToLocalType(ltIndex),
                  icon: const Icon(Icons.add),
                  tooltip: '칼럼 추가',
                ),
                IconButton(
                  onPressed: () => _removeLocalType(ltIndex),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '타입 삭제',
                ),
              ],
            ),
            if (ctrl.colNameCtrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildColumnTable(
                nameControllers: ctrl.colNameCtrls,
                descControllers: ctrl.colDescCtrls,
                typeValues: ctrl.colTypeValues,
                isListValues: ctrl.colIsListValues,
                requiredValues: ctrl.colRequiredValues,
                onRemove: (colIndex) => _removeColumnFromLocalType(ltIndex, colIndex),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocalEnumSection(int enumIndex) {
    final ctrl = _localEnumCtrls[enumIndex];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl.nameController,
                    decoration: const InputDecoration(
                      hintText: 'enum 이름',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(label: const Text('enum'), visualDensity: VisualDensity.compact),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addEnumValue(enumIndex),
                  icon: const Icon(Icons.add),
                  tooltip: '값 추가',
                ),
                IconButton(
                  onPressed: () => _removeLocalEnum(enumIndex),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'enum 삭제',
                ),
              ],
            ),
            if (ctrl.valueCtrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...List.generate(ctrl.valueCtrls.length, (vIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Text('• '),
                      Expanded(
                        child: TextField(
                          controller: ctrl.valueCtrls[vIndex],
                          decoration: const InputDecoration(
                            hintText: '값',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeEnumValue(enumIndex, vIndex),
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: '삭제',
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  // ── Shared table builder ──

  Widget _buildColumnTable({
    required List<TextEditingController> nameControllers,
    required List<TextEditingController> descControllers,
    required List<String> typeValues,
    required List<bool> isListValues,
    required List<bool> requiredValues,
    required void Function(int) onRemove,
  }) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
        4: FlexColumnWidth(2),
        5: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
          children: [
            _headerCell('Name'),
            _headerCell('Type'),
            _headerCell('List'),
            _headerCell('Required'),
            _headerCell('Description'),
            const SizedBox(width: 48),
          ],
        ),
        for (var i = 0; i < nameControllers.length; i++)
          _dataRow(
            nameCtrl: nameControllers[i],
            descCtrl: descControllers[i],
            typeValues: typeValues,
            isListValues: isListValues,
            requiredValues: requiredValues,
            index: i,
            onRemove: () => onRemove(i),
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

  TableRow _dataRow({
    required TextEditingController nameCtrl,
    required TextEditingController descCtrl,
    required List<String> typeValues,
    required List<bool> isListValues,
    required List<bool> requiredValues,
    required int index,
    required VoidCallback onRemove,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: 'column name', border: OutlineInputBorder(), isDense: true),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _resolveTypeValue(typeValues[index]),
                isExpanded: true,
                isDense: true,
                items: _buildTypeDropdownItems(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => typeValues[index] = value);
                    _onFieldChanged();
                  }
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Checkbox(
            value: isListValues[index],
            onChanged: (v) {
              setState(() => isListValues[index] = v ?? false);
              _onFieldChanged();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Checkbox(
            value: requiredValues[index],
            onChanged: (v) {
              setState(() => requiredValues[index] = v ?? false);
              _onFieldChanged();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: descCtrl,
            decoration: const InputDecoration(hintText: 'description', border: OutlineInputBorder(), isDense: true),
          ),
        ),
        IconButton(onPressed: onRemove, icon: const Icon(Icons.close), tooltip: '삭제'),
      ],
    );
  }
}
