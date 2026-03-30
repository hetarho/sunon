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

  /// Project template: directories to create under a new project.
  static const List<String> templateDirs = [
    'policies/data',
    'policies/format',
    'policies/system',
    'policies/ux',
    'policies/validate',
    'entities',
    'elements',
    'user stories',
    'specs',
  ];

  /// Project template: files to create under a new project.
  static const List<String> templateFiles = [
    'product.md',
  ];

  /// Creates a new project folder with the standard template structure.
  /// Throws on file system errors (caller should handle rollback).
  Future<String> createProject(String workspacePath, String projectName) async {
    final projectPath = p.join(workspacePath, projectName);
    final projectDir = Directory(projectPath);

    await projectDir.create();

    for (final dir in templateDirs) {
      await Directory(p.join(projectPath, dir)).create(recursive: true);
    }

    for (final file in templateFiles) {
      await File(p.join(projectPath, file)).create();
    }

    return projectPath;
  }

  /// Validates a project name. Returns an error message or null if valid.
  String? validateProjectName(String name, List<String> existingNames) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '프로젝트명을 입력해 주세요';
    }

    if (RegExp(r'[/\\:*?"<>|]').hasMatch(trimmed)) {
      return '사용할 수 없는 문자가 포함되어 있습니다';
    }

    if (trimmed.startsWith('.')) {
      return '마침표로 시작할 수 없습니다';
    }

    if (trimmed.length > 255) {
      return '프로젝트명이 너무 깁니다';
    }

    final lowerName = trimmed.toLowerCase();
    for (final existing in existingNames) {
      if (existing.toLowerCase() == lowerName) {
        return '이미 존재하는 프로젝트입니다';
      }
    }

    return null;
  }
}
