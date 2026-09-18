// Live CLI: drives a *running* `flutter run` app over the VM service —
// the same channel DevTools/hot-reload use. No accessibility tree, no tap
// simulation. Usage:
//   dart run bin/live_cli.dart <vm-service-uri> state
//   dart run bin/live_cli.dart <vm-service-uri> add apple 2
//   dart run bin/live_cli.dart <vm-service-uri> remove apple
// <vm-service-uri> is whatever `flutter run` prints after
// "A Dart VM Service ... is available at:" (http or ws, with or without /ws).
import 'dart:convert';
import 'dart:io';

import 'package:vm_service/vm_service_io.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
        'usage: dart run bin/live_cli.dart <vm-service-uri> <state|add|remove> [item] [qty]');
    exit(64);
  }
  final service = await vmServiceConnectUri(_toWsUri(args[0]));
  final vm = await service.getVM();
  final isolateId = vm.isolates!.first.id!;

  final Map<String, String> params = switch (args[1]) {
    'add' => {'item': args[2], if (args.length > 3) 'qty': args[3]},
    'remove' => {'item': args[2]},
    _ => {},
  };
  final resp = await service.callServiceExtension(
    'ext.helix_demo.${args[1]}',
    isolateId: isolateId,
    args: params,
  );
  stdout.writeln(jsonEncode(resp.json));
  await service.dispose();
}

String _toWsUri(String uri) {
  var u = uri.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
  if (!u.endsWith('/ws')) {
    u = '${u.endsWith('/') ? u : '$u/'}ws';
  }
  return u;
}
