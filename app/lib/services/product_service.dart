import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/product_document.dart';

class ProductService {
  static const _knownSections = {'mission', 'principles'};

  Future<ProductDocument> load(String projectPath) async {
    final file = File(p.join(projectPath, 'product.md'));
    if (!await file.exists()) {
      return ProductDocument.empty();
    }
    final content = await file.readAsString();
    return parse(content);
  }

  Future<void> save(String projectPath, ProductDocument doc) async {
    final file = File(p.join(projectPath, 'product.md'));
    final content = serialize(doc);
    await file.writeAsString(content);
  }

  ProductDocument parse(String markdown) {
    final lines = markdown.split('\n');
    final doc = ProductDocument.empty();

    String? currentSection;
    final sectionBodies = <String, StringBuffer>{};
    final unknownSections = <RawSection>[];
    String? unknownHeading;
    StringBuffer? unknownBody;

    var nameFound = false;

    for (final line in lines) {
      if (line.startsWith('# ') && !nameFound) {
        nameFound = true;
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
        if (_knownSections.contains(key)) {
          currentSection = key;
          sectionBodies.putIfAbsent(key, () => StringBuffer());
        } else {
          currentSection = '_unknown';
          unknownHeading = line;
          unknownBody = StringBuffer();
        }
        continue;
      }

      if (currentSection == '_name') {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && doc.name.isEmpty) {
          doc.name = trimmed;
        }
      } else if (currentSection == '_unknown' && unknownBody != null) {
        unknownBody.writeln(line);
      } else if (currentSection != null && _knownSections.contains(currentSection)) {
        sectionBodies[currentSection]!.writeln(line);
      }
    }

    // Flush last unknown section
    if (unknownHeading != null) {
      unknownSections.add(RawSection(
        heading: unknownHeading,
        body: unknownBody.toString().trim(),
      ));
    }

    doc.mission = (sectionBodies['mission']?.toString() ?? '').trim();

    final principlesRaw = sectionBodies['principles']?.toString() ?? '';
    doc.principles = principlesRaw
        .split('\n')
        .where((l) => l.trimLeft().startsWith('- '))
        .map((l) => l.trimLeft().substring(2))
        .toList();

    doc.unknownSections = unknownSections;

    return doc;
  }

  String serialize(ProductDocument doc) {
    final buf = StringBuffer();

    buf.writeln('# product');
    buf.writeln(doc.name);

    buf.writeln();
    buf.writeln('## mission');
    if (doc.mission.isNotEmpty) {
      buf.writeln(doc.mission);
    }

    buf.writeln();
    buf.writeln('## principles');
    final nonEmpty = doc.principles.where((p) => p.trim().isNotEmpty);
    for (final principle in nonEmpty) {
      buf.writeln('- $principle');
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
}
