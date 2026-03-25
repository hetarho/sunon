import 'package:flutter/foundation.dart';
import '../models/workspace.dart';
import '../services/workspace_service.dart';
import '../services/persistence_service.dart';

class WorkspaceProvider extends ChangeNotifier {
  final WorkspaceService _workspaceService = WorkspaceService();
  final PersistenceService _persistenceService = PersistenceService();

  Workspace? _workspace;
  bool _isLoading = true;

  Workspace? get workspace => _workspace;
  bool get isLoading => _isLoading;
  bool get hasWorkspace => _workspace != null;

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

  /// Set a project as the active project.
  void setActiveProject(int index) {
    if (_workspace == null) return;
    for (var i = 0; i < _workspace!.projects.length; i++) {
      _workspace!.projects[i].isActive = (i == index);
    }
    notifyListeners();
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
