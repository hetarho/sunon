import 'project.dart';

class Workspace {
  final String path;
  final String name;
  List<Project> projects;

  Workspace({
    required this.path,
    required this.name,
    this.projects = const [],
  });
}
