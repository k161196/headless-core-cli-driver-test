import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_notifier.dart';

void main() => runApp(const HelixDemoApp());

class HelixDemoApp extends StatefulWidget {
  const HelixDemoApp({super.key});

  @override
  State<HelixDemoApp> createState() => _HelixDemoAppState();
}

class _HelixDemoAppState extends State<HelixDemoApp> {
  final _notifier = CartNotifier();

  @override
  void initState() {
    super.initState();
    // Debug-only command channel: an external process (our live CLI) can
    // call these over the VM service URI `flutter run` prints, driving the
    // same notifier Provider rebuilds the UI from — no accessibility tree.
    developer.registerExtension('ext.helix_demo.add', (method, params) async {
      _notifier.add(
          params['item'] ?? 'apple', int.tryParse(params['qty'] ?? '1') ?? 1);
      return developer.ServiceExtensionResponse.result(
          _notifier.toJsonString());
    });
    developer.registerExtension('ext.helix_demo.remove', (method, params) async {
      _notifier.remove(params['item'] ?? '');
      return developer.ServiceExtensionResponse.result(
          _notifier.toJsonString());
    });
    developer.registerExtension('ext.helix_demo.state', (method, params) async {
      return developer.ServiceExtensionResponse.result(
          _notifier.toJsonString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: const MaterialApp(
          home: CartPage(), debugShowCheckedModeBanner: false),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CartNotifier>();
    final state = notifier.toJson();
    return Scaffold(
      appBar: AppBar(title: const Text('Helix demo (provider)')),
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
                          onPressed: () => notifier.remove(e.key),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.add('apple'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
