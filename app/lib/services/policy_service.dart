import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/policy_document.dart';

class PolicyService {
  static const _illegalChars = r'/\:*?"<>|';
  static const _dirName = 'policies';

  Future<List<PolicySummary>> listPolicies(String projectPath) async {
    final dir = Directory(p.join(projectPath, _dirName));
    if (!await dir.exists()) {
      return [];
    }

    final policies = <PolicySummary>[];
    await for (final entry in dir.list()) {
      if (entry is File && entry.path.endsWith('.md')) {
        final name = p.basenameWithoutExtension(entry.path);
        policies.add(PolicySummary(name: name, filePath: entry.path));
      }
    }
    policies
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return policies;
  }

  Future<PolicyDocument> load(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return PolicyDocument.empty();
    }
    final content = await file.readAsString();
    return parse(content, fallbackName: p.basenameWithoutExtension(filePath));
  }

  PolicyDocument parse(String markdown, {String fallbackName = ''}) {
    final lines = markdown.split('\n');
    String? name;
    int bodyStartIndex = 0;

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('# ')) {
        name = lines[i].substring(2).trim();
        bodyStartIndex = i + 1;
        break;
      }
    }

    if (name == null) {
      // No # heading found — use fallback name, entire content is body
      return PolicyDocument(
        name: fallbackName,
        body: markdown.trim(),
      );
    }

    // Skip leading blank lines after heading
    while (
        bodyStartIndex < lines.length && lines[bodyStartIndex].trim().isEmpty) {
      bodyStartIndex++;
    }

    final body = bodyStartIndex < lines.length
        ? lines.sublist(bodyStartIndex).join('\n').trimRight()
        : '';

    return PolicyDocument(name: name, body: body);
  }

  String serialize(PolicyDocument doc) {
    final buf = StringBuffer();
    buf.writeln('# ${doc.name}');
    if (doc.body.isNotEmpty) {
      buf.writeln();
      buf.writeln(doc.body);
    }
    buf.writeln();
    return buf.toString();
  }

  Future<void> save(String filePath, PolicyDocument doc) async {
    final file = File(filePath);
    await file.writeAsString(serialize(doc));
  }

  Future<String> createPolicy(String projectPath, String name) async {
    final dir = Directory(p.join(projectPath, _dirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final filePath = p.join(dir.path, '$name.md');
    final doc = PolicyDocument(name: name);
    await File(filePath).writeAsString(serialize(doc));

    return filePath;
  }

  Future<void> deletePolicy(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> renamePolicy(
      String oldPath, String newName, String projectPath) async {
    final dir = p.join(projectPath, _dirName);
    final newPath = p.join(dir, '$newName.md');

    if (oldPath != newPath) {
      final file = File(oldPath);
      if (await file.exists()) {
        await file.rename(newPath);
      }
    }

    return newPath;
  }

  String? validatePolicyName(String name, List<String> existingNames) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Policy 이름을 입력해주세요';
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
