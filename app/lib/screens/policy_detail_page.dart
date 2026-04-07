import 'dart:async';
import 'package:flutter/material.dart';
import '../models/policy_document.dart';
import '../services/policy_service.dart';

class PolicyDetailPage extends StatefulWidget {
  final String projectPath;
  final String policyFilePath;
  final VoidCallback onBack;

  const PolicyDetailPage({
    super.key,
    required this.projectPath,
    required this.policyFilePath,
    required this.onBack,
  });

  @override
  State<PolicyDetailPage> createState() => _PolicyDetailPageState();
}

class _PolicyDetailPageState extends State<PolicyDetailPage> {
  final PolicyService _policyService = PolicyService();

  bool _isLoading = true;
  Timer? _debounceTimer;

  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  String _currentFilePath = '';
  String _originalName = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _currentFilePath = widget.policyFilePath;
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final doc = await _policyService.load(_currentFilePath);
    if (!mounted) return;

    setState(() {
      _originalName = doc.name;
      _titleController.text = doc.name;
      _bodyController.text = doc.body;

      _titleController.addListener(_onFieldChanged);
      _bodyController.addListener(_onFieldChanged);

      _isLoading = false;
    });
  }

  void _onFieldChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _saveToFile);
  }

  Future<void> _saveToFile() async {
    final newName = _titleController.text.trim();
    final body = _bodyController.text;

    // Handle rename if title changed
    if (newName.isNotEmpty && newName != _originalName) {
      // Check for duplicate names
      final policies =
          await _policyService.listPolicies(widget.projectPath);
      final existingNames = policies
          .map((p) => p.name)
          .where((n) => n.toLowerCase() != _originalName.toLowerCase())
          .toList();

      final error = _policyService.validatePolicyName(newName, existingNames);
      if (error != null) {
        // Revert title on error
        _titleController.removeListener(_onFieldChanged);
        _titleController.text = _originalName;
        _titleController.addListener(_onFieldChanged);
        return;
      }

      final newPath = await _policyService.renamePolicy(
          _currentFilePath, newName, widget.projectPath);
      _currentFilePath = newPath;
      _originalName = newName;
    }

    final doc = PolicyDocument(
      name: newName.isNotEmpty ? newName : _originalName,
      body: body,
    );
    await _policyService.save(_currentFilePath, doc);
  }

  @override
  void dispose() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      // Synchronous flush: save current state
      final doc = PolicyDocument(
        name: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : _originalName,
        body: _bodyController.text,
      );
      _policyService.save(_currentFilePath, doc);
    }
    _titleController.removeListener(_onFieldChanged);
    _bodyController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header with back button and title field
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
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.titleLarge,
                  decoration: const InputDecoration(
                    hintText: 'Policy 이름',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Body editor
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _bodyController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: '의사결정 기준을 자유롭게 작성하세요...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
