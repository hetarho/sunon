import 'package:flutter/material.dart';
import '../models/policy_document.dart';
import '../services/policy_service.dart';
import 'policy_detail_page.dart';

class PolicyListPage extends StatefulWidget {
  final String projectPath;

  const PolicyListPage({super.key, required this.projectPath});

  @override
  State<PolicyListPage> createState() => _PolicyListPageState();
}

class _PolicyListPageState extends State<PolicyListPage> {
  final PolicyService _policyService = PolicyService();

  List<PolicySummary> _policies = [];
  bool _isLoading = true;

  // Detail navigation state
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final policies = await _policyService.listPolicies(widget.projectPath);
    if (!mounted) return;
    setState(() {
      _policies = policies;
      _isLoading = false;
    });
  }

  void _openDetail(PolicySummary item) {
    setState(() {
      _selectedPath = item.filePath;
    });
  }

  void _goBackToList() {
    setState(() {
      _selectedPath = null;
    });
    _loadAll();
  }

  Future<String?> _createPolicy(String name) async {
    final existingNames = _policies.map((e) => e.name).toList();
    final error = _policyService.validatePolicyName(name, existingNames);
    if (error != null) return error;

    final filePath =
        await _policyService.createPolicy(widget.projectPath, name.trim());
    await _loadAll();
    // Navigate to newly created policy
    setState(() {
      _selectedPath = filePath;
    });
    return null;
  }

  Future<void> _deletePolicy(PolicySummary policy) async {
    await _policyService.deletePolicy(policy.filePath);
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPath != null) {
      return PolicyDetailPage(
        projectPath: widget.projectPath,
        policyFilePath: _selectedPath!,
        onBack: _goBackToList,
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        _buildSectionHeader(),
        const Divider(height: 1),
        if (_policies.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(_policies.length, (index) {
            final policy = _policies[index];
            return ListTile(
              leading: const Icon(Icons.policy),
              title: Text(policy.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '삭제',
                onPressed: () => _showDeleteDialog(policy),
              ),
              onTap: () => _openDetail(policy),
            );
          }),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text('Policies', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _showAddDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Policy 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.policy_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Policy가 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final error = await _createPolicy(controller.text);
              if (error != null) {
                setDialogState(() => errorText = error);
              } else {
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              }
            }

            return AlertDialog(
              title: const Text('Policy 추가'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Policy 이름을 입력하세요',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
                onSubmitted: (_) => submit(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: submit,
                  child: const Text('생성'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showDeleteDialog(PolicySummary item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Policy 삭제'),
          content: Text("'${item.name}' Policy를 삭제하시겠습니까?"),
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
      await _deletePolicy(item);
    }
  }
}
