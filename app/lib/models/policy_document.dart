class PolicyDocument {
  String name;
  String body;

  PolicyDocument({
    this.name = '',
    this.body = '',
  });

  factory PolicyDocument.empty() => PolicyDocument();
}

class PolicySummary {
  final String name;
  final String filePath;

  const PolicySummary({required this.name, required this.filePath});
}
