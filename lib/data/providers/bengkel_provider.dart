import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/bengkel_model.dart';
import '../../core/constants/app_constants.dart';

class BengkelProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BengkelModel> _nearbyBengkels = [];
  List<BengkelModel> _allBengkels = [];

  BengkelModel? _selectedBengkel;

  bool _isLoading = false;
  String? _errorMessage;

  List<BengkelModel> get nearbyBengkels => _nearbyBengkels;
  List<BengkelModel> get allBengkels => _allBengkels;
  BengkelModel? get selectedBengkel => _selectedBengkel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNearbyBengkels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Position? position = await _getCurrentLocation();

      final querySnapshot = await _firestore
          .collection(AppConstants.bengkelsCollection)
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true)
          .get();

      _allBengkels = querySnapshot.docs
          .map((doc) => BengkelModel.fromMap(doc.data(), doc.id))
          .toList();

      if (position != null) {
        _nearbyBengkels = [..._allBengkels];

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
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

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

    final q = query.toLowerCase();
    return _allBengkels.where((bengkel) {
      return bengkel.name.toLowerCase().contains(q) ||
          bengkel.description.toLowerCase().contains(q) ||
          bengkel.services.any((s) => s.toLowerCase().contains(q));
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

  /// FIX: fetch bengkel by owner
  Future<void> fetchBengkelByOwner(String ownerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection(AppConstants.bengkelsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _selectedBengkel =
            BengkelModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      } else {
        _selectedBengkel = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
