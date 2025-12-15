import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bengkel_model.dart';
import '../../core/constants/app_constants.dart';

class BengkelProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BengkelModel> _verifiedBengkels = [];
  BengkelModel? _selectedBengkel;

  bool _isLoading = false;
  String? _errorMessage;

  // ================= GETTERS =================
  List<BengkelModel> get verifiedBengkels => _verifiedBengkels;
  BengkelModel? get selectedBengkel => _selectedBengkel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ================= USER =================
  /// Ambil SEMUA bengkel TERVERIFIKASI
Future<void> loadVerifiedBengkels() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final snapshot = await _firestore
        .collection(AppConstants.bengkelsCollection)
        .where('status', isEqualTo: 'verified')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    _verifiedBengkels = snapshot.docs
        .map((doc) => BengkelModel.fromMap(doc.data(), doc.id))
        .toList();

    debugPrint('✅ Bengkel loaded: ${_verifiedBengkels.length}');
  } catch (e) {
    debugPrint('❌ ERROR loadVerifiedBengkels: $e');
    _errorMessage = 'Gagal memuat bengkel';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // ================= SEARCH =================
  /// Cari bengkel dari list verified (LOCAL SEARCH)
  Future<List<BengkelModel>> searchBengkels(String query) async {
    // ⛔ pastikan data sudah ada
    if (_verifiedBengkels.isEmpty) {
      await loadVerifiedBengkels();
    }

    if (query.isEmpty) return [];

    final q = query.toLowerCase();

    return _verifiedBengkels.where((bengkel) {
      return bengkel.name.toLowerCase().contains(q) ||
          bengkel.address.toLowerCase().contains(q) ||
          bengkel.description.toLowerCase().contains(q) ||
          (bengkel.services.isNotEmpty &&
              bengkel.services.any(
                (service) => service.toLowerCase().contains(q),
              ));
    }).toList();
  }

  // ================= SELLER =================
  /// Ambil bengkel milik seller
  Future<void> fetchBengkelByOwner(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(AppConstants.bengkelsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      _selectedBengkel = snapshot.docs.isNotEmpty
          ? BengkelModel.fromMap(
              snapshot.docs.first.data(),
              snapshot.docs.first.id,
            )
          : null;
    } catch (e) {
      _errorMessage = 'Gagal memuat bengkel: $e';
      _selectedBengkel = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= SINGLE =================
  Future<BengkelModel?> getBengkelById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.bengkelsCollection)
          .doc(id)
          .get();

      if (!doc.exists) return null;
      return BengkelModel.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  } 
}
