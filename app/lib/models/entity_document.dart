import 'product_document.dart';

class Attribute {
  String name;
  String info;

  Attribute({
    this.name = '',
    this.info = '',
  });
}

class EntityDocument {
  String name;
  List<Attribute> attributes;
  List<RawSection> unknownSections;

  EntityDocument({
    this.name = '',
    List<Attribute>? attributes,
    List<RawSection>? unknownSections,
  })  : attributes = attributes ?? [],
        unknownSections = unknownSections ?? [];

  factory EntityDocument.empty() => EntityDocument();
}

class EntitySummary {
  final String name;
  final String filePath;

  const EntitySummary({required this.name, required this.filePath});
}
