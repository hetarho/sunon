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
  bool _isLoading = true;
  String? _selectedEntityPath;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    final entities = await _entityService.listEntities(widget.projectPath);
    if (!mounted) return;
    setState(() {
      _entities = entities;
      _isLoading = false;
    });
  }

  void _openEntity(EntitySummary entity) {
    setState(() {
      _selectedEntityPath = entity.filePath;
    });
  }

  void _goBackToList() {
    setState(() {
      _selectedEntityPath = null;
    });
    _loadEntities();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedEntityPath != null) {
      return EntityDetailPage(
        entityFilePath: _selectedEntityPath!,
        onBack: _goBackToList,
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Entities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _showAddEntityDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Entity'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _entities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '엔티티가 없습니다',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _showAddEntityDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Entity'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _entities.length,
                  itemBuilder: (context, index) {
                    final entity = _entities[index];
                    return ListTile(
                      leading: const Icon(Icons.category),
                      title: Text(entity.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: '삭제',
                        onPressed: () => _showDeleteDialog(entity),
                      ),
                      onTap: () => _openEntity(entity),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showAddEntityDialog() async {
    final controller = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Entity'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '엔티티 이름을 입력하세요',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
                onSubmitted: (_) async {
                  final error = await _createEntity(controller.text);
                  if (error != null) {
                    setDialogState(() => errorText = error);
                  } else {
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final error = await _createEntity(controller.text);
                    if (error != null) {
                      setDialogState(() => errorText = error);
                    } else {
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    }
                  },
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

  Future<String?> _createEntity(String name) async {
    final existingNames = _entities.map((e) => e.name).toList();
    final error = _entityService.validateEntityName(name, existingNames);
    if (error != null) return error;

    await _entityService.createEntity(widget.projectPath, name.trim());
    await _loadEntities();
    return null;
  }

  Future<void> _showDeleteDialog(EntitySummary entity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('엔티티 삭제'),
          content: Text("'${entity.name}' 엔티티를 삭제하시겠습니까?"),
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
      await _entityService.deleteEntity(entity.filePath);
      await _loadEntities();
    }
  }
}
