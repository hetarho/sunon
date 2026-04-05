import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/product_document.dart';
import '../models/entity_document.dart';

class EntityService {
  static const _illegalChars = r'/\:*?"<>|';

  Future<List<EntitySummary>> listEntities(String projectPath) async {
    final dir = Directory(p.join(projectPath, 'entities'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final entities = <EntitySummary>[];
    await for (final entry in dir.list()) {
      if (entry is File && entry.path.endsWith('.md')) {
        final name = p.basenameWithoutExtension(entry.path);
        entities.add(EntitySummary(name: name, filePath: entry.path));
      }
    }
    entities.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return entities;
  }

  Future<EntityDocument> load(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return EntityDocument.empty();
    }
    final content = await file.readAsString();
    return parse(content);
  }

  EntityDocument parse(String markdown) {
    final lines = markdown.split('\n');
    final doc = EntityDocument.empty();

    String? currentSection;
    String? currentLocalTypeName;
    List<EntityColumn>? currentColumns;
    String? currentEnumName;
    List<String>? currentEnumValues;
    final unknownSections = <RawSection>[];
    String? unknownHeading;
    StringBuffer? unknownBody;
    var nameFound = false;
    var headerSkipped = false;
    var separatorSkipped = false;

    void flushUnknown() {
      if (unknownHeading != null) {
        unknownSections.add(RawSection(
          heading: unknownHeading!,
          body: unknownBody.toString().trim(),
        ));
        unknownHeading = null;
        unknownBody = null;
      }
    }

    void flushLocalType() {
      if (currentLocalTypeName != null && currentColumns != null) {
        doc.localTypes.add(LocalType(
          name: currentLocalTypeName!,
          columns: currentColumns!,
        ));
        currentLocalTypeName = null;
        currentColumns = null;
      }
    }

    void flushLocalEnum() {
      if (currentEnumName != null && currentEnumValues != null) {
        doc.localEnums.add(LocalEnum(
          name: currentEnumName!,
          values: currentEnumValues!,
        ));
        currentEnumName = null;
        currentEnumValues = null;
      }
    }

    for (final line in lines) {
      if (line.startsWith('# ') && !nameFound) {
        nameFound = true;
        doc.name = line.substring(2).trim();
        currentSection = '_name';
        continue;
      }

      if (line.startsWith('## ')) {
        flushUnknown();
        flushLocalType();
        flushLocalEnum();

        final raw = line.substring(3).trim();
        final key = raw.toLowerCase();

        if (key == 'columns') {
          currentSection = 'columns';
          currentColumns = null;
          headerSkipped = false;
          separatorSkipped = false;
        } else if (key.startsWith('type:')) {
          currentSection = 'localtype';
          currentLocalTypeName = raw.substring(5).trim();
          currentColumns = [];
          headerSkipped = false;
          separatorSkipped = false;
        } else if (key.startsWith('enum:')) {
          currentSection = 'localenum';
          currentEnumName = raw.substring(5).trim();
          currentEnumValues = [];
        } else {
          currentSection = '_unknown';
          unknownHeading = line;
          unknownBody = StringBuffer();
        }
        continue;
      }

      if (currentSection == 'columns' || currentSection == 'localtype') {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (!trimmed.startsWith('|')) continue;

        if (!headerSkipped) { headerSkipped = true; continue; }
        if (!separatorSkipped) { separatorSkipped = true; continue; }

        final cols = currentSection == 'columns' ? doc.columns : currentColumns!;
        _parseTableRow(trimmed, cols);
      } else if (currentSection == 'localenum') {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (trimmed.startsWith('- ')) {
          currentEnumValues!.add(trimmed.substring(2));
        }
      } else if (currentSection == '_unknown' && unknownBody != null) {
        unknownBody!.writeln(line);
      }
    }

    flushUnknown();
    flushLocalType();
    flushLocalEnum();

    doc.unknownSections = unknownSections;
    return doc;
  }

  void _parseTableRow(String trimmed, List<EntityColumn> target) {
    final cells = trimmed.split('|').map((c) => c.trim()).toList();

    if (cells.length >= 6) {
      // | name | type | isList | required | description |
      target.add(EntityColumn(
        name: cells[1],
        type: cells[2],
        isList: cells[3].toLowerCase() == 'true',
        required: cells[4].toLowerCase() == 'true',
        description: cells[5],
      ));
    } else if (cells.length >= 5) {
      // Legacy: | name | type | required | description |
      target.add(EntityColumn(
        name: cells[1],
        type: cells[2],
        required: cells[3].toLowerCase() == 'true',
        description: cells[4],
      ));
    }
  }

  String serialize(EntityDocument doc) {
    final buf = StringBuffer();

    buf.writeln('# ${doc.name}');
    buf.writeln();
    buf.writeln('## columns');
    buf.writeln();
    buf.writeln('| name | type | isList | required | description |');
    buf.writeln('|------|------|--------|----------|-------------|');
    for (final col in doc.columns) {
      buf.writeln('| ${col.name} | ${col.type} | ${col.isList} | ${col.required} | ${col.description} |');
    }

    for (final lt in doc.localTypes) {
      buf.writeln();
      buf.writeln('## type: ${lt.name}');
      buf.writeln();
      buf.writeln('| name | type | isList | required | description |');
      buf.writeln('|------|------|--------|----------|-------------|');
      for (final col in lt.columns) {
        buf.writeln('| ${col.name} | ${col.type} | ${col.isList} | ${col.required} | ${col.description} |');
      }
    }

    for (final le in doc.localEnums) {
      buf.writeln();
      buf.writeln('## enum: ${le.name}');
      for (final v in le.values) {
        if (v.trim().isNotEmpty) buf.writeln('- $v');
      }
    }

    for (final section in doc.unknownSections) {
      buf.writeln();
      buf.writeln(section.heading);
      if (section.body.isNotEmpty) {
        buf.writeln(section.body);
      }
    }

    buf.writeln();
    return buf.toString();
  }

  Future<void> save(String filePath, EntityDocument doc) async {
    final file = File(filePath);
    final content = serialize(doc);
    await file.writeAsString(content);
  }

  Future<String> createEntity(String projectPath, String entityName) async {
    final dir = Directory(p.join(projectPath, 'entities'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final filePath = p.join(dir.path, '$entityName.md');
    final file = File(filePath);

    final doc = EntityDocument(name: entityName);
    await file.writeAsString(serialize(doc));

    return filePath;
  }

  Future<void> deleteEntity(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ── Custom Types (stored in types/ directory, same format as entities) ──

  Future<List<EntitySummary>> listTypes(String projectPath) async {
    final dir = Directory(p.join(projectPath, 'types'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final types = <EntitySummary>[];
    await for (final entry in dir.list()) {
      if (entry is File && entry.path.endsWith('.md')) {
        final name = p.basenameWithoutExtension(entry.path);
        types.add(EntitySummary(name: name, filePath: entry.path));
      }
    }
    types.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return types;
  }

  Future<String> createType(String projectPath, String typeName) async {
    final dir = Directory(p.join(projectPath, 'types'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final filePath = p.join(dir.path, '$typeName.md');
    final file = File(filePath);

    final doc = EntityDocument(name: typeName);
    await file.writeAsString(serialize(doc));

    return filePath;
  }

  Future<void> deleteType(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String? validateEntityName(String name, List<String> existingNames) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '엔티티 이름을 입력해주세요';
    }

    for (final ch in _illegalChars.split('')) {
      if (trimmed.contains(ch)) {
        return '사용할 수 없는 문자가 포함되어 있습니다: $ch';
      }
    }

    if (trimmed.startsWith('.')) {
      return '이름이 마침표로 시작할 수 없습니다';
    }

    final lowerName = trimmed.toLowerCase();
    for (final existing in existingNames) {
      if (existing.toLowerCase() == lowerName) {
        return '이미 존재하는 엔티티 이름입니다';
      }
    }

    return null;
  }
}
