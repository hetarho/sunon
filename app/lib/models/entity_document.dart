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
  bool isList;
  bool required;
  String description;

  EntityColumn({
    this.name = '',
    this.type = 'string',
    this.isList = false,
    this.required = false,
    this.description = '',
  });
}

class LocalType {
  String name;
  List<EntityColumn> columns;

  LocalType({
    this.name = '',
    List<EntityColumn>? columns,
  }) : columns = columns ?? [];
}

class LocalEnum {
  String name;
  List<String> values;

  LocalEnum({
    this.name = '',
    List<String>? values,
  }) : values = values ?? [];
}

class EntityDocument {
  String name;
  List<EntityColumn> columns;
  List<LocalType> localTypes;
  List<LocalEnum> localEnums;
  List<RawSection> unknownSections;

  EntityDocument({
    this.name = '',
    List<EntityColumn>? columns,
    List<LocalType>? localTypes,
    List<LocalEnum>? localEnums,
    List<RawSection>? unknownSections,
  })  : columns = columns ?? [],
        localTypes = localTypes ?? [],
        localEnums = localEnums ?? [],
        unknownSections = unknownSections ?? [];

  factory EntityDocument.empty() => EntityDocument();
}

class EntitySummary {
  final String name;
  final String filePath;

  const EntitySummary({required this.name, required this.filePath});
}
