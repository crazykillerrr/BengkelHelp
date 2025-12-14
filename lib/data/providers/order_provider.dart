import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSellerOrders(String sellerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders.clear();
      _orders.addAll(
        snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)),
      );

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder(OrderModel order) async {
  try {
    final docRef = await _firestore.collection('orders').add(order.toMap());

    // Update ID di object
    final newOrder = OrderModel(
      id: docRef.id,
      userId: order.userId,
      sellerId: order.sellerId,
      bengkelId: order.bengkelId,
      type: order.type,
      items: order.items,
      totalAmount: order.totalAmount,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      status: order.status,
      paymentMethod: order.paymentMethod,
      deliveryAddress: order.deliveryAddress,
      deliveryLatitude: order.deliveryLatitude,
      deliveryLongitude: order.deliveryLongitude,
      createdAt: order.createdAt,
      completedAt: order.completedAt,
    );

    _orders.insert(0, newOrder);
    notifyListeners();
    return true;

  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}


  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.now(),
        if (status == OrderStatus.completed)
          'completedAt': Timestamp.now(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
