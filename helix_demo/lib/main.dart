import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'core.dart';

void main() => runApp(const HelixDemoApp());

class HelixDemoApp extends StatelessWidget {
  const HelixDemoApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: CartPage(), debugShowCheckedModeBanner: false);
}

// Same CartCore class the CLI drives headlessly — proves the core has
// zero Flutter dependency and is shared verbatim, not re-implemented.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _core = CartCore();

  @override
  void initState() {
    super.initState();
    // Debug-only command channel: an external process (our live CLI) can
    // call these over the VM service URI `flutter run` prints, driving the
    // exact same core the taps drive — no accessibility tree involved.
    developer.registerExtension('ext.helix_demo.add', (method, params) async {
      setState(() => _core.add(
          params['item'] ?? 'apple', int.tryParse(params['qty'] ?? '1') ?? 1));
      return developer.ServiceExtensionResponse.result(_core.toJsonString());
    });
    developer.registerExtension('ext.helix_demo.remove', (method, params) async {
      setState(() => _core.remove(params['item'] ?? ''));
      return developer.ServiceExtensionResponse.result(_core.toJsonString());
    });
    developer.registerExtension('ext.helix_demo.state', (method, params) async {
      return developer.ServiceExtensionResponse.result(_core.toJsonString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _core.toJson();
    return Scaffold(
      appBar: AppBar(title: const Text('Helix demo (shared core)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Total qty: ${state['totalQty']}'),
          ),
          Expanded(
            child: ListView(
              children: (state['items'] as Map).entries
                  .map((e) => ListTile(
                        title: Text('${e.key} x${e.value}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(() => _core.remove(e.key)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _core.add('apple')),
        child: const Icon(Icons.add),
      ),
    );
  }
}
