// Claude Code PostToolUse hook.
//
// After Claude edits or writes a .dart file: formats it with `dart format`
// and analyzes it with `dart analyze`. Errors and warnings are sent back to
// Claude (exit code 2) so it fixes them right away. Lint infos are left to
// /review and CI (`flutter analyze --fatal-infos`) to avoid noise during
// multi-step edits.
//
// Written in Dart (not bash + jq) so it runs anywhere the Flutter SDK does.

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final input = await stdin.transform(utf8.decoder).join();

  final filePath = _extractFilePath(input);
  if (filePath == null || !_shouldProcess(filePath)) {
    exit(0);
  }

  final format = await Process.run('dart', ['format', filePath]);
  if (format.exitCode != 0) {
    stderr.writeln('dart format failed for $filePath:\n${format.stderr}');
    exit(2);
  }

  final analyze = await Process.run('dart', ['analyze', filePath]);
  if (analyze.exitCode != 0) {
    stderr.writeln(
      'dart analyze found errors/warnings in $filePath. Fix them:\n'
      '${analyze.stdout}${analyze.stderr}',
    );
    exit(2);
  }

  exit(0);
}

String? _extractFilePath(String input) {
  try {
    final decoded = jsonDecode(input);
    if (decoded case {'tool_input': {'file_path': final String path}}) {
      return path;
    }
  } on FormatException {
    return null;
  }
  return null;
}

bool _shouldProcess(String path) {
  final normalized = path.replaceAll(r'\', '/');
  return normalized.endsWith('.dart') &&
      !normalized.endsWith('.g.dart') &&
      !normalized.endsWith('.freezed.dart') &&
      !normalized.contains('/.claude/') &&
      !normalized.contains('/build/') &&
      File(path).existsSync();
}
