import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
	double _balance = 0.0;
	final List<Map<String, dynamic>> _transactions = [];
	bool _isLoading = false;

	double get balance => _balance;
	List<Map<String, dynamic>> get transactions => _transactions;
	bool get isLoading => _isLoading;

	Future<void> loadBalance(String userId) async {
		_isLoading = true;
		notifyListeners();
		await Future.delayed(const Duration(milliseconds: 50));
		_isLoading = false;
		notifyListeners();
	}

	Future<void> loadTransactions(String userId) async {
		_isLoading = true;
		notifyListeners();
		await Future.delayed(const Duration(milliseconds: 50));
		_isLoading = false;
		notifyListeners();
	}

	Future<bool> topUp(String userId, double amount) async {
		// Placeholder: simulate success and update balance
		_balance += amount;
		_transactions.add({
			'userId': userId,
			'type': 'topup',
			'amount': amount,
			'createdAt': DateTime.now(),
		});
		notifyListeners();
		return true;
	}
}
