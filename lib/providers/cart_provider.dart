import 'package:flutter/foundation.dart';
import '../models/package.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0, (sum, i) => sum + i.totalPrice);

  double get discount => _discountPct > 0 ? subtotal * (_discountPct / 100) : 0;
  double get total => subtotal - discount;

  double _discountPct = 0;
  double get discountPct => _discountPct;

  void setDiscount(double pct) {
    _discountPct = pct;
    notifyListeners();
  }

  void addItem(AISPackage package) {
    final idx = _items.indexWhere((i) => i.package.id == package.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(CartItem(package: package, addedAt: DateTime.now()));
    }
    notifyListeners();
  }

  void removeItem(String packageId) {
    _items.removeWhere((i) => i.package.id == packageId);
    notifyListeners();
  }

  void decrementItem(String packageId) {
    final idx = _items.indexWhere((i) => i.package.id == packageId);
    if (idx >= 0) {
      if (_items[idx].quantity <= 1) {
        _items.removeAt(idx);
      } else {
        _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity - 1);
      }
      notifyListeners();
    }
  }

  bool contains(String packageId) =>
      _items.any((i) => i.package.id == packageId);

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
