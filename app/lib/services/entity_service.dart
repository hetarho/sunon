import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/product_document.dart';
import '../models/entity_document.dart';

class EntityService {
  static const _illegalChars = r'/\:*?"<>|';

  Future<List<EntitySummary>> listEntities(String projectPath) async {
    final dir = Directory(p.join(projectPath, 'data'));
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

    for (final line in lines) {
      if (line.startsWith('# ') && !nameFound) {
        nameFound = true;
        doc.name = line.substring(2).trim();
        currentSection = '_name';
        continue;
      }

      if (line.startsWith('## ')) {
        flushUnknown();

        final raw = line.substring(3).trim();
        final key = raw.toLowerCase();

        if (key == '속성') {
          currentSection = 'attributes';
          headerSkipped = false;
          separatorSkipped = false;
        } else {
          currentSection = '_unknown';
          unknownHeading = line;
          unknownBody = StringBuffer();
        }
        continue;
      }

      if (currentSection == 'attributes') {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (!trimmed.startsWith('|')) continue;

        if (!headerSkipped) { headerSkipped = true; continue; }
        if (!separatorSkipped) { separatorSkipped = true; continue; }

        final cells = trimmed.split('|').map((c) => c.trim()).toList();
        if (cells.length >= 3) {
          doc.attributes.add(Attribute(
            name: cells[1],
            info: cells[2],
          ));
        }
      } else if (currentSection == '_unknown' && unknownBody != null) {
        unknownBody!.writeln(line);
      }
    }

    flushUnknown();
    doc.unknownSections = unknownSections;
    return doc;
  }

  String serialize(EntityDocument doc) {
    final buf = StringBuffer();

    buf.writeln('# ${doc.name}');
    buf.writeln();
    buf.writeln('## 속성');
    buf.writeln();
    buf.writeln('| 속성명 | 속성 정보 |');
    buf.writeln('|--------|----------|');
    for (final attr in doc.attributes) {
      buf.writeln('| ${attr.name} | ${attr.info} |');
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
    final dir = Directory(p.join(projectPath, 'data'));
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
      return '데이터 항목 이름을 입력해주세요';
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
        return '이미 존재하는 이름입니다';
      }
    }

    return null;
  }
}
