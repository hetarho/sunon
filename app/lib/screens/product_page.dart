import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../models/product_document.dart';
import '../providers/workspace_provider.dart';
import '../services/product_service.dart';
import '../services/workspace_service.dart';

class ProductPage extends StatefulWidget {
  final String projectPath;

  const ProductPage({super.key, required this.projectPath});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _productService = ProductService();
  final WorkspaceService _workspaceService = WorkspaceService();

  final _nameController = TextEditingController();
  final _missionController = TextEditingController();
  final _benefitControllers = <TextEditingController>[];
  final _principleControllers = <TextEditingController>[];

  ProductDocument _doc = ProductDocument.empty();
  String _currentProjectPath = '';
  String _lastSavedName = '';
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentProjectPath = widget.projectPath;
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final doc = await _productService.load(_currentProjectPath);
    if (!mounted) return;

    // If name is empty (new project / empty file), init from folder name
    if (doc.name.isEmpty) {
      doc.name = p.basename(_currentProjectPath);
    }

    setState(() {
      _doc = doc;
      _nameController.text = doc.name;
      _missionController.text = doc.mission;
      _lastSavedName = doc.name;

      _disposeBenefitControllers();
      for (final benefit in doc.benefits) {
        final c = TextEditingController(text: benefit);
        c.addListener(_onFieldChanged);
        _benefitControllers.add(c);
      }

      _disposePrincipleControllers();
      for (final principle in doc.principles) {
        final c = TextEditingController(text: principle);
        c.addListener(_onFieldChanged);
        _principleControllers.add(c);
      }

      _isLoading = false;
    });

    _nameController.addListener(_onFieldChanged);
    _missionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _saveToFile);
  }

  ProductDocument _buildDocument() {
    return ProductDocument(
      name: _nameController.text,
      mission: _missionController.text,
      benefits: _benefitControllers.map((c) => c.text).toList(),
      principles: _principleControllers.map((c) => c.text).toList(),
      unknownSections: _doc.unknownSections,
    );
  }

  Future<void> _saveToFile() async {
    final doc = _buildDocument();
    final newName = doc.name.trim();

    try {
      // Check if name changed → rename folder
      if (newName.isNotEmpty && newName != _lastSavedName) {
        final newPath = await _workspaceService.renameProject(
          _currentProjectPath,
          newName,
        );
        _currentProjectPath = newPath;
        _lastSavedName = newName;

        if (mounted) {
          context.read<WorkspaceProvider>().updateProjectPath(
                widget.projectPath,
                newPath,
                newName,
              );
        }
      }

      await _productService.save(_currentProjectPath, doc);
    } on Exception catch (e) {
      if (!mounted) return;
      // Revert name on rename failure
      if (newName != _lastSavedName) {
        _nameController.removeListener(_onFieldChanged);
        _nameController.text = _lastSavedName;
        _nameController.addListener(_onFieldChanged);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  void _addPrinciple() {
    setState(() {
      final c = TextEditingController();
      c.addListener(_onFieldChanged);
      _principleControllers.add(c);
    });
    _onFieldChanged();
  }

  void _removePrinciple(int index) {
    setState(() {
      _principleControllers[index].removeListener(_onFieldChanged);
      _principleControllers[index].dispose();
      _principleControllers.removeAt(index);
    });
    _onFieldChanged();
  }

  void _disposeBenefitControllers() {
    for (final c in _benefitControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _benefitControllers.clear();
  }

  void _addBenefit() {
    setState(() {
      final c = TextEditingController();
      c.addListener(_onFieldChanged);
      _benefitControllers.add(c);
    });
    _onFieldChanged();
  }

  void _removeBenefit(int index) {
    setState(() {
      _benefitControllers[index].removeListener(_onFieldChanged);
      _benefitControllers[index].dispose();
      _benefitControllers.removeAt(index);
    });
    _onFieldChanged();
  }

  void _disposePrincipleControllers() {
    for (final c in _principleControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _principleControllers.clear();
  }

  @override
  void dispose() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      _productService.save(_currentProjectPath, _buildDocument());
    }

    _nameController.dispose();
    _missionController.dispose();
    _disposeBenefitControllers();
    _disposePrincipleControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            'Product Name',
            tooltip: '프로덕트의 고유한 이름입니다. 변경 시 프로젝트 폴더명도 함께 변경됩니다.',
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: '프로덕트 이름을 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionLabel(
            'Mission',
            tooltip: '프로덕트가 존재하는 근본적인 이유입니다. 어떤 문제를 어떻게 해결하는지 한 문장으로 표현하세요.',
          ),
          TextField(
            controller: _missionController,
            maxLines: null,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: '프로덕트의 미션을 작성하세요',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionLabel(
            'Benefit',
            tooltip: '사용자가 이 프로덕트를 통해 얻는 핵심 혜택입니다. 사용자 관점에서 구체적인 가치를 작성하세요.',
          ),
          ..._buildListSection(
            controllers: _benefitControllers,
            hintText: '혜택을 입력하세요',
            onRemove: _removeBenefit,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addBenefit,
            icon: const Icon(Icons.add),
            label: const Text('혜택 추가'),
          ),
          const SizedBox(height: 24),
          _buildSectionLabel(
            'Principles',
            tooltip: '프로덕트를 만들 때 지켜야 할 핵심 원칙들입니다. 의사결정의 기준이 되는 철학을 나열하세요.',
          ),
          ..._buildListSection(
            controllers: _principleControllers,
            hintText: '원칙을 입력하세요',
            onRemove: _removePrinciple,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addPrinciple,
            icon: const Icon(Icons.add),
            label: const Text('원칙 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {required String tooltip}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 4),
          Tooltip(
            message: tooltip,
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListSection({
    required List<TextEditingController> controllers,
    required String hintText,
    required void Function(int) onRemove,
  }) {
    return List.generate(controllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controllers[index],
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onRemove(index),
              icon: const Icon(Icons.close),
              tooltip: '삭제',
            ),
          ],
        ),
      );
    });
  }
}
