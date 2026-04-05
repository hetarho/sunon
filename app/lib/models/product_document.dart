class RawSection {
  final String heading;
  final String body;

  const RawSection({required this.heading, required this.body});
}

class ProductDocument {
  String name;
  String mission;
  List<String> benefits;
  List<String> principles;
  List<RawSection> unknownSections;

  ProductDocument({
    this.name = '',
    this.mission = '',
    List<String>? benefits,
    List<String>? principles,
    List<RawSection>? unknownSections,
  })  : benefits = benefits ?? [],
        principles = principles ?? [],
        unknownSections = unknownSections ?? [];

  factory ProductDocument.empty() => ProductDocument();
}
