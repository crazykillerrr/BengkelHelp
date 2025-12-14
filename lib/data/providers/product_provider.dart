import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ------------------------------
  // FETCH SEMUA PRODUK (untuk User Shop)
  // ------------------------------
  Future<void> loadProducts({String? category}) async {
    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore
          .collection('products')
          .where('status', isEqualTo: 'verified');

      // Filter berdasarkan kategori jika dipilih
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs.map(
        (doc) => ProductModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id,
        ),
      ).toList();

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------
  // FETCH PRODUK BERDASARKAN SELLER
  // ------------------------------
  Future<void> fetchProductsBySeller(String sellerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------
  // ADD PRODUCT
  // ------------------------------
  Future<bool> addProduct(ProductModel product) async {
    try {
      final docRef =
          await _firestore.collection('products').add(product.toMap());

      final savedProduct = ProductModel(
        id: docRef.id,
        sellerId: product.sellerId,
        bengkelId: product.bengkelId,
        name: product.name,
        description: product.description,
        category: product.category,
        price: product.price,
        stock: product.stock,
        photoUrl: product.photoUrl,
        brand: product.brand,
        condition: product.condition,
        status: product.status,
        createdAt: product.createdAt,
      );

      _products.insert(0, savedProduct);
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ------------------------------
  // UPDATE PRODUCT
  // ------------------------------
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection("products")
          .doc(product.id)
          .update(product.toMap());

      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }

      return true;

    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ------------------------------
  // DELETE PRODUCT
  // ------------------------------
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection("products").doc(productId).delete();

      _products.removeWhere((p) => p.id == productId);
      notifyListeners();

      return true;

    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ------------------------------
  // DUMMY untuk ShopScreen
  // (nanti ini harus dipindah ke CartProvider!)
  // ------------------------------
  int get cartItemCount => 0; 
}
