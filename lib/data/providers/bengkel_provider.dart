import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/bengkel_model.dart';
// Note: product and order models not required here currently
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

