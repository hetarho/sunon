import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const _lastWorkspacePathKey = 'last_workspace_path';

  Future<void> saveLastWorkspacePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWorkspacePathKey, path);
  }

  Future<String?> getLastWorkspacePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastWorkspacePathKey);
  }
}
