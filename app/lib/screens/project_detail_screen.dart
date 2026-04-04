import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import 'product_page.dart';
import 'entity_list_page.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _selectedIndex = 0;

  static const List<String> _menuLabels = [
    'Product',
    'Entities',
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

  Widget _buildContent(String projectPath) {
    switch (_selectedIndex) {
      case 0:
        return ProductPage(projectPath: projectPath);
      case 1:
        return EntityListPage(projectPath: projectPath);
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
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
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
        ],
      ),
    );
  }
}
