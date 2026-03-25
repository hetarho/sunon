import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';

class WorkspaceSelectionScreen extends StatelessWidget {
  const WorkspaceSelectionScreen({super.key});

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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Sunon',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a workspace to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _openWorkspace(context),
              icon: const Icon(Icons.folder_open),
              label: const Text('Open Workspace'),
            ),
          ],
        ),
      ),
    );
  }
}
