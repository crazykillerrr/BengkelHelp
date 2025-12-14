import 'package:cloud_firestore/cloud_firestore.dart';

enum BengkelStatus { pending, verified, rejected }

class BengkelModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;

  final String? photoUrl;
  final List<String> services;

  final Map<String, String> operatingHours;

  final String openTime;
  final String closeTime;

  final BengkelStatus status;

  final double rating;
  final int totalReviews;

  final bool isVerified;
  final bool isActive;

  final DateTime createdAt;

  BengkelModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.photoUrl,
    required this.services,
    required this.operatingHours,
    required this.openTime,
    required this.closeTime,
    required this.status,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
  });

  static BengkelStatus _parseStatus(String? value) {
    switch (value) {
      case 'verified':
        return BengkelStatus.verified;
      case 'rejected':
        return BengkelStatus.rejected;
      default:
        return BengkelStatus.pending;
    }
  }

  factory BengkelModel.fromMap(Map<String, dynamic> map, String id) {
    return BengkelModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],

      services: List<String>.from(map['services'] ?? []),

      operatingHours: Map<String, String>.from(map['operatingHours'] ?? {}),

      openTime: map['openTime'] ?? '',
      closeTime: map['closeTime'] ?? '',

      status: _parseStatus(map['status']),

      rating: (map['rating'] ?? 0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,

      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,

      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'photoUrl': photoUrl,
      'services': services,
      'operatingHours': operatingHours,
      'openTime': openTime,
      'closeTime': closeTime,
      'status': status.name,
      'rating': rating,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
