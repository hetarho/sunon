import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';

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
            child: Center(
              child: Text(
                _menuLabels[_selectedIndex],
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
