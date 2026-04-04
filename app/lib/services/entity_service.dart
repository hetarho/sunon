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
    final unknownSections = <RawSection>[];
    String? unknownHeading;
    StringBuffer? unknownBody;
    var nameFound = false;
    var headerSkipped = false;
    var separatorSkipped = false;

    for (final line in lines) {
      if (line.startsWith('# ') && !nameFound) {
        nameFound = true;
        doc.name = line.substring(2).trim();
        currentSection = '_name';
        continue;
      }

      if (line.startsWith('## ')) {
        // Flush previous unknown section
        if (unknownHeading != null) {
          unknownSections.add(RawSection(
            heading: unknownHeading,
            body: unknownBody.toString().trim(),
          ));
          unknownHeading = null;
          unknownBody = null;
        }

        final key = line.substring(3).trim().toLowerCase();
        if (key == 'columns') {
          currentSection = 'columns';
          headerSkipped = false;
          separatorSkipped = false;
        } else {
          currentSection = '_unknown';
          unknownHeading = line;
          unknownBody = StringBuffer();
        }
        continue;
      }

      if (currentSection == 'columns') {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (!trimmed.startsWith('|')) continue;

        if (!headerSkipped) {
          headerSkipped = true;
          continue;
        }
        if (!separatorSkipped) {
          separatorSkipped = true;
          continue;
        }

        // Parse data row: | name | type | required | description |
        final cells = trimmed
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();

        if (cells.isNotEmpty) {
          doc.columns.add(EntityColumn(
            name: cells.isNotEmpty ? cells[0] : '',
            type: cells.length > 1 ? cells[1] : 'string',
            required: cells.length > 2 ? cells[2].toLowerCase() == 'true' : false,
            description: cells.length > 3 ? cells[3] : '',
          ));
        }
      } else if (currentSection == '_unknown' && unknownBody != null) {
        unknownBody.writeln(line);
      }
    }

    // Flush last unknown section
    if (unknownHeading != null) {
      unknownSections.add(RawSection(
        heading: unknownHeading,
        body: unknownBody.toString().trim(),
      ));
    }

    doc.unknownSections = unknownSections;
    return doc;
  }

  String serialize(EntityDocument doc) {
    final buf = StringBuffer();

    buf.writeln('# ${doc.name}');
    buf.writeln();
    buf.writeln('## columns');
    buf.writeln();
    buf.writeln('| name | type | required | description |');
    buf.writeln('|------|------|----------|-------------|');
    for (final col in doc.columns) {
      buf.writeln('| ${col.name} | ${col.type} | ${col.required} | ${col.description} |');
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
