import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartModel> _items = [];
  List<CartModel> get items => _items;

  // NEW UPDATED METHOD (ACCEPTS productId + productData)
  void addToCart(String productId, Map<String, dynamic> productData) {
    final index = _items.indexWhere((c) => c.productId == productId);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartModel(
          productId: productId,
          product: productData,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  void increase(String productId) {
    final i = _items.indexWhere((c) => c.productId == productId);
    if (i != -1) {
      _items[i].quantity++;
      notifyListeners();
    }
  }

  void decrease(String productId) {
    final i = _items.indexWhere((c) => c.productId == productId);
    if (i != -1) {
      if (_items[i].quantity > 1) {
        _items[i].quantity--;
      } else {
        _items.removeAt(i);
      }
      notifyListeners();
    }
  }

  void remove(String productId) {
    _items.removeWhere((c) => c.productId == productId);
    notifyListeners();
  }

double totalPrice() {
  double total = 0;

  for (var item in items) {
    final double price = (item.product["price"] ?? 0).toDouble();
    final double discount = (item.product["discount"] ?? 0).toDouble();

    final double finalPrice = price - discount;

    total += finalPrice * item.quantity;
  }

  return total;
}


  void clear() {
    _items.clear();
    notifyListeners();
  }
double totalDiscount() {
  double discount = 0;

  for (var item in items) {
    final double d = (item.product["discount"] ?? 0).toDouble();
    discount += d * item.quantity;
  }

  return discount;
}

}
