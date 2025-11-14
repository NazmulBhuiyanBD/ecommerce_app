import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartModel> _items = [];
  List<CartModel> get items => _items;

  void addToCart(Map<String, dynamic> product) {
    final index = _items.indexWhere((c) => c.product['id'] == product['id']);
    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartModel(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void increase(Map<String, dynamic> product) {
    final i = _items.indexWhere((c) => c.product['id'] == product['id']);
    if (i != -1) {
      _items[i].quantity++;
      notifyListeners();
    }
  }

  void decrease(Map<String, dynamic> product) {
    final i = _items.indexWhere((c) => c.product['id'] == product['id']);
    if (i != -1) {
      if (_items[i].quantity > 1) {
        _items[i].quantity--;
      } else {
        _items.removeAt(i);
      }
      notifyListeners();
    }
  }

  void remove(Map<String, dynamic> product) {
    _items.removeWhere((c) => c.product['id'] == product['id']);
    notifyListeners();
  }

  double totalPrice() {
    double total = 0;
    for (var c in _items) {
      final price = double.tryParse(c.product['price'].toString()) ?? 0;
      total += price * c.quantity;
    }
    return total;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
