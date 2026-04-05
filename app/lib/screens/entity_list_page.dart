import 'package:flutter/material.dart';
import '../models/entity_document.dart';
import '../services/entity_service.dart';
import 'entity_detail_page.dart';

class EntityListPage extends StatefulWidget {
  final String projectPath;

  const EntityListPage({super.key, required this.projectPath});

  @override
  State<EntityListPage> createState() => _EntityListPageState();
}

class _EntityListPageState extends State<EntityListPage> {
  final EntityService _entityService = EntityService();

  List<EntitySummary> _entities = [];
  List<EntitySummary> _types = [];
  bool _isLoading = true;

  // Detail navigation state
  String? _selectedPath;
  DetailKind? _selectedKind;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      _entityService.listEntities(widget.projectPath),
      _entityService.listTypes(widget.projectPath),
    ]);
    if (!mounted) return;
    setState(() {
      _entities = results[0];
      _types = results[1];
      _isLoading = false;
    });
  }

  void _openDetail(EntitySummary item, DetailKind kind) {
    setState(() {
      _selectedPath = item.filePath;
      _selectedKind = kind;
    });
  }

  void _goBackToList() {
    setState(() {
      _selectedPath = null;
      _selectedKind = null;
    });
    _loadAll();
  }

  // ── Entity CRUD ──

  Future<String?> _createEntity(String name) async {
    final existingNames = _entities.map((e) => e.name).toList();
    final error = _entityService.validateEntityName(name, existingNames);
    if (error != null) return error;

    await _entityService.createEntity(widget.projectPath, name.trim());
    await _loadAll();
    return null;
  }

  Future<void> _deleteEntity(EntitySummary entity) async {
    await _entityService.deleteEntity(entity.filePath);
    await _loadAll();
  }

  // ── Type CRUD ──

  Future<String?> _createType(String name) async {
    final existingNames = _types.map((e) => e.name).toList();
    final error = _entityService.validateEntityName(name, existingNames);
    if (error != null) return error;

    await _entityService.createType(widget.projectPath, name.trim());
    await _loadAll();
    return null;
  }

  Future<void> _deleteType(EntitySummary type) async {
    await _entityService.deleteType(type.filePath);
    await _loadAll();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    if (_selectedPath != null) {
      return EntityDetailPage(
        projectPath: widget.projectPath,
        entityFilePath: _selectedPath!,
        kind: _selectedKind!,
        onBack: _goBackToList,
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        // ── Entities section ──
        _buildSectionHeader(
          title: 'Entities',
          onAdd: () => _showAddDialog(
            title: 'Add Entity',
            hint: '엔티티 이름을 입력하세요',
            onCreate: _createEntity,
          ),
        ),
        const Divider(height: 1),
        if (_entities.isEmpty)
          _buildEmptyState(
            icon: Icons.category_outlined,
            message: '엔티티가 없습니다',
            onAdd: () => _showAddDialog(
              title: 'Add Entity',
              hint: '엔티티 이름을 입력하세요',
              onCreate: _createEntity,
            ),
          )
        else
          ...List.generate(_entities.length, (index) {
            final entity = _entities[index];
            return ListTile(
              leading: const Icon(Icons.category),
              title: Text(entity.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '삭제',
                onPressed: () => _showDeleteDialog(
                  entity,
                  label: '엔티티',
                  onConfirm: () => _deleteEntity(entity),
                ),
              ),
              onTap: () => _openDetail(entity, DetailKind.entity),
            );
          }),

        const SizedBox(height: 16),

        // ── Types section ──
        _buildSectionHeader(
          title: 'Types',
          onAdd: () => _showAddDialog(
            title: 'Add Type',
            hint: '타입 이름을 입력하세요',
            onCreate: _createType,
          ),
        ),
        const Divider(height: 1),
        if (_types.isEmpty)
          _buildEmptyState(
            icon: Icons.data_object,
            message: '커스텀 타입이 없습니다',
            onAdd: () => _showAddDialog(
              title: 'Add Type',
              hint: '타입 이름을 입력하세요',
              onCreate: _createType,
            ),
          )
        else
          ...List.generate(_types.length, (index) {
            final type = _types[index];
            return ListTile(
              leading: const Icon(Icons.data_object),
              title: Text(type.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '삭제',
                onPressed: () => _showDeleteDialog(
                  type,
                  label: '타입',
                  onConfirm: () => _deleteType(type),
                ),
              ),
              onTap: () => _openDetail(type, DetailKind.type),
            );
          }),
      ],
    );
  }

  // ── Shared UI helpers ──

  Widget _buildSectionHeader({required String title, required VoidCallback onAdd}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text('Add $title'.replaceFirst('s', '')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog({
    required String title,
    required String hint,
    required Future<String?> Function(String) onCreate,
  }) async {
    final controller = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final error = await onCreate(controller.text);
              if (error != null) {
                setDialogState(() => errorText = error);
              } else {
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              }
            }

            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
                onSubmitted: (_) => submit(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: submit,
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showDeleteDialog(
    EntitySummary item, {
    required String label,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$label 삭제'),
          content: Text("'${item.name}' $label을(를) 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onConfirm();
    }
  }
}
