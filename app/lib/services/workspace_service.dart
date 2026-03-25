import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/project.dart';
import '../models/workspace.dart';

class WorkspaceService {
  /// Scans the given directory and returns a Workspace with its projects.
  /// Projects are direct subdirectories (excluding hidden folders).
  /// Sorted alphabetically A→Z.
  Future<Workspace> openWorkspace(String directoryPath) async {
    final projects = await scanProjects(directoryPath);
    return Workspace(
      path: directoryPath,
      name: p.basename(directoryPath),
      projects: projects,
    );
  }

  /// Lists subdirectories, filters hidden folders and files, sorts A→Z.
  Future<List<Project>> scanProjects(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final entities = await dir.list().toList();
    final projects = <Project>[];

    for (final entity in entities) {
      if (entity is Directory) {
        final name = p.basename(entity.path);
        if (!name.startsWith('.')) {
          projects.add(Project(path: entity.path, name: name));
        }
      } else if (entity is Link) {
        // Include symlinks that point to directories
        final target = await entity.target();
        if (await FileSystemEntity.isDirectory(target)) {
          final name = p.basename(entity.path);
          if (!name.startsWith('.')) {
            projects.add(Project(path: entity.path, name: name));
          }
        }
      }
    }

    projects.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return projects;
  }

  /// Checks if a directory path is valid and exists.
  Future<bool> isValidWorkspacePath(String path) async {
    return await Directory(path).exists();
  }
}
