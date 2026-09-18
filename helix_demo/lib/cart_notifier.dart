import 'package:flutter/foundation.dart';
import 'core.dart';

// Thin ChangeNotifier shell around the headless CartCore, so Provider can
// tell the widget tree to rebuild. CartCore itself stays Flutter-free —
// this is the only file that bridges it into the framework.
class CartNotifier extends ChangeNotifier {
  final _core = CartCore();

  Map<String, dynamic> toJson() => _core.toJson();
  String toJsonString() => _core.toJsonString();

  void add(String item, [int qty = 1]) {
    _core.add(item, qty);
    notifyListeners();
  }

  void remove(String item) {
    _core.remove(item);
    notifyListeners();
  }
}
