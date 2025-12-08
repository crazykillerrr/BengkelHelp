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
    final existingItem = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final item = _cartItems.firstWhere((item) => item.product.id == productId);
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      item.quantity = quantity;
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
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
          product: ProductModel(
            id: '',
            sellerId: '',
            bengkelId: '',
            name: '',
            description: '',
            category: '',
            price: 0,
            stock: 0,
            imageUrls: [],
            createdAt: DateTime.now(),
          ),
          quantity: 0),
    );
    return item.quantity;
  }
}
