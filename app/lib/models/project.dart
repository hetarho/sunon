class Project {
  final String path;
  final String name;
  bool isActive;

  Project({
    required this.path,
    required this.name,
    this.isActive = false,
  });
}
