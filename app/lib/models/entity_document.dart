import 'product_document.dart';

const List<String> supportedColumnTypes = [
  'int',
  'string',
  'float',
  'bool',
  'datetime',
  'text',
];

class EntityColumn {
  String name;
  String type;
  bool required;
  String description;

  EntityColumn({
    this.name = '',
    this.type = 'string',
    this.required = false,
    this.description = '',
  });
}

class EntityDocument {
  String name;
  List<EntityColumn> columns;
  List<RawSection> unknownSections;

  EntityDocument({
    this.name = '',
    List<EntityColumn>? columns,
    List<RawSection>? unknownSections,
  })  : columns = columns ?? [],
        unknownSections = unknownSections ?? [];

  factory EntityDocument.empty() => EntityDocument();
}

class EntitySummary {
  final String name;
  final String filePath;

  const EntitySummary({required this.name, required this.filePath});
}
