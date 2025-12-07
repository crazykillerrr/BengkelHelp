import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    _listenAuthState();
  }

  /// LISTEN FIREBASE AUTH STATE
  void _listenAuthState() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('🚪 User signed out');
        _currentUser = null;
        notifyListeners();
      } else {
        print('👤 User signed in: ${user.email}');
        await _loadUserData(user.uid);
        notifyListeners();
      }
    });
  }

  /// SIGN UP
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
      print('📝 Signing up: $email');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth user created: ${credential.user!.uid}');

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

      print('💾 Saving user to Firestore...');
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      print('✅ User saved to Firestore');
      _currentUser = userModel;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      _errorMessage = _getAuthErrorMessage(e.code);
    } catch (e, stackTrace) {
      print('❌ Unexpected error during sign up: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = "Terjadi kesalahan: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// SIGN IN
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔐 Signing in: $email');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth successful: ${credential.user!.uid}');

      // Load user data from Firestore
      await _loadUserData(credential.user!.uid);

      if (_currentUser == null) {
        throw Exception('User data not found in Firestore');
      }

      print('✅ Sign in complete');
      print('   User: ${_currentUser!.name}');
      print('   Role: ${_currentUser!.role}');

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      _errorMessage = _getAuthErrorMessage(e.code);
    } catch (e, stackTrace) {
      print('❌ Unexpected error during sign in: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = "Terjadi kesalahan: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// SIGN OUT
  Future<void> signOut() async {
    print('🚪 Signing out...');
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
    print('✅ Signed out');
  }
  
  /// GET CURRENT USER BALANCE (from Firestore)
  Future<double> getCurrentBalance() async {
    if (_currentUser == null) return 0.0;
    
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.id)
          .get();
      
      if (doc.exists) {
        return (doc.data()?['walletBalance'] ?? 0).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('❌ Error getting balance: $e');
      return 0.0;
    }
  }

  /// LOAD USER DATA FROM FIRESTORE
  Future<void> _loadUserData(String uid) async {
    try {
      print('📖 Loading user data from Firestore: $uid');
      
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        print('❌ User document not found in Firestore');
        throw Exception('User document not found in Firestore');
      }

      print('📄 Document exists, parsing data...');
      final data = doc.data();
      print('   Raw Firestore data: $data');

      _currentUser = UserModel.fromMap(data!, doc.id);
      
      print('✅ User loaded successfully');
      print('   ID: ${_currentUser!.id}');
      print('   Email: ${_currentUser!.email}');
      print('   Name: ${_currentUser!.name}');
      print('   Role: ${_currentUser!.role}');
    } catch (e, stackTrace) {
      print('❌ Error loading user data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// UPDATE PROFILE
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
      print('✏️  Updating profile for: ${_currentUser!.id}');
      
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
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
      
      print('✅ Profile updated successfully');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error updating profile: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// AUTH ERROR MESSAGE HANDLER
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
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}