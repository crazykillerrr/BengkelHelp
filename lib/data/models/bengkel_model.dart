import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String status; // pending | verified | rejected
  final bool isActive;
  final double rating;
  final int totalReviews;
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
    required this.isActive,
    required this.rating,
    required this.totalReviews,
    required this.createdAt,
  });

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
      status: map['status'] ?? 'pending',
      isActive: map['isActive'] ?? true,
      rating: (map['rating'] ?? 0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
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
      'status': status,
      'isActive': isActive,
      'rating': rating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
