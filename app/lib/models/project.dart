class Project {
  String path;
  String name;
  bool isActive;

  Project({
    required this.path,
    required this.name,
    this.isActive = false,
  });
}
