import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===============================
  // FETCH SELLER ORDERS
  // ===============================
  Future<void> fetchSellerOrders(String sellerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // FETCH USER ORDERS
  // ===============================
  Future<void> fetchUserOrders(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // CREATE ORDER
  // ===============================
  Future<bool> createOrder(OrderModel order) async {
    try {
      if (order.sellerId.isEmpty) {
        throw Exception('Seller ID tidak boleh kosong');
      }

      await _firestore.collection('orders').add(order.toMap());

      // ❌ JANGAN insert ke _orders
      // ✅ BIAR FETCH ULANG SESUAI ROLE

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===============================
  // UPDATE STATUS
  // ===============================
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
        if (status == OrderStatus.completed)
          'completedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===============================
  // CLEAR LOCAL CACHE (LOGOUT)
  // ===============================
  void clearLocal() {
    _orders = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
