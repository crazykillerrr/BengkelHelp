import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
	final List<OrderModel> _orders = [];
	bool _isLoading = false;

	List<OrderModel> get orders => _orders;
	bool get isLoading => _isLoading;

	Future<void> loadUserOrders(String userId) async {
		_isLoading = true;
		notifyListeners();
		await Future.delayed(const Duration(milliseconds: 50));
		_isLoading = false;
		notifyListeners();
	}

	Future<void> loadSellerOrders(String sellerId) async {
		_isLoading = true;
		notifyListeners();
		await Future.delayed(const Duration(milliseconds: 50));
		_isLoading = false;
		notifyListeners();
	}

	Future<bool> createOrder(OrderModel order) async {
		// Placeholder: pretend to create order
		_orders.insert(0, order);
		notifyListeners();
		return true;
	}
}
