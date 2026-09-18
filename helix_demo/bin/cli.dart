// CLI driver: talks to the headless core over stdin/stdout.
// `dart run bin/cli.dart` — no Flutter SDK, no simulator, no engine boot.
// Commands: `add <item> [qty]`, `remove <item>`, `state`, `quit`.
import 'dart:convert';
import 'dart:io';
import 'package:helix_demo/core.dart';

Future<void> main() async {
  final core = CartCore();
  stdout.writeln(core.toJsonString());
  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) continue;
    switch (parts[0]) {
      case 'add':
        core.add(parts[1], parts.length > 2 ? int.parse(parts[2]) : 1);
        break;
      case 'remove':
        core.remove(parts[1]);
        break;
      case 'state':
        break;
      case 'quit':
        return;
      default:
        stderr.writeln('unknown command: $line');
        continue;
    }
    stdout.writeln(core.toJsonString());
  }
}
