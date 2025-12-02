import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  
  AuthProvider() {
    // HAPUS _checkAuthState() dari sini
    _initAuth(); // Ganti dengan init yang lebih aman
  }
  
  Future<void> _initAuth() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
      }
    } catch (e) {
      print('Auth init error: $e');
      // Jangan throw error, biar app tetap jalan
    }
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document
      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toMap());
      
      _currentUser = userModel;
      await _saveLoginState();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _loadUserData(credential.user!.uid);
      await _saveLoginState();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    await _clearLoginState();
    notifyListeners();
  }
  
  Future<void> _loadUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.data()!, doc.id);
    }
  }
  
  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
    await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
  }
  
  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return false;
    
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.id)
          .update(updates);
      
      await _loadUserData(_currentUser!.id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}