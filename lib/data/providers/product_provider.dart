import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
	final List<ProductModel> _products = [];
	final List<ProductModel> _cartItems = [];
	bool _isLoading = false;

	List<ProductModel> get products => _products;
	List<ProductModel> get cartItems => _cartItems;
	bool get isLoading => _isLoading;
	int get cartItemCount => _cartItems.length;

	Future<void> loadProducts({String? category, String? bengkelId}) async {
		_isLoading = true;
		notifyListeners();
		// Placeholder: no network call here.
		await Future.delayed(const Duration(milliseconds: 50));
		_isLoading = false;
		notifyListeners();
	}

	void addToCart(ProductModel product) {
		_cartItems.add(product);
		notifyListeners();
	}

	void removeFromCart(ProductModel product) {
		_cartItems.remove(product);
		notifyListeners();
	}

	void clearCart() {
		_cartItems.clear();
		notifyListeners();
	}
}
