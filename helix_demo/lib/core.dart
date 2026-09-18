// Headless core: pure Dart, zero UI dependency. Runs identically in a
// bare `dart run` process (CLI-driven) or inside the Flutter app.
import 'dart:convert';

class CartCore {
  final Map<String, int> _items = {};

  void add(String item, [int qty = 1]) {
    _items[item] = (_items[item] ?? 0) + qty;
  }

  void remove(String item) {
    if (!_items.containsKey(item)) return;
    final left = _items[item]! - 1;
    if (left <= 0) {
      _items.remove(item);
    } else {
      _items[item] = left;
    }
  }

  Map<String, dynamic> toJson() => {
        'items': _items,
        'totalQty': _items.values.fold(0, (a, b) => a + b),
      };

  String toJsonString() => jsonEncode(toJson());
}
