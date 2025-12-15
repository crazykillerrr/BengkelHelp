import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(ProductModel product, {int quantity = 1}) {
    if (product.stock <= 0) return;

    final index =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      final newQty = _cartItems[index].quantity + quantity;
      if (newQty <= product.stock) {
        _cartItems[index].quantity = newQty;
      }
    } else {
      if (quantity <= product.stock) {
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index =
        _cartItems.indexWhere((item) => item.product.id == productId);

    if (index == -1) return;

    if (quantity <= 0) {
      removeFromCart(productId);
    } else if (quantity <= _cartItems[index].product.stock) {
      _cartItems[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final item = _cartItems
        .where((item) => item.product.id == productId)
        .toList();
    return item.isEmpty ? 0 : item.first.quantity;
  }
}

