import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

class WalletProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  
  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  
  /// LOAD BALANCE FROM FIRESTORE
  Future<void> loadBalance(String userId) async {
    try {
      print('💰 Loading balance for user: $userId');
      
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        _balance = (data?['walletBalance'] ?? 0).toDouble();
        
        print('✅ Balance loaded: $_balance');
        notifyListeners();
      } else {
        print('⚠️  User document not found');
        _balance = 0.0;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error loading balance: $e');
      _balance = 0.0;
      notifyListeners();
    }
  }
  
  /// TOP UP BALANCE (SAVE TO FIRESTORE)
  Future<bool> topUp(String userId, double amount) async {
    try {
      print('💵 Top up requested:');
      print('   User ID: $userId');
      print('   Amount: $amount');
      print('   Current balance: $_balance');
      
      // Calculate new balance
      final newBalance = _balance + amount;
      print('   New balance will be: $newBalance');
      
      // Update balance in Firestore using transaction for safety
      await _firestore.runTransaction((transaction) async {
        // Get current user document
        final userDoc = await transaction.get(
          _firestore.collection(AppConstants.usersCollection).doc(userId),
        );
        
        if (!userDoc.exists) {
          throw Exception('User document not found');
        }
        
        // Update wallet balance
        transaction.update(
          _firestore.collection(AppConstants.usersCollection).doc(userId),
          {
            'walletBalance': FieldValue.increment(amount),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
        
        print('✅ Balance updated in Firestore');
      });
      
      // Create transaction record
      final transactionData = {
        'userId': userId,
        'type': 'topup',
        'amount': amount,
        'description': 'Top Up BengkelPay',
        'balanceBefore': _balance,
        'balanceAfter': newBalance,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .add(transactionData);
      
      print('✅ Transaction record created');
      
      // Update local balance
      _balance = newBalance;
      
      // Reload balance from Firestore to ensure sync
      await loadBalance(userId);
      
      // Reload transactions
      await loadTransactions(userId);
      
      print('✅ Top up completed successfully');
      print('   Final balance: $_balance');
      
      return true;
    } catch (e, stackTrace) {
      print('❌ Error during top up: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// DEDUCT BALANCE (FOR PAYMENTS)
  Future<bool> deductBalance(String userId, double amount, String description) async {
    try {
      print('💸 Payment requested:');
      print('   User ID: $userId');
      print('   Amount: $amount');
      print('   Current balance: $_balance');
      
      // Check if balance is sufficient
      if (_balance < amount) {
        print('❌ Insufficient balance');
        return false;
      }
      
      final newBalance = _balance - amount;
      print('   New balance will be: $newBalance');
      
      // Update balance in Firestore
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(
          _firestore.collection(AppConstants.usersCollection).doc(userId),
        );
        
        if (!userDoc.exists) {
          throw Exception('User document not found');
        }
        
        final currentBalance = (userDoc.data()?['walletBalance'] ?? 0).toDouble();
        
        if (currentBalance < amount) {
          throw Exception('Insufficient balance');
        }
        
        transaction.update(
          _firestore.collection(AppConstants.usersCollection).doc(userId),
          {
            'walletBalance': FieldValue.increment(-amount),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
        
        print('✅ Balance deducted in Firestore');
      });
      
      // Create transaction record
      final transactionData = {
        'userId': userId,
        'type': 'payment',
        'amount': amount,
        'description': description,
        'balanceBefore': _balance,
        'balanceAfter': newBalance,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .add(transactionData);
      
      print('✅ Payment transaction recorded');
      
      // Update local balance
      _balance = newBalance;
      
      // Reload from Firestore
      await loadBalance(userId);
      await loadTransactions(userId);
      
      print('✅ Payment completed successfully');
      print('   Final balance: $_balance');
      
      return true;
    } catch (e, stackTrace) {
      print('❌ Error during payment: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// LOAD TRANSACTION HISTORY
  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('📜 Loading transactions for user: $userId');
      
      final querySnapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      _transactions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      
      print('✅ Loaded ${_transactions.length} transactions');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading transactions: $e');
      _transactions = [];
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// GET TRANSACTION BY ID
  Future<Map<String, dynamic>?> getTransaction(String transactionId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .get();
      
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting transaction: $e');
      return null;
    }
  }
  
  /// CLEAR LOCAL DATA (FOR LOGOUT)
  void clearData() {
    print('🧹 Clearing wallet data');
    _balance = 0.0;
    _transactions = [];
    notifyListeners();
  }
}