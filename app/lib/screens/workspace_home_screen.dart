import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';

class WorkspaceHomeScreen extends StatelessWidget {
  const WorkspaceHomeScreen({super.key});

  Future<void> _openNewWindow() async {
    await WindowController.create(
      WindowConfiguration(arguments: jsonEncode({'newWindow': true})),
    );
  }

  Future<void> _addProject(BuildContext context) async {
    final controller = TextEditingController();
    String? errorText;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('프로젝트 추가'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '프로젝트명',
                  errorText: errorText,
                ),
                onSubmitted: (_) {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.of(context).pop(text);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.of(context).pop(text);
                    } else {
                      setState(() {
                        errorText = '프로젝트명을 입력해 주세요';
                      });
                    }
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );

    if (name == null || !context.mounted) return;

    final error = await context.read<WorkspaceProvider>().addProject(name);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _openWorkspace(BuildContext context) async {
    final home = Platform.environment['HOME'] ?? '/';
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Workspace Directory',
      initialDirectory: home,
    );
    if (path != null && context.mounted) {
      await context.read<WorkspaceProvider>().openWorkspace(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        final workspace = provider.workspace!;
        final projects = workspace.projects;

        return Scaffold(
          appBar: AppBar(
            title: Text(workspace.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: '프로젝트 추가',
                onPressed: () => _addProject(context),
              ),
              IconButton(
                icon: const Icon(Icons.folder_open),
                tooltip: 'Open Workspace',
                onPressed: () => _openWorkspace(context),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'New Window',
                onPressed: _openNewWindow,
              ),
            ],
          ),
          body: projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_off,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '프로젝트가 없습니다',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Workspace 디렉토리에 폴더를 추가해 주세요',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ListTile(
                      leading: Icon(
                        Icons.folder,
                        color: project.isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(
                        project.name,
                        style: project.isActive
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      selected: project.isActive,
                      onTap: () => provider.navigateToProject(index),
                    );
                  },
                ),
        );
      },
    );
  }
}
