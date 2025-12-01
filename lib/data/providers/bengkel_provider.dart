import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/bengkel_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../../core/constants/app_constants.dart';

class BengkelProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BengkelModel> _nearbyBengkels = [];
  List<BengkelModel> _allBengkels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BengkelModel> get nearbyBengkels => _nearbyBengkels;
  List<BengkelModel> get allBengkels => _allBengkels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNearbyBengkels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      Position? position = await _getCurrentLocation();

      // Load all bengkels
      final querySnapshot = await _firestore
          .collection(AppConstants.bengkelsCollection)
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true)
          .get();

      _allBengkels = querySnapshot.docs
          .map((doc) => BengkelModel.fromMap(doc.data(), doc.id))
          .toList();

      // Calculate distances and sort
      if (position != null) {
        _nearbyBengkels = _allBengkels.map((bengkel) {
          return bengkel;
        }).toList();

        _nearbyBengkels.sort((a, b) {
          final distA = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            a.latitude,
            a.longitude,
          );
          final distB = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            b.latitude,
            b.longitude,
          );
          return distA.compareTo(distB);
        });

        // Take only nearby bengkels (within radius)
        _nearbyBengkels = _nearbyBengkels.take(10).toList();
      } else {
        _nearbyBengkels = _allBengkels.take(10).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data bengkel';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<List<BengkelModel>> searchBengkels(String query) async {
    if (query.isEmpty) return _allBengkels;

    final lowercaseQuery = query.toLowerCase();
    return _allBengkels.where((bengkel) {
      return bengkel.name.toLowerCase().contains(lowercaseQuery) ||
          bengkel.description.toLowerCase().contains(lowercaseQuery) ||
          bengkel.services.any((s) => s.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<BengkelModel?> getBengkelById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.bengkelsCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return BengkelModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> _cartItems = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  List<ProductModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get cartItemCount => _cartItems.length;
  double get cartTotal => _cartItems.fold(
        0,
        (sum, item) => sum + item.price,
      );

  Future<void> loadProducts({String? category, String? bengkelId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection(AppConstants.productsCollection)
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (bengkelId != null) {
        query = query.where('bengkelId', isEqualTo: bengkelId);
      }

      final querySnapshot = await query.get();
      _products = querySnapshot.docs
          .map((doc) =>
              ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
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

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<bool> createOrder(OrderModel order) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .add(order.toMap());

      await loadUserOrders(order.userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSellerOrders(String sellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({
        'status': status,
        'updatedAt': Timestamp.now(),
        if (status == AppConstants.orderCompleted)
          'completedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}

class WalletProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadBalance(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        _balance = (doc.data()?['walletBalance'] ?? 0).toDouble();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> topUp(String userId, double amount) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'walletBalance': FieldValue.increment(amount),
      });

      await _firestore.collection(AppConstants.transactionsCollection).add({
        'userId': userId,
        'type': 'topup',
        'amount': amount,
        'createdAt': Timestamp.now(),
      });

      await loadBalance(userId);
      await loadTransactions(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _transactions = querySnapshot.docs.map((doc) => doc.data()).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get chats => _chats;
  bool get isLoading => _isLoading;

  Future<void> loadChats(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .get();

      _chats = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
