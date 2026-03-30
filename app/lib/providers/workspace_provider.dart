import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/workspace.dart';
import '../services/workspace_service.dart';
import '../services/persistence_service.dart';

class WorkspaceProvider extends ChangeNotifier {
  final WorkspaceService _workspaceService = WorkspaceService();
  final PersistenceService _persistenceService = PersistenceService();

  Workspace? _workspace;
  bool _isLoading = true;
  bool _isInProjectView = false;

  Workspace? get workspace => _workspace;
  bool get isLoading => _isLoading;
  bool get hasWorkspace => _workspace != null;
  bool get isInProjectView => _isInProjectView;

  /// Skip init: go directly to workspace selection (for new windows).
  void skipInit() {
    _isLoading = false;
    notifyListeners();
  }

  /// Initialize: try to restore last workspace on app start.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final lastPath = await _persistenceService.getLastWorkspacePath();
    if (lastPath != null && await _workspaceService.isValidWorkspacePath(lastPath)) {
      _workspace = await _workspaceService.openWorkspace(lastPath);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Open a workspace from a directory path.
  Future<void> openWorkspace(String directoryPath) async {
    _workspace = await _workspaceService.openWorkspace(directoryPath);
    await _persistenceService.saveLastWorkspacePath(directoryPath);
    notifyListeners();
  }

  /// Navigate into a project's detail view.
  void navigateToProject(int index) {
    setActiveProject(index);
    _isInProjectView = true;
    notifyListeners();
  }

  /// Navigate back from project detail view to project list.
  void navigateBack() {
    _isInProjectView = false;
    notifyListeners();
  }

  /// Set a project as the active project.
  void setActiveProject(int index) {
    if (_workspace == null) return;
    for (var i = 0; i < _workspace!.projects.length; i++) {
      _workspace!.projects[i].isActive = (i == index);
    }
    notifyListeners();
  }

  /// Add a new project: validate, create on disk, refresh list, activate.
  /// Returns an error message on failure, or null on success.
  Future<String?> addProject(String name) async {
    if (_workspace == null) return '워크스페이스가 열려 있지 않습니다';

    final trimmed = name.trim();
    final existingNames = _workspace!.projects.map((p) => p.name).toList();
    final error = _workspaceService.validateProjectName(trimmed, existingNames);
    if (error != null) return error;

    try {
      await _workspaceService.createProject(_workspace!.path, trimmed);
    } catch (e) {
      // Rollback: delete partially created project folder
      final projectDir = Directory('${_workspace!.path}/$trimmed');
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      return '프로젝트 생성 중 오류가 발생했습니다: $e';
    }

    // Refresh and activate the new project
    final projects = await _workspaceService.scanProjects(_workspace!.path);
    for (final p in projects) {
      p.isActive = (p.name == trimmed);
    }
    _workspace!.projects = projects;
    notifyListeners();
    return null;
  }

  /// Refresh the project list (re-scan workspace directory).
  Future<void> refreshProjects() async {
    if (_workspace == null) return;
    final projects = await _workspaceService.scanProjects(_workspace!.path);
    // Preserve active state if possible
    final activeName = _workspace!.projects
        .where((p) => p.isActive)
        .map((p) => p.name)
        .firstOrNull;
    if (activeName != null) {
      for (final p in projects) {
        if (p.name == activeName) p.isActive = true;
      }
    }
    _workspace!.projects = projects;
    notifyListeners();
  }
}
