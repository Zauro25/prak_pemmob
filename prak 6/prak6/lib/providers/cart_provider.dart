import 'package:flutter/foundation.dart';
import 'dart:collection';
import '../models/item.dart';

class CartProvider extends ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  void addItem(Item item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(Item item) {
    _items.remove(item);
    notifyListeners();
  }

  // Quantity of a specific item currently in the cart
  int quantityFor(Item item) {
    return _items.where((e) => e == item).length;
  }

  // Increment quantity (same as addItem but semantically clearer for UI buttons)
  void increment(Item item) {
    addItem(item);
  }

  // Decrement quantity (removes a single instance if present)
  void decrement(Item item) {
    final index = _items.indexOf(item);
    if (index != -1) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Returns grouped items with their quantities preserving insertion order
  List<MapEntry<Item, int>> get itemsWithQuantities {
    final map = LinkedHashMap<Item, int>();
    for (final item in _items) {
      map[item] = (map[item] ?? 0) + 1;
    }
    return map.entries.toList();
  }

  // Remove all occurrences of an item
  void removeAllOf(Item item) {
    _items.removeWhere((e) => e == item);
    notifyListeners();
  }
}
