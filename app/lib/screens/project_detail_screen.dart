import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import 'product_page.dart';
import 'entity_list_page.dart';
import 'policy_list_page.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _selectedIndex = 0;
  bool _isPanelOpen = false;

  static const List<String> _menuLabels = [
    'Product',
    'Data Items',
    'Policies',
    'User Stories',
    'Elements',
    'Specs',
  ];

  static const List<IconData> _menuIcons = [
    Icons.hub,
    Icons.category,
    Icons.policy,
    Icons.people,
    Icons.widgets,
    Icons.description,
  ];

  // Document Architecture layer reference rule:
  // Each menu index maps to the list of menu indices it can reference.
  // 0=Product, 1=Entities, 2=Policies, 3=UserStories, 4=Elements, 5=Specs
  static const Map<int, List<int>> _layerReferences = {
    0: [],              // Product: no references
    1: [0],             // Entities: Product
    2: [0, 1],          // Policies: Product, Entities
    3: [0, 1, 2],       // UserStories: Product, Entities, Policies
    4: [0, 1, 2],       // Elements: Product, Entities, Policies
    5: [0, 1, 2, 3, 4], // Specs: all
  };

  bool get _canOpenPanel => _layerReferences[_selectedIndex]!.isNotEmpty;

  Widget _buildContent(String projectPath) {
    switch (_selectedIndex) {
      case 0:
        return ProductPage(projectPath: projectPath);
      case 1:
        return EntityListPage(projectPath: projectPath);
      case 2:
        return PolicyListPage(projectPath: projectPath);
      default:
        return Center(
          child: Text(
            _menuLabels[_selectedIndex],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        );
    }
  }

  Widget _buildContextPanel(String projectPath) {
    final refs = _layerReferences[_selectedIndex]!;
    if (refs.isEmpty) return const SizedBox.shrink();

    final sections = <Widget>[];
    for (final refIndex in refs) {
      switch (refIndex) {
        case 0:
          sections.add(
            ExpansionTile(
              title: const Text('Product'),
              initiallyExpanded: true,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: ProductPage(projectPath: projectPath),
                ),
              ],
            ),
          );
          break;
        default:
          sections.add(
            ExpansionTile(
              title: Text(_menuLabels[refIndex]),
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${_menuLabels[refIndex]} 컨텍스트는 향후 지원 예정입니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          );
      }
    }

    return SingleChildScrollView(child: Column(children: sections));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkspaceProvider>();
    final activeProject = provider.workspace?.projects
        .where((p) => p.isActive)
        .firstOrNull;
    final projectName = activeProject?.name ?? 'Project';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => provider.navigateBack(),
        ),
        title: Text(projectName),
        actions: [
          IconButton(
            onPressed: _canOpenPanel
                ? () => setState(() => _isPanelOpen = !_isPanelOpen)
                : null,
            icon: Icon(
              Icons.vertical_split,
              color: _canOpenPanel ? null : Theme.of(context).disabledColor,
            ),
            tooltip: _canOpenPanel ? '컨텍스트 패널' : '이 페이지에서는 참조할 컨텍스트가 없습니다',
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                // Auto-close panel when navigating to a page with no references
                if (_layerReferences[index]!.isEmpty) {
                  _isPanelOpen = false;
                }
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: List.generate(_menuLabels.length, (index) {
              return NavigationRailDestination(
                icon: Icon(_menuIcons[index]),
                label: Text(_menuLabels[index]),
              );
            }),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: activeProject != null
                ? _buildContent(activeProject.path)
                : const SizedBox.shrink(),
          ),
          if (_isPanelOpen && activeProject != null) ...[
            const VerticalDivider(thickness: 1, width: 1),
            SizedBox(
              width: 320,
              child: _buildContextPanel(activeProject.path),
            ),
          ],
        ],
      ),
    );
  }
}
